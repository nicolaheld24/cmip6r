#' Light Theme for CMIP6 Plots
#'
#' @description
#' An alternative light-styled ggplot2 theme with a warm background,
#' markdown-enabled titles and a clean minimal look.
#' Requires the `ggtext` package for markdown title rendering.
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
#' p + theme_cmip6_light()
#' }

theme_cmip6_light <- function(base_size = 10, base_family = "lora", preview = FALSE) {
  if (!("lora" %in% sysfonts::font_families())) {
    sysfonts::font_add_google("Lora", "lora")
  }
  showtext::showtext_auto(enable = TRUE)
  if (preview) {
    actual_size <- base_size * 0.9
    showtext::showtext_opts(dpi = 96)
  } else {
    actual_size <- base_size
    showtext::showtext_opts(dpi = 300)
  }
  bg      <- "#F4F5F1"
  txt_col <- "#555555"
  ggplot2::theme_minimal(base_size = actual_size, base_family = base_family) +
    ggplot2::theme(
      plot.title           = ggplot2::element_text(
        face = "bold", hjust = 0.5, size = actual_size * 1.5,
        lineheight = 1.2, color = "#4a4a4a"),
      plot.title.position  = "plot",
      plot.background      = ggplot2::element_rect(color = bg, fill = bg),
      panel.background     = ggplot2::element_rect(color = bg, fill = bg),
      panel.grid.minor     = ggplot2::element_blank(),
      panel.grid.major     = ggplot2::element_line(color = "white"), #E0E0D8
      axis.text            = ggplot2::element_text(size = actual_size * 0.9, color = txt_col),
      axis.title           = ggplot2::element_text(size = actual_size * 1.0, color = txt_col),
      legend.position      = "bottom",
      legend.justification = "center",
      legend.title         = ggplot2::element_blank(),
      legend.text          = ggplot2::element_text(size = actual_size * 1.0, color = "#4a4a4a"),
      legend.spacing.x     = ggplot2::unit(0.3, "cm"),
      plot.margin          = ggplot2::margin(10, 10, 10, 10)
    )
}
