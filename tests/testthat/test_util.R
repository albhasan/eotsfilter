#library(eotsfilter)
#library(testthat)



teststr <- "123456789"
testthat::expect_equal(.substrRight(teststr, 1, 1), "9")
testthat::expect_equal(.substrRight(teststr, nchar(teststr), nchar(teststr)), "1")
testthat::expect_equal(.substrRight(teststr, 1, 2), "89")
testthat::expect_equal(.substrRight(teststr, 1, 3), "789")



testthat::expect_false(.tn2bool("0"))
testthat::expect_true(.tn2bool("1"))
testthat::expect_true(is.na(.tn2bool("1100")))
testthat::expect_false(.tn2bool(0))
testthat::expect_true(.tn2bool(1))
testthat::expect_true(is.na(.tn2bool(1100)))



teststr <- "123456789"
testthat::expect_equal(.invertString(teststr), "987654321")
