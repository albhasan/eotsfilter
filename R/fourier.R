################################################################################
# Fourier Transform: A R Tutorial
#-------------------------------------------------------------------------------
# http://www.di.fc.ul.pt/~jpn/r/fourier/fourier.html
################################################################################


# inverse fourier transformation
# returns the x.n time series for a given time sequence (ts) and
# a vector with the amount of frequencies k in the signal (X.k)
get.trajectory <- function(X.k, ts, acq.freq) {
  N   <- length(ts)
  i   <- complex(real = 0, imaginary = 1)
  x.n <- rep(0, N)           # create vector to keep the trajectory
  ks  <- 0:(length(X.k)-1)
  for(n in 0:(N-1)) {       # compute each time point x_n based on freqs X.k
    x.n[n+1] <- sum(X.k * exp(i*2*pi*ks*n/N)) / N
  }
  x.n * acq.freq
}
