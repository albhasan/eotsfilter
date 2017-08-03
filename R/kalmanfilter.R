# Compute the Kalman filter
#
# @param measurement                    A vector of measurements
# @param error_in_measurement           A vector of errors in the measuments
# @param initial_estimate               A first estimation of the measurement
# @param initial_error_in_estimate      A first error in the estimation
# @return                               A matrix of 3 columns estimate, error_in_estimate, and kalman_gain
.kalmanfilter <- function(measurement,
                          error_in_measurement,
                          initial_estimate,
                          initial_error_in_estimate){
  kg <- vector(mode = "logical", length = length(measurement) + 1)
  est <- vector(mode = "logical", length = length(measurement) + 1)
  e_est <- vector(mode = "logical", length = length(measurement) + 1)
  #
  # Compute the Kalman gain
  # @param e_est    error in estimation
  # @param e_mea    error in measurement
  # @return         the Kalman gain
  .KG <- function(e_est, e_mea){
    return(e_est/(e_est + e_mea))
  }
  # Compute the KF current estimate
  # @param kg        Kalman gain
  # @param est_t1    previous estimate
  # @param mea       measurement
  # @return          current estimate
  .EST_t <- function(kg, est_t1, mea){
    est_t1 + kg * (mea - est_t1)
  }
  # Compute the KF error in the estimation
  # @param kg        Kalman gain
  # @param e_est_t1  previous error in estimation
  .E_EST_t <- function(kg, e_est_t1){
    (1 - kg) * e_est_t1
  }
  # add initial results
  est[1] <- initial_estimate[1]
  e_est[1] <- initial_error_in_estimate[1]
  kg[1] <- NA
  # compute
  for(i in 2:(length(measurement) + 1)){
    kg[i] <- .KG(e_est[i - 1], error_in_measurement[i - 1])
    m <- measurement[i - 1]
    if(is.na(m)){
      m <- est[i - 1]                                                           # if the measurement is missing, use the estimation instead
    }
    est[i] <- .EST_t(kg[i], est[i - 1], m)
    e_est[i] <- .E_EST_t(kg[i], e_est[i - 1])
  }
  # format the results
  res <- cbind(c(NA, measurement), c(NA, error_in_measurement), est, e_est, kg)
  colnames(res) <- c("measurement", "error_in_measurement", "estimate", "error_in_estimate", "kalman_gain")
  rownames(res) <- paste("t", seq.int(from = -1, to = (nrow(res) - 2)), sep = "")
  return(res)
}


