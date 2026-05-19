#' Save a CMIP6 Plot
#'
#' Saves a ggplot object to the CMIP6 data directory set by \code{set_cmip6_dir()}.
#'
#' @param plot A ggplot object to save.
#' @param filename Character. Filename including extension (e.g. \code{"my_plot.png"}).
#' @param width Numeric. Plot width in inches. Default is \code{8}.
#' @param height Numeric. Plot height in inches. Default is \code{5}.
#' @param dpi Numeric. Resolution in DPI. Default is \code{300}.
#'
#' @return Invisibly returns the path to the saved file.
#' @export
#'
#' @examples
#' \dontrun{
#' save_plot(p, "bavaria_tasmax.png")
#' }

save_plot <- function(plot, filename, width = 8, height = 5, dpi = 300) {
  path <- file.path(get_cmip6_dir(), filename)
  ggplot2::ggsave(path, plot = plot, width = width, height = height, dpi = dpi)
  message("Plot saved to: ", path)
  invisible(path)
}

