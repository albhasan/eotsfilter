#' Fill in the gaps of a time series
#'
#' @param type   A numeric. The type of fill
#' @param sample A list. A SAMPLE object processed using jsonlite::fromJSON
#' @return       A list representing A JSON object of type SAMPLE
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
      value.zoo <- zoo::na.aggregate(value.zoo, zoo::as.yearmon)                # mean - group by months
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
