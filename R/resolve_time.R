#' Resolve Time Range for a CMIP6 Scenario
#'
#' @param scenario Character. One of `"historical"`, `"ssp126"`, `"ssp245"`,
#'   `"ssp370"`, `"ssp585"`.
#' @param start_year Integer or NULL. Start year. Defaults to scenario minimum.
#' @param end_year Integer or NULL. End year. Defaults to scenario maximum.
#'
#' @return A list with `start_year` and `end_year`.
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
