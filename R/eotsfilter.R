# describe the filtering service
#
# @return A character
getcapabilities <- function(){
  return('{"name":"eotsfilter","whitaker1":{"name":"Weighted Whittaker smoothing with a first order finite difference penalty","parameters":{"lambda":{"keyname":"lambda","keytype":"double","keymin":1,"keymax":100000000,"default":100},"sample":{"id":"UUID","lat":"double","lon":"double","label":"string","timeline":["string date"],"validdata":["boolean"],"attributes":[{"attribute":"string name","values":["double"]},{"attribute":"string name","values":["double"]}]}}}}')
}

# Wrapper of the Weighted Whittaker smoothing with a first order finite difference penalty
#
# @param lambda A numeric. The smoothing parameter
# @param sample A character. A JSON object of type SAMPLE
# @return       A character. A JSON object of type SAMPLE
whitaker1 <- function(lambda, sample){
  sample.list <- jsonlite::fromJSON(sample)                                     # cast JSON to list
  value.list <- sample.list$attributes$values                                   # get observations
  valid.vec <- as.logical(sample.list$validdata)                                            # get valid observation vector
  if(sum(valid.vec) != length(valid.vec)){
    stop("Whitaker1 cannot handle missing values")
  }
  vfilter.list <- lapply(value.list, ptw::whit1, lambda = lambda)               # filter
  sample.list$attributes$values <- vfilter.list                                 # rebuild JSON
  sample.list$attributes$attribute <- paste(                                    # update attribute names
    sample.list$attributes$attribute,
    "whitaker1",
    sep = "-"
  )
  return(as.character(jsonlite::toJSON(sample.list)))
}
