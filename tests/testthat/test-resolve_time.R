test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("historical scenario has correct defaults", {
  result <- resolve_time("historical")
  expect_equal(result$start_year, 1850)
  expect_equal(result$end_year, 2014)
})

test_that("ssp scenario has correct defaults", {
  result <- resolve_time("ssp245")
  expect_equal(result$start_year, 2015)
  expect_equal(result$end_year, 2100)
})

test_that("custom years are respected", {
  result <- resolve_time("ssp245", start_year = 2020, end_year = 2060)
  expect_equal(result$start_year, 2020)
  expect_equal(result$end_year, 2060)
})

test_that("years out of range throw error", {
  expect_error(resolve_time("historical", start_year = 1800, end_year = 2014))
  expect_error(resolve_time("ssp245", start_year = 2015, end_year = 2200))
})

test_that("start_year > end_year throws error", {
  expect_error(resolve_time("ssp245", start_year = 2060, end_year = 2020))
})

test_that("returns a list with start_year and end_year", {
  result <- resolve_time("ssp245")
  expect_type(result, "list")
  expect_named(result, c("start_year", "end_year"))
})
