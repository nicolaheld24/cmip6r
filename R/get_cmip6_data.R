#' Download CMIP6 Data from the Copernicus Climate Data Store
#'
#' Downloads CMIP6 climate data for a specified model, variable, scenario,
#' time period, and region. Data is downloaded as a NetCDF file and saved
#' to the local CMIP6 data directory.
#'
#' @param model Character. CMIP6 model name. Default is \code{"AWI-CM-1-1-MR"}.
#'   See \code{cmip6_info("models")} for all available models.
#' @param variable Character. Climate variable short name. Default is \code{"tas"}.
#'   See \code{cmip6_info("variables")} for all available variables.
#' @param scenario Character. Emissions scenario. Default is \code{"ssp245"}.
#'   See \code{cmip6_info("scenarios")} for all available scenarios.
#' @param start_year Integer. First year of the requested time period. Default is \code{2015}.
#' @param end_year Integer. Last year of the requested time period. Default is \code{2100}.
#' @param months Integer vector. Months to include. Default is \code{1:12} (all months).
#' @param region Character or numeric vector. Either \code{"global"} for global coverage,
#'   or a bounding box as \code{c(lon_min, lon_max, lat_min, lat_max)}. Default is \code{"global"}.
#' @param temporal_resolution Character. Either \code{"monthly"} or \code{"daily"}.
#'   Default is \code{"daily"}.
#' @param output_file Character. Path to save the downloaded NetCDF file.
#'   Defaults to the package data directory.
#'
#' @return A named list with two elements:
#'   \describe{
#'     \item{request}{The formatted CDS API request.}
#'     \item{file}{Path to the downloaded NetCDF file.}
#'   }
#' @export
#'
#' @examples
#' \dontrun{
#' data <- get_cmip6_data(
#'   variable   = "tas",
#'   model      = "MPI-ESM1-2-LR",
#'   scenario   = "ssp585",
#'   start_year = 2015,
#'   end_year   = 2100,
#'   months     = 1:12,
#'   region     = c(9, 14, 47, 51),
#'   temporal_resolution = "monthly"
#' )
#' }


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
  # 1. Validate inputs first ← alles oben
  valid_variables <- c(
    "tas", "tasmax", "tasmin", "pr"
  )

  if (!variable %in% names(VARIABLE_MAP)) {
    # Recognizes typos
    closest <- names(VARIABLE_MAP)[which.min(adist(variable, names(VARIABLE_MAP)))]

    warning(
      "Variable '", variable, "' is not in the known variable list.\n",
      "Did you mean '", closest, "'?\n",
      "Known variables:\n",
      paste0("  - ", names(VARIABLE_MAP), collapse = "\n"), "\n",
      "Download will proceed anyway.\n",
      "See https://cds.climate.copernicus.eu/datasets/projections-cmip6 for all available variables."
    )
  }

  valid_scenarios <- c("historical", "ssp126", "ssp245", "ssp370", "ssp585")
  # Scenario
  if (!scenario %in% valid_scenarios) {
    warning(
      "Scenario '", scenario, "' is not in the known scenario list. ",
      "Download will proceed, but plotting with plot_timeseries() may not work correctly. ",
      "Supported scenarios for plotting: ", paste(valid_scenarios, collapse = ", "), "."
    )
  }

  # 2. Validate Model
  validate_model(model)

  # 3. Scenario & Time
  time <- resolve_time(scenario = scenario, start_year = start_year, end_year = end_year)

  # 4. Region
  region_parsed <- resolve_region(region)

  # 5. Build Request
  request <- build_request(
    model = model, variable = variable, scenario = scenario,
    start_year = time$start_year, end_year = time$end_year,
    months = months, region = region_parsed,
    temporal_resolution = temporal_resolution
  )

  # 6. Download
  output_path <- load_cds_data(request = request, output_file = output_file)

  return(list(request = request, file = output_path))
}


