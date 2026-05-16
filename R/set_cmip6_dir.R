#' Set the CMIP6 Data Directory
#'
#' @description
#' Sets the directory where downloaded CMIP6 NetCDF files are stored.
#' Creates the directory if it does not exist. This must be called once
#' before using \code{get_cmip6_data()}.
#'
#' @param path Character. Path to the directory where CMIP6 data should be saved.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect of
#'   setting the \code{cmip6r.data_dir} option.
#' @export
#'
#' @examples
#' \dontrun{
#' set_cmip6_dir("~/cmip6_data")
#' }

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
