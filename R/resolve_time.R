#' Resolve Time Range for a CMIP6 Scenario
#'
#' @description
#' Validates and returns the start and end year for a given CMIP6 scenario.
#' If no years are provided, defaults to the full available time range
#' for the selected scenario.
#'
#' @param scenario Character. Emissions scenario (e.g. \code{"ssp585"},
#'   \code{"historical"}).
#' @param start_year Integer or \code{NULL}. First year of the requested period.
#'   Defaults to \code{1850} for historical, \code{2015} for SSP scenarios.
#' @param end_year Integer or \code{NULL}. Last year of the requested period.
#'   Defaults to \code{2015} for historical, \code{2100} for SSP scenarios.
#'
#' @return A named list with elements \code{start_year} and \code{end_year}.
#' @keywords internal

resolve_time <- function(scenario, start_year = NULL, end_year = NULL) {

  if (scenario == "historical") {
    default_start <- 1850
    default_end <- 2014
  } else {
    default_start <- 2015
    default_end <- 2100
  }

  if (is.null(start_year)) start_year <- default_start
  if (is.null(end_year)) end_year <- default_end

  if (start_year < default_start || end_year > default_end) {
    stop("Years out of range for selected scenario")
  }

  if (start_year > end_year) {
    stop("start_year must be <= end_year")
  }

  list(
    start_year = start_year,
    end_year = end_year
  )
}
