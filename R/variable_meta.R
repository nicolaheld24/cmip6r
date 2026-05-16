#' Retrieve Metadata for CMIP6 Variables and Scenarios
#'
#' @description
#' Returns display metadata (label, color, unit) for a given climate variable,
#' or a formatted label for a given scenario. Used internally by
#' \code{plot_timeseries()} for axis labels and color scales.
#'
#' @param var_name Character or \code{NULL}. Climate variable short name
#'   (e.g. \code{"tas"}, \code{"pr"}). If not \code{NULL}, variable metadata
#'   is returned.
#' @param scenario Character or \code{NULL}. Scenario identifier
#'   (e.g. \code{"ssp585"}, \code{"historical"}). If not \code{NULL}, a
#'   formatted scenario label is returned.
#'
#' @return If \code{var_name} is provided, a named list with elements
#'   \code{label}, \code{color}, and \code{unit}. If \code{scenario} is
#'   provided, a character string with the formatted scenario label
#'   (e.g. \code{"SSP5-8.5"}).
#' @keywords internal

variable_meta <- function(var_name = NULL, scenario = NULL) {
  meta <- list(
    tas     = list(label = "Near-Surface Air Temperature",   color = "#2166ac", unit = "\u00b0C"),
    tasmin  = list(label = "Minimum Temperature",      color = "#4dac26", unit = "\u00b0C"),
    tasmax  = list(label = "Maximum Temperature",      color = "#d73027", unit = "\u00b0C"),
    pr      = list(label = "Precipitation Sum",                  color = "#1a9850", unit = "mm/month")
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
