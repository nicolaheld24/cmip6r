#' ggplot2 Theme for cmip6r Plots
#'
#' @description
#' A clean minimal ggplot2 theme used as default for all cmip6r plots.
#' Automatically loads the Lora Google Font via `showtext`.
#'
#' @param base_size Numeric. Base font size. Default: `13`.
#' @param base_family Character. Font family. Default: `"lora"`.
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_cmip6()
#' }
#'
#' @export

theme_cmip6 <- function(base_size = 13, base_family = "lora") {

  # Load font if not already loaded
  if (!("lora" %in% sysfonts::font_families())) {
    sysfonts::font_add_google("Lora", "lora")
  }
  showtext::showtext_auto()

  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.title           = ggplot2::element_text(face = "bold", hjust = 0.5),
      plot.title.position  = "plot",
      panel.grid.minor     = ggplot2::element_blank(),
      legend.position      = "bottom",
      legend.justification = "center",
      legend.title         = ggplot2::element_blank(),  # Titel weg, sieht sauberer aus
      legend.spacing.x     = ggplot2::unit(0.3, "cm")
    )
}

