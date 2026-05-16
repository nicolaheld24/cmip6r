#' Default Theme for CMIP6 Plots
#'
#' @description
#' A minimal ggplot2 theme for CMIP6 climate plots using the Lora Google Font.
#' Optimised for high-resolution export at 300 DPI. Use \code{preview = TRUE}
#' for a better in-session preview in RStudio.
#'
#' @param base_size Numeric. Base font size in points. Default is \code{10}.
#' @param base_family Character. Font family. Default is \code{"lora"}.
#' @param preview Logical. If \code{TRUE}, reduces font size and sets DPI to
#'   96 for better display in the RStudio plot pane. If \code{FALSE} (default),
#'   uses full size and 300 DPI for export.
#'
#' @return A \code{ggplot2} theme object.
#' @export
#'
#' @examples
#' \dontrun{
#' p <- plot_timeseries(df_ssp126, df_ssp585)
#' p + theme_cmip6()
#' }

theme_cmip6 <- function(base_size = 10, base_family = "lora", preview = FALSE) {
  if (!("lora" %in% sysfonts::font_families())) {
    sysfonts::font_add_google("Lora", "lora")
  }
  showtext::showtext_auto()

  if (preview) {
    actual_size <- base_size * 0.9
    showtext::showtext_opts(dpi = 96)
  } else {
    actual_size <- base_size
    showtext::showtext_opts(dpi = 300)
  }

  ggplot2::theme_minimal(base_size = actual_size, base_family = base_family) +
    ggplot2::theme(
      plot.title           = ggplot2::element_text(
        face = "bold", hjust = 0.5, size = actual_size * 1.5,
        lineheight = 1.2),
      plot.title.position  = "plot",
      panel.grid.minor     = ggplot2::element_blank(),
      axis.text            = ggplot2::element_text(size = actual_size * 0.9),
      axis.title           = ggplot2::element_text(size = actual_size * 1.0),
      legend.text          = ggplot2::element_text(size = actual_size * 1.0),
      legend.position      = "bottom",
      legend.justification = "center",
      legend.title         = ggplot2::element_blank(),
      legend.spacing.x     = ggplot2::unit(0.3, "cm")
    )
}









