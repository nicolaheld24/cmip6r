#' Display CMIP6 Reference Information
#'
#' @description
#' Prints available variables, scenarios, models, temporal resolutions,
#' and a usage example for \code{get_cmip6_data()}.
#'
#' @param what Character. Which information to display. One of:
#'   \describe{
#'     \item{\code{"all"}}{Display everything (default).}
#'     \item{\code{"variables"}}{Show available climate variables.}
#'     \item{\code{"scenarios"}}{Show available emissions scenarios.}
#'     \item{\code{"models"}}{Show available CMIP6 models.}
#'     \item{\code{"temporal_resolution"}}{Show available temporal resolutions.}
#'     \item{\code{"example"}}{Show a usage example.}
#'   }
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect of
#'   printing information to the console.
#' @export
#'
#' @examples
#' cmip6_info()
#' cmip6_info("variables")
#' cmip6_info("models")

cmip6_info <- function(what = "all") {

  if (what %in% c("all", "variables")) {
    cat("=== Variables (short name -> API name) ===\n")
    cat("  tas      -> near_surface_air_temperature\n")
    cat("  tasmax   -> daily_maximum_near_surface_air_temperature\n")
    cat("  tasmin   -> daily_minimum_near_surface_air_temperature\n")
    cat("  pr       -> precipitation\n")
    cat("  hurs     -> near_surface_relative_humidity\n")
    cat("  huss     -> near_surface_specific_humidity\n")
    cat("  sfcWind  -> near_surface_wind_speed\n")
    cat("  uas      -> eastward_near_surface_wind\n")
    cat("  vas      -> northward_near_surface_wind\n")
    cat("  psl      -> sea_level_pressure\n")
    cat("  rsds     -> surface_downwelling_shortwave_radiation\n")
    cat("  rlds     -> surface_downwelling_longwave_radiation\n")
    cat("  mrsos    -> moisture_in_upper_portion_of_soil_column\n")
    cat("  mrro     -> total_runoff\n")
    cat("  clt      -> total_cloud_cover_percentage\n")
    cat("  evspsbl  -> evaporation_including_sublimation_and_transpiration\n\n")
  }

  if (what %in% c("all", "scenarios")) {
    cat("=== Scenarios ===\n")
    cat("  historical  -> Historical (1850-2014)\n")
    cat("  ssp119      -> SSP1-1.9 - Very low emissions\n")
    cat("  ssp126      -> SSP1-2.6 - Low emissions\n")
    cat("  ssp434      -> SSP4-3.4 - Gap-filling scenario\n")
    cat("  ssp534os    -> SSP5-3.4OS - Overshoot scenario\n")
    cat("  ssp245      -> SSP2-4.5 - Intermediate emissions\n")
    cat("  ssp460      -> SSP4-6.0 - Medium-high emissions\n")
    cat("  ssp370      -> SSP3-7.0 - High emissions\n")
    cat("  ssp585      -> SSP5-8.5 - Very high emissions\n\n")
  }

  if (what %in% c("all", "models")) {
    cat("=== Models ===\n")
    cat("  ACCESS-CM2, ACCESS-ESM1-5, AWI-CM-1-1-MR, AWI-ESM-1-1-LR,\n")
    cat("  BCC-CSM2-MR, BCC-ESM1, CAMS-CSM1-0, CanESM5, CanESM5-CanOE,\n")
    cat("  CESM2, CESM2-FV2, CESM2-WACCM, CESM2-WACCM-FV2, CIESM,\n")
    cat("  CMCC-CM2-HR4, CMCC-CM2-SR5, CMCC-ESM2, CNRM-CM6-1,\n")
    cat("  CNRM-CM6-1-HR, CNRM-ESM2-1, E3SM-1-0, E3SM-1-1,\n")
    cat("  E3SM-1-1-ECA, EC-Earth3, EC-Earth3-AerChem, EC-Earth3-CC,\n")
    cat("  EC-Earth3-Veg, EC-Earth3-Veg-LR, FGOALS-f3-L, FGOALS-g3,\n")
    cat("  FIO-ESM-2-0, GFDL-ESM4, GISS-E2-1-G, GISS-E2-1-H,\n")
    cat("  HadGEM3-GC31-LL, HadGEM3-GC31-MM, IITM-ESM, INM-CM4-8,\n")
    cat("  INM-CM5-0, IPSL-CM5A2-INCA, IPSL-CM6A-LR, KACE-1-0-G,\n")
    cat("  KIOST-ESM, MCM-UA-1-0, MIROC6, MIROC-ES2H, MIROC-ES2L,\n")
    cat("  MPI-ESM1-2-HAM, MPI-ESM1-2-HR, MPI-ESM1-2-LR, MRI-ESM2-0,\n")
    cat("  NESM3, NorCPM1, NorESM2-LM, NorESM2-MM, SAM0-UNICON,\n")
    cat("  TaiESM1, UKESM1-0-LL\n\n")
  }

  if (what %in% c("all", "temporal_resolution")) {
    cat("=== Temporal Resolution ===\n")
    cat("  monthly  -> Monthly data\n")
    cat("  daily    -> Daily data\n\n")
  }

  if (what %in% c("all", "example")) {
    cat("=== Example ===\n")
    cat('get_cmip6_data(\n')
    cat('  variable   = "tas",\n')
    cat('  model      = "MPI-ESM1-2-LR",\n')
    cat('  scenario   = "ssp585",\n')
    cat('  start_year = 2015,\n')
    cat('  end_year   = 2100,\n')
    cat('  months     = 1:12,\n')
    cat('  region     = c(9, 14, 47, 51),\n')
    cat('  temporal_resolution = "monthly"\n')
    cat(')\n')
  }
}
