#' Plot CMIP6 Climate Scenario Time Series
#'
#' @description
#' Creates a time series plot for one or more CMIP6 climate scenarios.
#' Supports automatic spatial and temporal aggregation, unit conversion,
#' and optional LOESS trend lines with confidence intervals.
#'
#' @param ... One or more data frames returned by \code{read_cmip6()}.
#'   All data frames must contain the same climate variable.
#' @param aggregation Character. Spatial aggregation method. One of
#'   \code{"mean"} (default), \code{"max"}, \code{"min"}, or \code{"median"}.
#' @param title Character. Plot title. If \code{NULL} (default), a title is
#'   generated automatically from the variable metadata.
#' @param show_smooth Logical. Whether to add a LOESS trend line. Default is \code{TRUE}.
#' @param time_aggregation Character. Temporal aggregation level. One of
#'   \code{"auto"} (default), \code{"annual"}, \code{"monthly"}, or \code{"none"}.
#'   \code{"auto"} selects annual aggregation for time series longer than 20 years.
#' @param show_ci Logical. Whether to show the confidence interval around the
#'   trend line. Default is \code{TRUE}.
#' @param theme Character. Plot theme. Either \code{"default"} or \code{"light"}.
#'
#' @return A \code{ggplot2} object.
#' @export
#'
#' @examples
#' \dontrun{
#' p <- plot_timeseries(
#'   df_historical, df_ssp126, df_ssp585,
#'   title = "Monthly Maximum Temperature\nBavaria (1980-2100)",
#'   theme = "light"
#' )
#' print(p)
#' }



plot_timeseries <- function(..., aggregation = "mean", title = NULL,
                            show_smooth = TRUE,
                            time_aggregation = "auto",
                            show_ci = TRUE,
                            theme = "default",
                            line_alpha = 0.4) {

  # 1. Collect all data.frames
  dfs <- list(...)

  # 2. Check if all data.frames have the same variable
  vars <- sapply(dfs, function(df) attr(df, "variable"))
  if (length(unique(vars)) > 1) {
    stop("All data.frames must contain the same variable. Found: ",
         paste(unique(vars), collapse = ", "))
  }

  var_name <- unique(vars)
  meta     <- variable_meta(var_name)
  units    <- attr(dfs[[1]], "units")

  # 3. Aggregation function
  agg_fn <- switch(aggregation,
                   "mean"   = function(x) mean(x, na.rm = TRUE),
                   "max"    = function(x) max(x, na.rm = TRUE),
                   "min"    = function(x) min(x, na.rm = TRUE),
                   "median" = function(x) median(x, na.rm = TRUE),
                   stop("Invalid aggregation. Choose: 'mean', 'max', 'min', 'median'")
  )
  # 4a. Aggregate spatially per time step and scenario
  combined <- dplyr::bind_rows(dfs) |>
    dplyr::group_by(time, scenario) |>
    dplyr::summarise(value = agg_fn(value), .groups = "drop") |>
    dplyr::arrange(scenario, time)

  # 4b. Auto time aggregation based on time range
  if (time_aggregation == "auto") {
    n_years <- as.numeric(difftime(max(combined$time),
                                   min(combined$time),
                                   units = "days")) / 365
    if (n_years > 20) {
      time_aggregation <- "annual"
    } else if (n_years > 2) {
      time_aggregation <- "monthly"
    } else {
      time_aggregation <- "none"
    }
  }

  if (time_aggregation == "annual") {
    combined <- combined |>
      dplyr::mutate(year = format(time, "%Y")) |>
      dplyr::group_by(year, scenario) |>
      dplyr::summarise(
        value = if (var_name == "pr") sum(value, na.rm = TRUE) else mean(value, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::mutate(time = as.Date(paste0(year, "-07-01"))) |>
      dplyr::select(-year)

    if (var_name == "pr") units <- "mm/year"

  } else if (time_aggregation == "monthly") {
    combined <- combined |>
      dplyr::mutate(month = format(time, "%Y-%m")) |>
      dplyr::group_by(month, scenario) |>
      dplyr::summarise(value = mean(value, na.rm = TRUE), .groups = "drop") |>
      dplyr::mutate(time = as.Date(paste0(month, "-15"))) |>
      dplyr::select(-month)
  }

  trend_data <- combined |>
    dplyr::mutate(
      year = format(time, "%Y"),
      time = as.Date(paste0(year, "-07-01"))
    ) |>
    dplyr::select(-year)

  # 5. Color palettes
  scenario_colors <- c(
    "SSP1-2.6"   = "#feda75",
    "SSP2-4.5"   = "#fa7e1e",
    "SSP3-7.0"   = "#ae0001",
    "SSP5-8.5"   = "#962fbf",
    "Historical" = "#4f5bd5",
    "Unknown"    = "#aaaaaa"
  )

  trend_colors <- c(
    "SSP1-2.6 (trend)"   = "#c9a800",
    "SSP2-4.5 (trend)"   = "#c45000",
    "SSP3-7.0 (trend)"   = "#6b0000",
    "SSP5-8.5 (trend)"   = "#5a0070",
    "Historical (trend)" = "#1f2a8a",
    "Unknown (trend)"    = "#555555"
  )

  present_scenarios <- unique(combined$scenario)
  colors   <- scenario_colors[present_scenarios]
  t_colors <- trend_colors[paste0(present_scenarios, " (trend)")]

  # 6. Combine all colors and linetypes into one scale
  all_colors <- c(colors, t_colors)
  all_linetypes <- c(
    stats::setNames(rep("solid", length(present_scenarios)), present_scenarios),
    stats::setNames(rep("solid", length(present_scenarios)), paste0(present_scenarios, " (trend)"))
  )

  # 7. Plot title
  if (is.null(title)) {
    title <- paste0(meta$label, " \u2013 ", aggregation, " over region")
  }

  # 8. Base plot
  p <- ggplot2::ggplot(combined, ggplot2::aes(x = time, y = value)) +
    ggplot2::geom_line(
      ggplot2::aes(color = scenario, linetype = scenario, group = scenario),
      linewidth = 0.7,
      alpha = line_alpha
    )

  # 9. Optionally add trend line
  if (show_smooth) {
    p <- p +
      ggplot2::geom_smooth(
        data = trend_data,
        ggplot2::aes(
          color    = paste0(scenario, " (trend)"),
          linetype = paste0(scenario, " (trend)"),
          fill     = scenario
        ),
        linetype  = "solid",
        span      = 0.75,
        method    = "loess",
        se        = show_ci,
        linewidth = 0.8,
        alpha     = 0.15,
        show.legend = TRUE
      )
  }

  # 10. Labels and theme
  p <- p +
    ggplot2::scale_color_manual(values = all_colors, name = "Scenario") +
    ggplot2::scale_linetype_manual(values = all_linetypes, name = "Scenario") +
    ggplot2::scale_fill_manual(values = colors, guide = "none") +
    ggplot2::guides(
      color    = ggplot2::guide_legend(override.aes = list(linetype = "solid", linewidth = 0.8)),
      linetype = "none",
      fill     = "none"
    ) +
    ggplot2::labs(
      title = title,
      x     = "Year",
      y     = paste0(meta$label, " (", units, ")")
    )

  p <- p + if (theme == "light") theme_cmip6_light() else theme_cmip6()

  return(p)
}









