#' Warpper of the double logistic fit
#'
#' @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
#' @return       A list representing A JSON object of type SAMPLE
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




# Estimation of NDVI using a double logistic function. Taken from Global land surface phenology trends from GIMMS database by Julien & Sobrino 2009. Equation 1
#
# @param doy    A numeric. Day of the year (0:364)
# @param w.ndvi A numeric. Winter NDVI value
# @param m.ndvi A numeric. Maximum NDVI value
# @param S      A numeric. Increasing inflection point (spring date)
# @param A      A numeric. Drecreasing inflection point (autumn date)
# @param mS     A numeric. Rate of increase at S
# @param mA     A numeric. Rate of decrease at A
# @return       A numeric. An estimation od NDVI for a given day of the year
dlog1 <- function(doy, w.ndvi, m.ndvi, S, A, mS, mA){
  # Global land surface phenology trends from GIMMS database by Julien & Sobrino. Equation 1
  # TEST: plot(dlog1(doy = 0:364, w.ndvi = 0.07, m.ndvi = 0.68, S = 119, A = 282, mS = 0.19, mA = 0.13), type = "l")
  return(w.ndvi + (m.ndvi - w.ndvi) * ((1/(1 + exp(-mS * (doy - S)))) + (1/(1 + exp( mA * (doy - A)))) - 1))
}



# Estimation of NDVI using a double logistic function for arid and semi-arid areas. Taken from Global land surface phenology trends from GIMMS database by Julien & Sobrino 2009. Equation 2
#
# @param doy    A numeric. Day of the year (0:364)
# @param w.ndvi A numeric. Winter NDVI value
# @param m.ndvi A numeric. Maximum NDVI value
# @param S      A numeric. Increasing inflection point (spring date)
# @param A      A numeric. Drecreasing inflection point (autumn date)
# @param mS     A numeric. Rate of increase at S
# @param mA     A numeric. Rate of decrease at A
# @return       A numeric. An estimation od NDVI for a given day of the year
dlog2 <- function(doy, w.ndvi, m.ndvi, S, A, mS, mA){
  # Global land surface phenology trends from GIMMS database by Julien & Sobrino. Equation 1
  return(m.ndvi - (m.ndvi - w.ndvi) * ((1/(1 + exp(-mS * (doy - S)))) + (1/(1 + exp( mA * (doy - A)))) - 1))
}
