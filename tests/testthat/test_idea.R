test_that("idea() stops on non-positive mu", {
  expect_error(idea(c(1, 2), mu = 0))
})
