#' Read a CMIP6 NetCDF File into a Data Frame
#'
#' @description
#' Reads a CMIP6 NetCDF file and returns a tidy data frame with columns for
#' longitude, latitude, time, value, scenario, and model. Model name and
#' scenario are automatically extracted from the file's global attributes.
#' Unit conversion is applied automatically for known variables.
#'
#' @param file Character. Path to a NetCDF (.nc) file.
#' @param convert_units Logical. Whether to convert units automatically.
#'   Temperature is converted from Kelvin to °C, precipitation from
#'   \code{kg m-2 s-1} to \code{mm/day} or \code{mm/month}. Default is \code{TRUE}.
#' @param scenario Character. Optional scenario label to override the one
#'   detected from the file. If \code{NULL} (default), the scenario is read
#'   from the file's \code{experiment_id} attribute.
#' @param temporal_resolution Character. Deprecated - temporal resolution is
#'   now detected automatically from the file. Default is \code{"monthly"}.
#'
#' @return A data frame with columns \code{lon}, \code{lat}, \code{time},
#'   \code{value}, \code{scenario}, and \code{model}. The following attributes
#'   are attached:
#'   \describe{
#'     \item{variable}{The detected climate variable name (e.g. \code{"tas"}).}
#'     \item{units}{The unit of the values after conversion (e.g. \code{"°C"}).}
#'     \item{temporal_resolution}{Either \code{"monthly"} or \code{"daily"}.}
#'   }
#' @export
#'
#' @examples
#' \dontrun{
#' df <- read_cmip6("tasmax_Amon_MPI-ESM1-2-LR_ssp585_r1i1p1f1_gn_20150116-21001216.nc")
#' head(df)
#' }


read_cmip6 <- function(file, convert_units = TRUE, scenario = NULL, temporal_resolution = "monthly") {
  nc <- ncdf4::nc_open(file)
  on.exit(ncdf4::nc_close(nc))
  # 1. Read dimensions
  lon  <- ncdf4::ncvar_get(nc, "lon")
  lat  <- ncdf4::ncvar_get(nc, "lat")
  time <- ncdf4::ncvar_get(nc, "time")
  # Extract model name
  model_name <- ncdf4::ncatt_get(nc, 0, "source_id")$value
  if (is.null(model_name) || model_name == "") {
    model_name <- "unknown"
  }
  # Extract scenario automatically
  scenario_raw <- ncdf4::ncatt_get(nc, 0, "experiment_id")$value
  if (is.null(scenario_raw) || scenario_raw == "") {
    scenario_raw <- "unknown"
  }
  scenario_label <- variable_meta(scenario = scenario_raw)
  # 2. Convert time to dates
  time_units <- ncdf4::ncatt_get(nc, "time", "units")$value
  origin <- sub("days since ", "", time_units)
  dates  <- as.Date(time, origin = origin)
  # 3. Auto-detect temporal resolution
  time_step <- mean(diff(head(time, 13)))
  temporal_resolution <- if (time_step > 20) "monthly" else "daily"
  # 4. Auto-detect variable name
  all_vars  <- names(nc$var)
  skip_vars <- c("time_bnds", "lat_bnds", "lon_bnds", "height", "time_bounds", "axis_nbounds")
  var_name  <- all_vars[!all_vars %in% skip_vars &
                          sapply(all_vars, function(v) length(nc$var[[v]]$dim) == 3)][1]
  # 5. Read data array
  data_array <- ncdf4::ncvar_get(nc, var_name)
  # 6. Replace fill value with NA
  fill_value <- ncdf4::ncatt_get(nc, var_name, "_FillValue")$value
  data_array[abs(data_array - fill_value) < 1e14] <- NA
  # 7. Read units attribute
  units <- ncdf4::ncatt_get(nc, var_name, "units")$value
  # 8. Convert units
  if (convert_units) {
    temp_vars <- c("tas", "tasmax", "tasmin")
    if (var_name %in% temp_vars) {
      if (units == "K") {
        data_array <- data_array - 273.15
        units <- "\u00b0C"
      } else if (units == "F") {
        data_array <- (data_array - 32) * 5/9
        units <- "\u00b0C"
      }
    }
    if (var_name == "pr") {
      if (temporal_resolution == "daily") {
        data_array <- data_array * 86400
        units <- "mm/day"
      } else if (temporal_resolution == "monthly") {
        data_array <- data_array * 86400 * 30.44
        units <- "mm/month"
      }
    }
  }
  # 9. Convert to data.frame
  if (length(dim(data_array)) == 1) {
    df <- data.frame(
      lon      = lon,
      lat      = lat,
      time     = dates,
      value    = as.numeric(data_array),
      scenario = scenario_label,
      model    = model_name
    )
  } else {
    dimnames(data_array) <- list(lon = lon, lat = lat, time = as.character(dates))
    df <- as.data.frame.table(data_array, responseName = "value") |>
      dplyr::mutate(
        lon      = as.numeric(as.character(lon)),
        lat      = as.numeric(as.character(lat)),
        time     = as.Date(time),
        value    = as.numeric(value),
        scenario = scenario_label,
        model    = model_name
      )
  }
  # 10. Attach metadata
  attr(df, "variable")             <- var_name
  attr(df, "units")                <- units
  attr(df, "temporal_resolution")  <- temporal_resolution
  return(df)
}



# read_cmip6 <- function(file, convert_units = TRUE, scenario = NULL) {
#
#   nc <- ncdf4::nc_open(file)
#   on.exit(ncdf4::nc_close(nc))  # Datei wird immer geschlossen, auch bei Fehler
#
#   # 1. Read dimensions
#   lon  <- ncdf4::ncvar_get(nc, "lon")
#   lat  <- ncdf4::ncvar_get(nc, "lat")
#   time <- ncdf4::ncvar_get(nc, "time")
#
#   # 2. Convert time to dates
#   time_units <- ncdf4::ncatt_get(nc, "time", "units")$value
#   # Format: "days since YYYY-MM-DD"
#   origin <- sub("days since ", "", time_units)
#   dates  <- as.Date(time, origin = origin)
#
#   # 3. Auto-detect variable name
#   all_vars   <- names(nc$var)
#   skip_vars  <- c("time_bnds", "lat_bnds", "lon_bnds", "height", "time_bounds", "axis_nbounds")
#   var_name   <- all_vars[!all_vars %in% skip_vars &
#                            sapply(all_vars, function(v) length(nc$var[[v]]$dim) == 3)][1]
#
#   # 4. Read data array
#   data_array <- ncdf4::ncvar_get(nc, var_name)
#
#   # 5. Replace fill value with NA
#   fill_value <- ncdf4::ncatt_get(nc, var_name, "_FillValue")$value
#   data_array[abs(data_array - fill_value) < 1e14] <- NA
#
#   # 6. Read units attribute
#   units <- ncdf4::ncatt_get(nc, var_name, "units")$value
#
#   # 7. Convert °F to °C
#   if (convert_units) {
#     temp_vars <- c("tas", "tasmax", "tasmin")
#     if (var_name %in% temp_vars) {
#       if (units == "K") {
#         data_array <- data_array - 273.15
#         units <- "\u00b0C"
#       } else if (units == "F") {
#         data_array <- (data_array - 32) * 5/9
#         units <- "\u00b0C"
#       }
#     }
#   }
#
#   # 8. Extract model name from filename
#   model_name <- tryCatch({
#     parts <- strsplit(basename(file), "_")[[1]]
#     if (length(parts) >= 3) parts[3] else "unknown"
#   }, error = function(e) "unknown")
#
#   # 9. Convert array to long data.frame
#   dimnames(data_array) <- list(lon = lon, lat = lat, time = as.character(dates))
#
#   df <- as.data.frame.table(data_array, responseName = "value") |>
#     dplyr::mutate(
#       lon   = as.numeric(as.character(lon)),
#       lat   = as.numeric(as.character(lat)),
#       time  = as.Date(time),
#       value = as.numeric(value),
#       scenario = variable_meta(scenario = if(!is.null(scenario)) scenario else "unknown"),
#       model = model_name
#     )
#
#   # 10. Attach metadata as attributes
#   attr(df, "variable") <- var_name
#   attr(df, "units")    <- units
#
#   return(df)
# }

