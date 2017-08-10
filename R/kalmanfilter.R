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
    kg[i] <- .KG(e_est = e_est[i - 1], e_mea = error_in_measurement[i - 1])
    m <- measurement[i - 1]
    if(is.na(m)){
      m <- est[i - 1]                                                           # if the measurement is missing, use the estimation instead
    }
    est[i] <- .EST_t(kg = kg[i], est_t1 = est[i - 1], mea = m)
    e_est[i] <- .E_EST_t(kg = kg[i], e_est_t1 = e_est[i - 1])
  }
  # format the results
  res <- cbind(c(NA, measurement), c(NA, error_in_measurement), est, e_est, kg)
  colnames(res) <- c("measurement", "error_in_measurement", "estimate", "error_in_estimate", "kalman_gain")
  rownames(res) <- paste("t", seq.int(from = -1, to = (nrow(res) - 2)), sep = "")
  return(res)
}



# Adjust the logistic model parameters using the extended Kalman filter
#
# @param population         A vector of noisy measurements of population
# @param population_error   The error in the population measurements.
# @param rate               A first estimation of the rate of growth of the population
# @param k                  The carrying capacity (maximum value of the population)
# @param deltaT             Length of a time step
# @param Sigma              Covariance matrix ()
# @return
.kalmanfilter_LOG <- function(population,
                              population_error,
                              rate,
                              k,
                              deltaT,
                              Sigma){
  # Adapted from http://www.magesblog.com/2015/01/extended-kalman-filter-example-in-r.html

  G <- t(c(0, 1))
  Q <- diag(c(0, 0))                                                            # Evolution error
  R <- population_error ^ 2                                                     # Observation error
  x <- c(rate, population[1])                                                   # Prior (distribution)
  n <- length(population)
  res <- data.frame(Rate = rep(NA, n), Population=rep(NA, n))
  #
  # Analytical solution to the logistic growth function
  # @param r  Growth rate
  # @param p0 Populaion
  # @param k  Carrying capacity
  # @param t  Time
  # @return   Population at t
  .logGrowth <- function(r, p0, k, t){
    k * p0 * exp(r * t) / (k + p0 * (exp(r * t) - 1))
  }
  #
  # Auxiliary function for calculating the jacobian
  # @param x        A vector of rate and population
  # @param k        Carrying capacity
  # @param deltaT   Length of a time step
  .a <- function(x, k, deltaT){
    c(r=x[1], .logGrowth(r = x[1], p0 = x[2], k = k, t = deltaT))
  }
  #
  for(i in 1:n){
    xobs <- c(0, population[i])
    y <- G %*% xobs
    # Filter
    SigTermInv <- solve(G %*% Sigma %*% t(G) + R)
    xf <- x + Sigma %*% t(G) %*%  SigTermInv %*% (y - G %*% x)
    Sigma <- Sigma - Sigma %*% t(G) %*% SigTermInv %*% G %*% Sigma
    #
    A <- numDeriv::jacobian(.a, x = x, k = k, deltaT = deltaT)
    K <- A %*% Sigma %*% t(G) %*% solve(G %*% Sigma %*% t(G) + R)
    res[i,] <- x
    # Predict
    x <- .a(x = xf, k = k, deltaT = deltaT) + K %*% (y - G %*% xf)
    Sigma <- A %*% Sigma %*% t(A) - K %*% G %*% Sigma %*% t(A) + Q
  }
  return(res)
}
