#library(eotsfilter)
#library(testthat)


#-------------------------------------------------------------------------------
# NORMAL CASE
#-------------------------------------------------------------------------------
measurement <- c(75, 71, 70, 74)
error_in_measurement <- c(4, 4, 4, 4)
initial_estimate <- 68
initial_error_in_estimate <- 2
# run the function
res <- eotsfilter::kalmanfilter(measurement,
                                error_in_measurement = error_in_measurement,
                                initial_estimate = initial_estimate,
                                initial_error_in_estimate = initial_error_in_estimate)
# expected results
resexp <- cbind(
  c(NA, measurement),
  c(NA, error_in_measurement),
  c(initial_estimate, 70.33333,  70.5, 70.4, 71),
  c(initial_error_in_estimate, 1.3333333, 1, 0.8, 0.6666667),
  c(NA, 0.3333333, 0.25, 0.2, 0.1666667)
)

# test results
restest <- apply(
  base::abs(res - resexp),
  MARGIN = c(1,2),
  FUN = function(x){
    if(!is.na(x)){
      testthat::expect_lt(x, expected = 3.4)
    }
  }
)
#-------------------------------------------------------------------------------
# ALL PARAMETERS ARE NULL BUT MEASUREMENTS
#-------------------------------------------------------------------------------
res <- eotsfilter::kalmanfilter(rnorm(10),
                                error_in_measurement = NULL,
                                initial_estimate = NULL,
                                initial_error_in_estimate = NULL)
testthat::expect_false(is.null(res))
#-------------------------------------------------------------------------------
# ALL PARAMETERS ARE NULL AND ALSO THE FIRST MEASUREMENT
#-------------------------------------------------------------------------------
measurement <- rnorm(10)
measurement[1] <- NA
res <- eotsfilter::kalmanfilter(measurement,
                                error_in_measurement = NULL,
                                initial_estimate = NULL,
                                initial_error_in_estimate = NULL)
testthat::expect_false(is.null(res))
#-------------------------------------------------------------------------------
# MEASUREMENT HAVE HOLES AND PARAMETERS ARE NULL
#-------------------------------------------------------------------------------
measurement <- rnorm(10)
measurement[sample(3, x = 1:(length(measurement)))] <- NA
res <- eotsfilter::kalmanfilter(measurement,
                                error_in_measurement = NULL,
                                initial_estimate = NULL,
                                initial_error_in_estimate = NULL)
testthat::expect_false(is.null(res))
#-------------------------------------------------------------------------------
# MEASUREMENT HAVE HOLES
#-------------------------------------------------------------------------------
measurement <- c(75, 71, 70, 74)
error_in_measurement <- c(4, 4, 4, 4)
initial_estimate <- 68
initial_error_in_estimate <- 2
measurement[3] <- NA
res <- eotsfilter::kalmanfilter(measurement,
                                error_in_measurement = NULL,
                                initial_estimate = NULL,
                                initial_error_in_estimate = NULL)
testthat::expect_false(is.null(res))








#-------------------------------------------------------------------------------
# LOGISTIC KALMAN
#-------------------------------------------------------------------------------
logistG <- function(r, p, k, t){
  k * p * exp(r*t) / (k + p * (exp(r*t) - 1))
}

k <- 100
p0 <- 0.1*k
r <- 0.2
deltaT <- 0.1

# Let's create some sample data:
set.seed(12345)

obsVariance <- 25
nObs = 250
nu <- rnorm(nObs, mean=0, sd=sqrt(obsVariance))
true.val <- c(p0, logistG(r, p0, k, (1:(nObs-1))*deltaT))
pop <- true.val + nu

res <- .kalmanfilter_LOG(population = pop,
                         population_error = sqrt(obsVariance),
                         rate = r,
                         k = k,
                         deltaT = deltaT,
                         Sigma = diag(c(144, 25)))

testthat::expect_true(length(true.val) == length(res$Population))
testthat::expect_lt(abs(mean(tail(true.val)) - mean(tail(res$Population))), expected = 0.0179)
testthat::expect_lt(abs(r - mean(tail(res$Rate))), expected = 0.00174)
