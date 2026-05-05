#' Read CMIP6 NetCDF File into a Data Frame
#'
#' @description
#' Reads a CMIP6 NetCDF file and converts it into a tidy long-format data frame
#' with columns for longitude, latitude, time, value, and scenario.
#'
#' @param file Character. Path to the `.nc` file to read.
#' @param convert_units Logical. If `TRUE` (default), converts temperature variables
#'   (`tas`, `tasmax`, `tasmin`) from Kelvin or Fahrenheit to degrees Celsius.
#' @param scenario Character. Optional scenario label (e.g. `"ssp245"`). Used to
#'   identify the scenario in `plot_timeseries()`. Default: `NULL` (stored as `"unknown"`).
#'
#' @return A data frame with columns:
#' \describe{
#'   \item{lon}{Longitude in degrees east.}
#'   \item{lat}{Latitude in degrees north.}
#'   \item{time}{Date of the observation as `Date` object.}
#'   \item{value}{Climate variable value.}
#'   \item{scenario}{Scenario label.}
#' }
#' The data frame also carries two attributes:
#' \describe{
#'   \item{variable}{Name of the climate variable (e.g. `"tas"`).}
#'   \item{units}{Unit of the climate variable after conversion (e.g. `"°C"`).}
#' }
#'
#' @examples
#' \dontrun{
#' df <- read_cmip6("AWI-CM-1-1-MR_tas_ssp245.nc", scenario = "ssp245")
#' head(df)
#' }
#'
#' @export


read_cmip6 <- function(file, convert_units = TRUE, scenario = NULL) {

  nc <- ncdf4::nc_open(file)
  on.exit(ncdf4::nc_close(nc))  # Datei wird immer geschlossen, auch bei Fehler

  # 1. Read dimensions
  lon  <- ncdf4::ncvar_get(nc, "lon")
  lat  <- ncdf4::ncvar_get(nc, "lat")
  time <- ncdf4::ncvar_get(nc, "time")

  # 2. Convert time to dates
  time_units <- ncdf4::ncatt_get(nc, "time", "units")$value
  # Format: "days since YYYY-MM-DD"
  origin <- sub("days since ", "", time_units)
  dates  <- as.Date(time, origin = origin)

  # 3. Auto-detect variable name
  all_vars   <- names(nc$var)
  skip_vars  <- c("time_bnds", "lat_bnds", "lon_bnds", "height")
  var_name   <- all_vars[!all_vars %in% skip_vars][1]

  # 4. Read data array
  data_array <- ncdf4::ncvar_get(nc, var_name)

  # 5. Replace fill value with NA
  fill_value <- ncdf4::ncatt_get(nc, var_name, "_FillValue")$value
  data_array[abs(data_array - fill_value) < 1e14] <- NA

  # 6. Read units attribute
  units <- ncdf4::ncatt_get(nc, var_name, "units")$value

  # 7. Convert °F to °C
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
  }

  # 8. Convert array to long data.frame
  dimnames(data_array) <- list(lon = lon, lat = lat, time = as.character(dates))

  df <- as.data.frame.table(data_array, responseName = "value") |>
    dplyr::mutate(
      lon   = as.numeric(as.character(lon)),
      lat   = as.numeric(as.character(lat)),
      time  = as.Date(time),
      value = as.numeric(value),
      scenario = variable_meta(scenario = if(!is.null(scenario)) scenario else "unknown")
    )

  # 9. Attach metadata as attributes
  attr(df, "variable") <- var_name
  attr(df, "units")    <- units

  return(df)
}

