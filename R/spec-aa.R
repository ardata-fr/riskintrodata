# export functions used for validation ----
#' @export
#' @title Check if a vector is a valid latitude
#' @description Check if a vector is a valid latitude
#' @param x numeric vector
#' @return logical vector of the same length as x
#' @family functions for validation process
is.lat <- function(x) {
  # z <- na.omit(x)
  x <= 90 & x >= -90
}

#' @export
#' @title Check if a vector is a valid longitude
#' @description Check if a vector is a valid longitude
#' @param x numeric vector
#' @return logical vector of the same length as x
#' @family validation process
is.lng <- function(x) {
  # z <- na.omit(x)
  x <= 180 & x >= -180
}
