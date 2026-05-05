#' Resolve Region Specification
#'
#' @param region Either `"global"` or a numeric vector
#'   `c(lon_min, lon_max, lat_min, lat_max)`.
#'
#' @return A list with `type` and optionally `lon_min`, `lon_max`,
#'   `lat_min`, `lat_max`.
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
