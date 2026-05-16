#' @importFrom stats median setNames
#' @importFrom utils head adist
#' @importFrom scales breaks_width label_date hue_pal
NULL

# Suppress R CMD check notes for dplyr variables
utils::globalVariables(c("time", "scenario", "value", "year", "month"))
