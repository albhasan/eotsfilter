#' Wrapper of the Weighted Whittaker smoothing with a first order finite difference penalty
#'
#' @param lambda A numeric. The smoothing parameter
#' @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
#' @return       A list representing A JSON object of type SAMPLE
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



#' Wrapper of the Weighted Whittaker smoothing with a second order finite difference penalty
#'
#' @param lambda A numeric. The smoothing parameter
#' @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
#' @return       A list representing A JSON object of type SAMPLE
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
