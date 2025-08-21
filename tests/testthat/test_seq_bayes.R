test_that("seq_bayes() stops on non-positive mu", {
  expect_error(seq_bayes(c(1, 2), mu = 0))
})

test_that("seq_bayes() stops on kappa less than 1", {
  expect_error(seq_bayes(c(1, 2), mu = 1, kappa = 0.9))
})

test_that("seq_bayes() stops on non-boolean posterior flag", {
  expect_error(seq_bayes(c(1, 2), mu = 1, post = "TRUE"))
})

test_that("seq_bayes() stops on less than two positive cases", {
  expect_error(seq_bayes(c(0, 1, 0), mu = 1))
})

test_that("seq_bayes() returns posterior on positive flag", {
  expect_type(seq_bayes(c(1, 2), mu = 1, post = TRUE), "list")
})
