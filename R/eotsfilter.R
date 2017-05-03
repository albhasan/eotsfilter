# describe the filtering service
#
# @return A character
getcapabilities <- function(){
  cap <- '{"service":"eotsfilter","filters":[{"alias":"fill","name":"Fill in the missing observations","missingdata":"true","parameters":[{"keyname":"type","keytype":"integer","keymin":1,"keymax":6,"default":1,"domain":["line","last observation","spline","mean","monthly mean","yearly mean"]}],"sample":"sample object https://github.com/albhasan/eotsfilter/blob/master/jsonschema/sample_schema.json"},{"alias":"whitaker1","name":"Weighted Whittaker smoothing with a first order finite difference penalty","missingdata":"false","parameters":[{"keyname":"lambda","keytype":"double","keymin":1,"keymax":100000000,"default":100}],"sample":"sample object https://github.com/albhasan/eotsfilter/blob/master/jsonschema/sample_schema.json"},{"alias":"whitaker2","name":"Weighted Whittaker smoothing with a second order finite difference penalty","missingdata":"false","parameters":[{"keyname":"lambda","keytype":"double","keymin":1,"keymax":100000000,"default":100}],"sample":"sample object https://github.com/albhasan/eotsfilter/blob/master/jsonschema/sample_schema.json"},{"alias":"fourier","name":"Filter using the Fast Discrete Fourier Transform","missingdata":"false","parameters":[{"keyname":"nfreq","keytype":"integer","keymin":1,"keymax":-1,"default":1}],"sample":"sample object https://github.com/albhasan/eotsfilter/blob/master/jsonschema/sample_schema.json"},{"alias":"doublelogistic","name":"Double logistic function","missingdata":"false","parameters":[],"sample":"sample object https://github.com/albhasan/eotsfilter/blob/master/jsonschema/sample_schema.json"},{"alias":"sts","name":"Fit structural time series","missingdata":"false","parameters":[],"sample":"sample object https://github.com/albhasan/eotsfilter/blob/master/jsonschema/sample_schema.json"}]}'
  return(jsonlite::fromJSON(cap))
}



# Fill in the gaps of a time series
#
# @param type   A numeric. The type of fill
# @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
# @return       A list representing A JSON object of type SAMPLE
fill <- function(type, sample){
  value.list <- sample$attributes$values                                        # get observations
  valid.vec <- as.logical(sample$validdata)                                     # get valid observation vector
  date.vec <- as.Date(sample$timeline)
  fill.list <- lapply(value.list, function(value.vec, valid.vec, date.vec){
    value.vec[!valid.vec] <- NA
    value.zoo <- zoo::zoo(value.vec, date.vec)
    if(type == 0){
      value.zoo <- zoo::na.approx(value.zoo)                                    # straight line
    }else if(type == 1){
      value.zoo <- zoo::na.locf(value.zoo)                                      # Last Observation Carried Forward
    }else if(type == 2){
      value.zoo <- zoo::na.spline(value.zoo)                                    # splines
    }else if(type == 3){
      value.zoo <- zoo::na.aggregate(value.zoo)                                 # mean
    }else if(type == 4){
      value.zoo <- zoo::na.aggregate(value.zoo, zoo::as.yearmon)                     # mean - group by months
    }else if(type == 5){
      value.zoo <- zoo::na.aggregate(value.zoo, months)                         # mean - group by calendar months
    }else if(type == 6){
      value.zoo <- zoo::na.aggregate(value.zoo, format, "%Y")                   # mean - group by years
    }else{
      value.zoo <- zoo::na.locf(value.zoo)
    }
    return(zoo::coredata(value.zoo))
  },
  valid.vec = valid.vec,
  date.vec = date.vec
  )
  sample$attributes$values <- fill.list                                         # rebuild JSON
  sample$validdata <- rep(1, length(sample$validdata))
  sample$attributes$attribute <- paste(                                         # update attribute names
    sample$attributes$attribute,
    "fill_",
    type,
    sep = "-"
  )
  return(sample)
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
  sample$validdata <- rep(1, length(sample$validdata))
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
  sample$validdata <- rep(1, length(sample$validdata))
  sample$attributes$attribute <- paste(                                         # update attribute names
    sample$attributes$attribute,
    "whitaker2",
    sep = "-"
  )
  return(sample)
}




# Warpper of the Fourier filter
#
# @param nfreq A numeric. Number of low frequencies to keep
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
  sample$validdata <- rep(1, length(sample$validdata))
  sample$attributes$attribute <- paste(                                         # update attribute names
    sample$attributes$attribute,
    "fourier",
    sep = "-"
  )
  return(sample)
}



# Warpper of the double logistic fit
#
# @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
# @return       A list representing A JSON object of type SAMPLE
doublelogistic <- function(sample){
  value.list <- sample$attributes$values                                        # get observations
  valid.vec <- as.logical(sample$validdata)                                     # get valid observation vector
  # no handling of NAs
  if(sum(valid.vec) != length(valid.vec)){
    stop("doublelogistic cannot handle missing values")
  }
  # initial parameters for optimization algorithm
  start1 <- c(w.ndvi = 0.07,
              m.ndvi = 0.68,
              S = 119,
              A = 282,
              mS = 0.19,
              mA = 0.13
  )
  # function to optimize
  dlog1.f <- function(b, mydata){
    sum((mydata$y - dlog1(mydata$x, w.ndvi = b[1], m.ndvi = b[2], S = b[3], A = b[4], mS = b[5], mA = b[6]))^2)
  }
  # filter
  dlog.list <- lapply(value.list,
                      function(value.vec, start1, dlog1.f){
                        doy <- round(seq(from = 1, to = 365, length.out = length(value.vec)))
                        dlog.df <- data.frame(y = value.vec, x = doy)           # build a data.frame of values and dates
                        options(warn=-1)
                        dlog.optx <- optimx::optimx(                                    # optimization
                          par = start1, fn = dlog1.f, mydata = dlog.df,
                          control = list(
                            method = "BFGS",
                            save.failures = FALSE,
                            maxit = 2500
                          )
                        )
                        options(warn=0)
                        params <- as.vector(unlist(dlog.optx["BFGS", 1:6]))
                        return(dlog1(doy = dlog.df$x, w.ndvi = params[1], m.ndvi = params[2], S = params[3], A = params[4], mS = params[5], mA = params[6]))
                      },
                      start1 = start1,
                      dlog1.f = dlog1.f
  )
  sample$attributes$values <- dlog.list                                         # rebuild JSON
  sample$validdata <- rep(1, length(sample$validdata))
  sample$attributes$attribute <- paste(                                         # update attribute names
    sample$attributes$attribute,
    "dlog",
    sep = "-"
  )
  return(sample)
}



# Warpper of the Fit Structural Time Series
#
# @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
# @return       A list representing A JSON object of type SAMPLE
sts <- function(sample){
  value.list <- sample$attributes$values                                        # get observations
  valid.vec <- as.logical(sample$validdata)                                     # get valid observation vector
  # no handling of NAs
  if(sum(valid.vec) != length(valid.vec)){
    stop("kfas cannot handle missing values")
  }
  # filter
  sts.list <- lapply(value.list,
                      function(value.vec){
                        fit <- stats::StructTS(value.vec, type = "level")
                        return(as.numeric(fit$fitted))
                      }
  )
  sample$attributes$values <- sts.list                                          # rebuild JSON
  sample$validdata <- rep(1, length(sample$validdata))
  sample$attributes$attribute <- paste(                                         # update attribute names
    sample$attributes$attribute,
    "sts",
    sep = "-"
  )
  return(sample)
}
