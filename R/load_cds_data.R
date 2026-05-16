#' Download Data from the CDS API
#'
#' Downloads CMIP6 data from the Copernicus Climate Data Store using the
#' Python \code{cdsapi} package via \code{reticulate}. Automatically installs
#' \code{cdsapi} if not available. The downloaded ZIP archive is extracted
#' and the resulting NetCDF file is returned.
#'
#' @param request List. A CDS-formatted request, output of \code{build_request()}.
#' @param output_file Character. Path to save the downloaded \code{.nc} file.
#'
#' @return Character. Path to the downloaded and extracted NetCDF file.
#' @keywords internal

load_cds_data <- function(request, output_file) {
  # Check .cdsapirc first
  cdsapirc <- file.path(Sys.getenv("HOME"), ".cdsapirc")
  if (!file.exists(cdsapirc)) {
    stop(
      "No .cdsapirc file found at: ", cdsapirc, "\n",
      "Please create it with your CDS API key.\n",
      "See: https://cds.climate.copernicus.eu/how-to-api"
    )
  }
  # Check Python package
  if (!reticulate::py_module_available("cdsapi")) {
    message("Python package 'cdsapi' not found. Installing...")
    reticulate::py_install("cdsapi")
    message("'cdsapi' installed successfully.")
  }
  cds_client <- reticulate::import("cdsapi")$Client()
  message("Downloading CMIP6 data ...")
  message("Model:    ", request$model)
  message("Variable: ", request$variable)
  message("Scenario: ", request$experiment)
  # Download as zip
  zip_file <- paste0(tools::file_path_sans_ext(output_file), ".zip")
  tryCatch({                                            # ← NEU
    cds_client$retrieve(
      "projections-cmip6",
      request,
      zip_file
    )
  }, error = function(e) {
    stop("CDS API error: Model '", request$model, "' may not be available for scenario '",
         request$experiment, "' and variable '", request$variable,
         "'.\nOriginal error: ", e$message)
  })
  # Unzip and get .nc file
  output_dir <- dirname(output_file)
  utils::unzip(zip_file, exdir = output_dir)
  # Find the correct .nc file based on temporal resolution
  pattern  <- if (request$temporal_resolution == "daily") "_day_" else "_Amon_"
  nc_files <- list.files(output_dir, pattern = pattern, full.names = TRUE)
  if (length(nc_files) == 0) {
    nc_files <- list.files(output_dir, pattern = "\\.nc$", full.names = TRUE)
  }
  if (length(nc_files) == 0) {
    stop("No .nc file found after extracting the downloaded archive.")
  }
  nc_file <- nc_files[which.max(file.info(nc_files)$mtime)]
  # Clean up zip
  file.remove(zip_file)
  message("Downloaded and extracted: ", nc_file)
  return(nc_file)
}
