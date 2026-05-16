test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("global region returns correct type", {
  result <- resolve_region("global")
  expect_equal(result$type, "global")
})

test_that("valid bbox returns correct structure", {
  result <- resolve_region(c(-10, 30, 45, 60))
  expect_equal(result$type, "bbox")
  expect_equal(result$lon_min, -10)
  expect_equal(result$lon_max, 30)
  expect_equal(result$lat_min, 45)
  expect_equal(result$lat_max, 60)
})

test_that("bbox with wrong length throws error", {
  expect_error(resolve_region(c(9, 14, 47)))
  expect_error(resolve_region(c(9, 14, 47, 51, 100)))
})

test_that("invalid bbox throws error", {
  expect_error(resolve_region(c(30, -10, 47, 51)))  # lon_min > lon_max
  expect_error(resolve_region(c(9, 14, 60, 47)))    # lat_min > lat_max
})

test_that("unknown region name throws error", {
  expect_error(resolve_region("europe"))
})

test_that("non-numeric non-character input throws error", {
  expect_error(resolve_region(TRUE))
})
