# R/cmip6_dir.R

#' Set the directory for CMIP6 data downloads
#'
#' @param path Character. Full path to the directory where downloaded `.nc`
#'   files will be saved. The directory will be created if it does not exist.
#'
#' @examples
#' \dontrun{
#' set_cmip6_dir("C:/Users/nicol/Desktop/EAGLE/data")
#' }
#'
#' @export

set_cmip6_dir <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
    message("Created directory: ", path)
  }
  options(cmip6r.data_dir = path)
  message("CMIP6 data directory set to: ", path)
}

#' Get the current CMIP6 data directory
#'
#' @return Character. Path to the current data directory.
#' @keywords internal

get_cmip6_dir <- function() {
  path <- getOption("cmip6r.data_dir")
  if (is.null(path)) {
    stop("No CMIP6 data directory set. Please run set_cmip6_dir() first.")
  }
  path
}
