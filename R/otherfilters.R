#' Warpper of the Fit Structural Time Series
#'
#' @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
#' @return       A list representing A JSON object of type SAMPLE
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
