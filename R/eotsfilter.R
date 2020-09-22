#' Kalman filter
#' @name kalmanfilter
#' @description  A simple Kalman filter implementation
#'
#' @param measurement                    A vector of measurements
#' @param error_in_measurement           A vector of errors in the measuments
#' @param initial_estimate               A first estimation of the measurement
#' @param initial_error_in_estimate      A first error in the estimation
#' @return                               A matrix of 3 columns estimate, error_in_estimate, and kalman_gain
#' @export
kalmanfilter <- function(measurement,
                         error_in_measurement = NULL,
                         initial_estimate = NULL,
                         initial_error_in_estimate = NULL){
  # coerce
  if(!is.vector(measurement)){
    measurement <- as.vector(measurement)
  }
  # default values
  if(is.null(initial_estimate) || is.na(initial_estimate)){
    initial_estimate <- base::mean(measurement, na.rm = TRUE)
  }
  if(is.null(initial_error_in_estimate) || is.na(initial_error_in_estimate)){
    initial_error_in_estimate <- 3 * base::abs(stats::sd(measurement, na.rm = TRUE))
  }
  if(is.null(error_in_measurement)){
    error_in_measurement <- 2 * rep(stats::sd(measurement, na.rm = TRUE), length.out = base::length(measurement))
  }
  # do
  return(
    .kalmanfilter(measurement = measurement,
                  error_in_measurement = error_in_measurement,
                  initial_estimate = initial_estimate,
                  initial_error_in_estimate = initial_error_in_estimate)
  )
}



#' DEPRECATED (moved to scidbutil) - Add quality description to MOD13Q1
#' @name addMod13Q1quality
#' @description  Add readable quality data to a MOD13Q1 time series according to its data quality
#'
#' @param x A data frame containing the column c("quality")
#' @return  A data frame with additional columns.
#' @export
addMod13Q1quality <- function(x){
  stop("DEPRECATED (moved to scidbutil)")
}






#' Cast MOD13Q1 quality data to codes
#' @name mod13q1quality2codes
#' @description  Cast MOD13Q1 quality data to codes
#'
#' @param x A data frame containing the column c("quality")
#' @return  A data frame with additional columns.
#' @details See TABLE 2: MOD13Q1 VI Quality at https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod13q1
#' @export
mod13q1quality2codes <- function(x){
  return(.mod13q1quality2codes(x = x))
}
