#' Download Data from the CDS API
#'
#' @param request List. A CDS-formatted request, output of `build_request()`.
#' @param output_file Character. Path to save the downloaded `.nc` file.
#'
#' @return Character. Path to the downloaded file.
#' @keywords internal
#' load_cds_data.R – ZIP entpacken nach dem Download

load_cds_data <- function(request, output_file) {

  if (!reticulate::py_module_available("cdsapi")) {
    message("Python package 'cdsapi' not found. Installing...")
    reticulate::py_install("cdsapi")
    message("'cdsapi' installed successfully.")
  }

  c <- reticulate::import("cdsapi")$Client()

  message("Downloading CMIP6 data ...")
  message("Model:    ", request$model)
  message("Variable: ", request$variable)
  message("Scenario: ", request$experiment)

  # Download as zip
  zip_file <- paste0(tools::file_path_sans_ext(output_file), ".zip")

  c$retrieve(
    "projections-cmip6",
    request,
    zip_file
  )

  # Unzip and get .nc file
  output_dir <- dirname(output_file)
  utils::unzip(zip_file, exdir = output_dir)

  # Find the correct .nc file based on temporal resolution
  pattern  <- if (request$temporal_resolution == "daily") "_day_" else "_Amon_"
  nc_files <- list.files(output_dir, pattern = pattern, full.names = TRUE)

  if (length(nc_files) == 0) {
    nc_files <- list.files(output_dir, pattern = "\\.nc$", full.names = TRUE)
  }

  nc_file <- nc_files[which.max(file.info(nc_files)$mtime)]

  # Clean up zip
  file.remove(zip_file)

  message("Downloaded and extracted: ", nc_file)
  return(nc_file)
}
