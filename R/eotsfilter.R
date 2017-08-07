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

