#' Resolve Region Input to a Standardised Format
#'
#' @description
#' Converts a region input (either a string or a numeric bounding box) into
#' a standardised list used by \code{build_request()}.
#'
#' @param region Character or numeric vector. Either \code{"global"} for global
#'   coverage, or a bounding box as \code{c(lon_min, lon_max, lat_min, lat_max)}.
#'   Example: \code{c(9, 14, 47, 51)} for Bavaria.
#'
#' @return A named list with element \code{type} set to either \code{"global"}
#'   or \code{"bbox"}. For bounding boxes, additionally contains \code{lon_min},
#'   \code{lon_max}, \code{lat_min}, and \code{lat_max}.
#' @keywords internal

resolve_region <- function(region) {

  if (is.character(region)) {

    if (region == "global") {
      return(list(
        type = "global"
      ))
    }

    stop("Unknown region name (only 'global' supported yet)")
  }

  if (is.numeric(region)) {

    if (length(region) != 4) {
      stop("bbox must be: c(lon_min, lon_max, lat_min, lat_max)")
    }

    lon_min <- region[1]
    lon_max <- region[2]
    lat_min <- region[3]
    lat_max <- region[4]

    if (lon_min >= lon_max || lat_min >= lat_max) {
      stop("Invalid bounding box")
    }

    return(list(
      type = "bbox",
      lon_min = lon_min,
      lon_max = lon_max,
      lat_min = lat_min,
      lat_max = lat_max
    ))
  }

  stop("Invalid region format")
}
