################################################################################
# Adapted from:
# Fourier Transform: A R Tutorial
#-------------------------------------------------------------------------------
# http://www.di.fc.ul.pt/~jpn/r/fourier/fourier.html
################################################################################


#' Warpper of the Fourier filter
#'
#' @param nfreq A numeric. Number of low frequencies to keep
#' @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
#' @return       A list representing A JSON object of type SAMPLE
fourier <- function(nfreq, sample){
  value.list <- sample$attributes$values                                        # get observations
  valid.vec <- as.logical(sample$validdata)                                     # get valid observation vector
  # no handling of NAs
  if(sum(valid.vec) != length(valid.vec)){
    stop("fourier cannot handle missing values")
  }
  # make sure nfreq is valid
  valid.vecl <- unlist(lapply(value.list, length))
  if(min(valid.vecl) < nfreq){
    nfreq <- min(valid.vecl)
  }
  # filter
  vfourier.list <- lapply(value.list,
                          function(value.vec){
                            time <- 1
                            acq.freq <- (length(value.vec) - 1)/time
                            ts <- seq(0, time, 1/acq.freq)
                            # de-trend
                            trend <- stats::lm(value.vec ~ ts)
                            detrended.trajectory <- trend$residuals
                            obs.pred <- stats::predict(trend)
                            # build the filtered signal
                            X.k <- stats::fft(detrended.trajectory)
                            X.k[seq(nfreq + 1, length(X.k))] <- 0                                # unwanted higher frequencies become 0
                            x.n <- get.trajectory(X.k, ts, acq.freq) / acq.freq                  # TODO: why the scaling?
                            x.n <- x.n + (value.vec - trend$residuals)                           # add back the trend
                            return(Re(x.n))                                                      # gert rid of imaginary numbers
                          }
  )
  sample$attributes$values <- vfourier.list                                     # rebuild JSON
  sample$validdata <- rep(1, length(sample$validdata))
  sample$attributes$attribute <- paste(                                         # update attribute names
    sample$attributes$attribute,
    "fourier",
    sep = "-"
  )
  return(sample)
}


# inverse fourier transformation
# returns the x.n time series for a given time sequence (ts) and
# a vector with the amount of frequencies k in the signal (X.k)
get.trajectory <- function(X.k, ts, acq.freq) {
  N   <- length(ts)
  i   <- complex(real = 0, imaginary = 1)
  x.n <- rep(0, N)           # create vector to keep the trajectory
  ks  <- 0:(length(X.k)-1)
  for(n in 0:(N-1)) {       # compute each time point x_n based on freqs X.k
    x.n[n+1] <- sum(X.k * exp(i*2*pi*ks*n/N)) / N
  }
  x.n * acq.freq
}
