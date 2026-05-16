#' Build a CDS API Request
#'
#' Constructs a formatted request list for the Copernicus Climate Data Store (CDS) API.
#' Short variable names (e.g. "tas") are automatically mapped to their CDS API equivalents.
#'
#' @param model Character. CMIP6 model name (e.g. "MPI-ESM1-2-LR"). See \code{cmip6_info("models")} for all available models.
#' @param variable Character. Climate variable short name (e.g. "tas", "pr"). See \code{cmip6_info("variables")} for all available variables.
#' @param scenario Character. Emissions scenario (e.g. "ssp585", "historical"). See \code{cmip6_info("scenarios")} for all available scenarios.
#' @param start_year Integer. First year of the requested time period.
#' @param end_year Integer. Last year of the requested time period.
#' @param months Integer vector. Months to include (e.g. \code{1:12} for all months).
#' @param region List. Output of \code{resolve_region()}, defining the spatial extent.
#' @param temporal_resolution Character. Either \code{"monthly"} or \code{"daily"}. Default is \code{"daily"}.
#'
#' @return A named list formatted for use with the CDS API.
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

  # Short name → Change API Name if available
  api_variable <- if (variable %in% names(VARIABLE_MAP)) {
    VARIABLE_MAP[[variable]]
  } else {
    variable
  }

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
