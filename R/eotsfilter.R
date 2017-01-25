# describe the filtering service
#
# @return A character
getcapabilities <- function(){
  cap <- '{"service":"eotsfilter","filters":[{"alias":"whitaker1","name":"Weighted Whittaker smoothing with a first order finite difference penalty","missingdata":"false","parameters":{"lambda":{"keyname":"lambda","keytype":"double","keymin":1,"keymax":100000000,"default":100},"sample":{"id":"UUID","lat":"double","lon":"double","label":"string","timeline":["string date"],"validdata":["boolean"],"attributes":[{"attribute":"string name","values":["double"]},{"attribute":"string name","values":["double"]}]}}},{"alias":"whitaker2","name":"Weighted Whittaker smoothing with a second order finite difference penalty","missingdata":"false","parameters":{"lambda":{"keyname":"lambda","keytype":"double","keymin":1,"keymax":100000000,"default":1000},"sample":{"id":"UUID","lat":"double","lon":"double","label":"string","timeline":["string date"],"validdata":["boolean"],"attributes":[{"attribute":"string name","values":["double"]},{"attribute":"string name","values":["double"]}]}}},{"alias":"fourier","name":"Filter using the Fast Discrete Fourier Transform","missingdata":"false","parameters":{"nfreq":{"keyname":"nfreq","keytype":"integer","keymin":1,"keymax":100000000,"default":1},"sample":{"id":"UUID","lat":"double","lon":"double","label":"string","timeline":["string date"],"validdata":["boolean"],"attributes":[{"attribute":"string name","values":["double"]},{"attribute":"string name","values":["double"]}]}}}]}'
  return(jsonlite::fromJSON(cap))
}




# Wrapper of the Weighted Whittaker smoothing with a first order finite difference penalty
#
# @param lambda A numeric. The smoothing parameter
# @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
# @return       A list representing A JSON object of type SAMPLE
whitaker1 <- function(lambda, sample){
  value.list <- sample$attributes$values                                        # get observations
  valid.vec <- as.logical(sample$validdata)                                     # get valid observation vector
  if(sum(valid.vec) != length(valid.vec)){
    stop("whitaker1 cannot handle missing values")
  }
  vfilter.list <- lapply(value.list, ptw::whit1, lambda = lambda)               # filter
  sample$attributes$values <- vfilter.list                                      # rebuild JSON
  sample$attributes$attribute <- paste(                                         # update attribute names
    sample$attributes$attribute,
    "whitaker1",
    sep = "-"
  )
  return(sample)
}




# Wrapper of the Weighted Whittaker smoothing with a second order finite difference penalty
#
# @param lambda A numeric. The smoothing parameter
# @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
# @return       A list representing A JSON object of type SAMPLE
whitaker2 <- function(lambda, sample){
  value.list <- sample$attributes$values                                        # get observations
  valid.vec <- as.logical(sample$validdata)                                     # get valid observation vector
  if(sum(valid.vec) != length(valid.vec)){
    stop("whitaker2 cannot handle missing values")
  }
  vfilter.list <- lapply(value.list, ptw::whit2, lambda = lambda)               # filter
  sample$attributes$values <- vfilter.list                                      # rebuild JSON
  sample$attributes$attribute <- paste(                                         # update attribute names
    sample$attributes$attribute,
    "whitaker1",
    sep = "-"
  )
  return(sample)
}




# Warpper of the Fourier filter
#
# @param sample A numeric. Number of low frequencies to keep
# @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
# @return       A list representing A JSON object of type SAMPLE
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
  sample$attributes$attribute <- paste(                                         # update attribute names
    sample$attributes$attribute,
    "fourier",
    sep = "-"
  )
  return(sample)
}





