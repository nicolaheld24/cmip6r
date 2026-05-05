#' Get Metadata for a CMIP6 Variable or Scenario
#'
#' @param var_name Character or NULL. Variable name (e.g. `"tas"`, `"pr"`).
#' @param scenario Character or NULL. Scenario key (e.g. `"ssp245"`).
#'
#' @return A list with `label`, `color`, and `unit` for variables,
#'   or a formatted scenario label string.
#' @keywords internal

variable_meta <- function(var_name = NULL, scenario = NULL) {
  meta <- list(
    tas     = list(label = "Near-Surface Air Temperature",   color = "#2166ac", unit = "\u00b0C"),
    tasmin  = list(label = "Daily Minimum Temperature",      color = "#4dac26", unit = "\u00b0C"),
    tasmax  = list(label = "Daily Maximum Temperature",      color = "#d73027", unit = "\u00b0C"),
    pr      = list(label = "Precipitation",                  color = "#1a9850", unit = "mm/day"),
    huss    = list(label = "Near-Surface Specific Humidity", color = "#8073ac", unit = "kg/kg"),
    psl     = list(label = "Sea Level Pressure",             color = "#e08214", unit = "hPa"),
    sfcWind = list(label = "Near-Surface Wind Speed",        color = "#542788", unit = "m/s")
  )

  # Scenario labels
  scenario_labels <- c(
    "ssp126"     = "SSP1-2.6",
    "ssp245"     = "SSP2-4.5",
    "ssp370"     = "SSP3-7.0",
    "ssp585"     = "SSP5-8.5",
    "historical" = "Historical",
    "unknown"    = "Unknown"
  )

  # Return variable metadata
  if (!is.null(var_name)) {
    if (!var_name %in% names(meta)) {
      return(list(label = var_name, color = "#555555", unit = ""))
    }
    return(meta[[var_name]])
  }

  # Return scenario label
  if (!is.null(scenario)) {
    if (!scenario %in% names(scenario_labels)) {
      return(scenario)
    }
    return(scenario_labels[[scenario]])
  }

  stop("Please provide either var_name or scenario")
}
