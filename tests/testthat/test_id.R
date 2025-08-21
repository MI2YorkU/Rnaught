test_that("id() stops on non-positive mu", {
  expect_error(id(c(1, 2), mu = 0))
})
