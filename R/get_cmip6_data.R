#' Download CMIP6 Climate Data from the Copernicus Climate Data Store
#'
#' @description
#' Downloads CMIP6 climate model data from the Copernicus Climate Data Store
#' (CDS) API for a specified model, variable, scenario, time range, and region.
#'
#' @param model Character. Name of the CMIP6 model. Default: `"AWI-CM-1-1-MR"`.
#' @param variable Character. Climate variable to download (e.g. `"tas"`, `"tasmax"`, `"pr"`).
#' @param scenario Character. Emissions scenario. One of `"historical"`, `"ssp126"`,
#'   `"ssp245"`, `"ssp370"`, `"ssp585"`.
#' @param start_year Integer. First year of the requested time range.
#' @param end_year Integer. Last year of the requested time range.
#' @param months Integer vector. Months to download (e.g. `1:12` for all months).
#' @param temporal_resolution Character. Either `"daily"` or `"monthly"`.
#'   Default: `"daily"`.
#' @param region Either `"global"` or a numeric vector `c(lon_min, lon_max, lat_min, lat_max)`.
#' @param output_file Character. Full path and filename for the downloaded
#'   `.nc` file. Defaults to `model_variable_scenario.nc` in the directory
#'   set by `set_cmip6_dir()`.
#'
#' @return A list with two elements:
#' \describe{
#'   \item{request}{The CDS API request as a list.}
#'   \item{file}{Path to the downloaded `.nc` file.}
#' }
#'
#' @examples
#' \dontrun{
#' result <- get_cmip6_data(
#'   model      = "AWI-CM-1-1-MR",
#'   variable   = "tas",
#'   scenario   = "ssp245",
#'   start_year = 2020,
#'   end_year   = 2025,
#'   months     = 1:12,
#'   region     = c(9, 14, 47, 51)
#' )
#' }
#'
#' @export


get_cmip6_data <- function(
    model = "AWI-CM-1-1-MR",
    variable = "tas",
    scenario = "ssp245",
    start_year = 2015,
    end_year = 2100,
    months = 1:12,
    region = "global",
    temporal_resolution = "daily",
    output_file = file.path(
      get_cmip6_dir(),
      paste0(model, "_", variable, "_", scenario, ".nc")
    )
) {
  # 1. Validate Model
  validate_model(model)

  # 2. Scenario & Time
  time <- resolve_time(
    scenario = scenario,
    start_year = start_year,
    end_year = end_year
  )

  # 3. Region
  region_parsed <- resolve_region(region)

  # 4. Build Request
  request <- build_request(
    model = model,
    variable = variable,
    scenario = scenario,
    start_year = time$start_year,
    end_year = time$end_year,
    months = months,
    region = region_parsed,
    temporal_resolution = temporal_resolution
  )

  # 5. Download Data
  output_path <- load_cds_data(
    request = request,
    output_file = output_file
  )

  return(list(
    request = request,
    file = output_path
  ))
}



