#' Build a CDS API Request
#'
#' @param model Character. CMIP6 model name.
#' @param variable Character. Climate variable.
#' @param scenario Character. Emissions scenario.
#' @param start_year Integer. Start year.
#' @param end_year Integer. End year.
#' @param months Integer vector. Months to request.
#' @param region List. Output of `resolve_region()`.
#'
#' @return A list formatted for the CDS API.
#' @keywords internal

build_request <- function(
    model,
    variable,
    scenario,
    start_year,
    end_year,
    months,
    region,
    temporal_resolution = "daily"
) {

  years <- as.list(as.character(seq(start_year, end_year)))

  months_fmt <- sprintf("%02d", months)

  area <- if (region$type == "global") {
    NULL
  } else {
    c(region$lat_max, region$lon_min, region$lat_min, region$lon_max)
  }

  list(
    model = model,
    variable = variable,
    experiment = scenario,
    year = years,
    month = months_fmt,
    area = area,
    temporal_resolution = temporal_resolution,
    format = "zip"
  )
}
