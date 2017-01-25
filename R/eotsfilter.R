# describe the filtering service
#
# @return A character
getcapabilities <- function(){
  cap <- '{"name":"eotsfilter","whitaker1":{"name":"Weighted Whittaker smoothing with a first order finite difference penalty","missingdata":"false","parameters":{"lambda":{"keyname":"lambda","keytype":"double","keymin":1,"keymax":100000000,"default":100},"sample":{"id":"UUID","lat":"double","lon":"double","label":"string","timeline":["string date"],"validdata":["boolean"],"attributes":[{"attribute":"string name","values":["double"]},{"attribute":"string name","values":["double"]}]}}}}'
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
