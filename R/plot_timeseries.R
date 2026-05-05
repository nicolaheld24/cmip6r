#' Plot CMIP6 Climate Time Series
#'
#' @description
#' Creates a time series plot of CMIP6 climate data for one or more scenarios.
#' Automatically aggregates daily data to monthly or annual means depending on
#' the length of the time series.
#'
#' @param ... One or more data frames created by `read_cmip6()`. All data frames
#'   must contain the same climate variable.
#' @param aggregation Character. Spatial aggregation function applied across all
#'   grid points per time step. One of `"mean"` (default), `"max"`, `"min"`, `"median"`.
#' @param title Character. Plot title. If `NULL` (default), a title is generated
#'   automatically from the variable name and aggregation method.
#' @param show_smooth Logical. If `TRUE` (default), adds a linear trend line
#'   for each scenario.
#' @param time_aggregation Character. Temporal aggregation level. One of `"auto"`
#'   (default), `"annual"`, `"monthly"`, `"none"`. When `"auto"`, the aggregation
#'   is chosen based on the length of the time series: annual for > 20 years,
#'   monthly for 3-20 years, none for < 3 years.
#' @param show_ci Logical. If `TRUE` (default), adds a 95% confidence band around
#'   the trend line.
#' @param theme Character. Plot theme. Either `"default"` (dark) or `"light"`.
#'
#' @return A `ggplot2` object.
#'
#' @examples
#' \dontrun{
#' df_ssp245 <- read_cmip6("tas_ssp245.nc", scenario = "ssp245")
#' df_ssp585 <- read_cmip6("tas_ssp585.nc", scenario = "ssp585")
#'
#' # Plot two scenarios
#' plot_timeseries(df_ssp245, df_ssp585,
#'                 title = "Near-Surface Air Temperature – Bavaria")
#'
#' # Without trend line
#' plot_timeseries(df_ssp245, show_smooth = FALSE)
#'
#' # Force annual aggregation
#' plot_timeseries(df_ssp245, df_ssp585, time_aggregation = "annual")
#' }
#'
#' @importFrom stats median
#' @export

plot_timeseries <- function(..., aggregation = "mean", title = NULL,
                            show_smooth = TRUE,
                            time_aggregation = "auto",
                            show_ci = TRUE,
                            theme = "default") {

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

  # 4. Aggregate spatially per time step and scenario
  combined <- dplyr::bind_rows(dfs) |>
    dplyr::group_by(time, scenario) |>
    dplyr::summarise(value = agg_fn(value), .groups = "drop")

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
      dplyr::summarise(value = mean(value, na.rm = TRUE), .groups = "drop") |>
      dplyr::mutate(time = as.Date(paste0(year, "-07-01"))) |>
      dplyr::select(-year)

  } else if (time_aggregation == "monthly") {
    combined <- combined |>
      dplyr::mutate(month = format(time, "%Y-%m")) |>
      dplyr::group_by(month, scenario) |>
      dplyr::summarise(value = mean(value, na.rm = TRUE), .groups = "drop") |>
      dplyr::mutate(time = as.Date(paste0(month, "-15"))) |>
      dplyr::select(-month)
  }

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
    stats::setNames(rep("dashed",    length(present_scenarios)), paste0(present_scenarios, " (trend)"))
  )

  # 7. Plot title
  if (is.null(title)) {
    title <- paste0(meta$label, " \u2013 ", aggregation, " over region")
  }

  # 8. Base plot
  p <- ggplot2::ggplot(combined, ggplot2::aes(x = time, y = value)) +
    ggplot2::geom_line(
      ggplot2::aes(color = scenario, linetype = scenario),
      linewidth = 0.7,
      alpha = 0.6
    )

  # 9. Optionally add trend line
  if (show_smooth) {
    p <- p +
      ggplot2::geom_smooth(
        ggplot2::aes(
          color    = paste0(scenario, " (trend)"),
          linetype = paste0(scenario, " (trend)"),
          fill     = scenario
        ),
        method    = "lm",
        se        = show_ci,
        linewidth = 0.8,
        alpha     = 0.15,
        show.legend = TRUE
      ) +
      ggplot2::scale_fill_manual(
        values = colors,
        guide  = "none"
      )
  }

  # 10. Labels and theme
  p <- p +
    ggplot2::scale_color_manual(values = all_colors, name = "Scenario") +
    ggplot2::scale_linetype_manual(values = all_linetypes, name = "Scenario") +
    ggplot2::labs(
      title = title,
      x     = "Year",
      y     = paste0(meta$label, " (", units, ")")
    ) +
    if (theme == "light") theme_cmip6_light() else theme_cmip6()

  return(p)
}





