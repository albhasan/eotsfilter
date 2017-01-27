# Transform a date into the year-day_of_the_year date (YYYYDOY)
#
# @param date.vec   A Date vector
# @return           A character representing a date as day-of-the-year (YYYYDOY)
date2ydoy <- function(date.vec){
  yearOriginText <- paste(format(date.vec, "%Y"), "/01/01", sep="")
  yearOrigin <- as.POSIXlt(yearOriginText)
  doy <- as.numeric(as.Date(date.vec) - as.Date(yearOrigin)) + 1
  res <- paste(format(date.vec, "%Y"), sprintf("%03d", doy), sep="")
  return(res)
}
