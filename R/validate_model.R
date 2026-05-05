#' Validate CMIP6 Model Name
#'
#' @param model Character. Model name to validate.
#'
#' @return Invisibly returns `TRUE` if valid, otherwise throws an error.
#' @keywords internal

validate_model <- function(model) {
  valid_models <- c(
    "ACCESS-CM2", "AWI-CM-1-1-MR", "BCC-CSM2-MR",
    "CAMS-CSM1-0", "CanESM5", "CESM2", "CMCC-ESM2",
    "CNRM-CM6-1", "CNRM-CM6-1-HR", "CNRM-ESM2-1",
    "EC-Earth3-Veg-LR", "FGOALS-g3", "GFDL-ESM4",
    "HadGEM3-GC31-LL", "HadGEM3-GC31-MM", "IITM-ESM",
    "INM-CM4-8", "INM-CM5-0", "IPSL-CM5A2-INCA",
    "IPSL-CM6A-LR", "KACE-1-0-G", "KIOST-ESM",
    "MIROC6", "MIROC-ES2L", "MPI-ESM1-2-LR",
    "MRI-ESM2-0", "NorESM2-LM", "NorESM2-MM",
    "UKESM1-0-LL"
  )

  if (!model %in% valid_models) {
    stop(
      "Invalid model: '", model, "'\nAvailable models:\n",
      paste(valid_models, collapse = ", ")
    )
  }

  invisible(TRUE)
}
