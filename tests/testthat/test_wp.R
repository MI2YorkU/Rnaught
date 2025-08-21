test_that("wp() stops on non-boolean serial flag", {
  expect_error(wp(c(1, 2), serial = "TRUE"))
})

test_that("wp() stops on non-integer grid length", {
  expect_error(wp(c(1, 2), grid_length = 100.1))
})

test_that("wp() stops on non-positive max shape", {
  expect_error(wp(c(1, 2), max_shape = 0))
})

test_that("wp() stops on non-positive max scale", {
  expect_error(wp(c(1, 2), max_scale = 0))
})

test_that("wp() stops on non-positive mu", {
  expect_error(wp(c(1, 2), mu = 0))
})

test_that("wp() returns serial on positive flag", {
  expect_type(wp(c(1, 2), serial = TRUE), "list")
})
