#' Light ggplot2 Theme for cmip6r Plots
#'
#' @description
#' An alternative light-styled ggplot2 theme with a warm background,
#' markdown-enabled titles and a clean minimal look.
#' Requires the `ggtext` package for markdown title rendering.
#'
#' @param base_size Numeric. Base font size. Default: `11`.
#' @param base_family Character. Font family. Default: `"lora"`.
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_cmip6_light()
#' }
#'
#' @export


theme_cmip6_light <- function(base_size = 11, base_family = "lora") {

  # Load font if not already loaded
  if (!("lora" %in% sysfonts::font_families())) {
    sysfonts::font_add_google("Lora", "lora")
  }
  showtext::showtext_auto(enable = TRUE)

  bg      <- "#F4F5F1"
  txt_col <- "black"

  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # Title & subtitle
      plot.title            = ggtext::element_markdown(
        hjust = 0.5, size = 16, color = txt_col,
        lineheight = 0.8, face = "bold",
        margin = ggplot2::margin(20, 0, 30, 0)),
      plot.subtitle         = ggtext::element_markdown(
        hjust = 0.5, size = 11, color = txt_col,
        lineheight = 1,
        margin = ggplot2::margin(10, 0, 30, 0)),
      plot.caption          = ggtext::element_markdown(
        hjust = 0.5, size = 8, color = txt_col,
        lineheight = 1.2,
        margin = ggplot2::margin(30, 0, 0, 0)),
      plot.caption.position = "plot",
      # Background
      plot.background       = ggplot2::element_rect(color = bg, fill = bg),
      panel.background      = ggplot2::element_rect(color = bg, fill = bg),
      # Axes
      axis.title            = ggplot2::element_text(size = 9, color = txt_col),
      axis.text             = ggplot2::element_text(size = 8, color = txt_col),
      # Grid
      panel.grid.minor      = ggplot2::element_blank(),
      panel.grid.major      = ggplot2::element_line(color = "#E0E0D8"),
      # Legend
      legend.position       = "bottom",
      legend.title          = ggplot2::element_blank(),
      legend.text           = ggplot2::element_text(size = 9),
      # Margin
      plot.margin           = ggplot2::margin(10, 10, 10, 10)
    )
}
