nullify <- function(x) {
  x <- Filter(function(x) !is.null(x), x)
  if (length(x) < 1) x <- NULL
  x
}

#' @title Quote and Collapse Values into a Single String
#' @description
#' Formats a vector of values by surrounding each element with a specified quote character and
#' concatenating them with a separator. The last element is joined with a different separator
#' (e.g., "and") for better readability.
#' @param value A character vector containing the values to format.
#' @param quote_char A character string used to surround each value. Defaults to \code{"`"}.
#' @details
#' This function is useful for creating readable lists of quoted values, such as column names or
#' descriptive strings. The function uses \code{\link[glue]{glue_collapse}} to concatenate the values,
#' with the option to specify a different separator for the last element.
#' @return
#' A single character string with all values quoted and concatenated.
#' @examples
#' # Basic usage
#' quote_and_collapse(c("name", "age", "gender"))
#' # Returns "`name`, `age` and `gender`"
#'
#' # Custom quote character
#' quote_and_collapse(c("A", "B", "C"), quote_char = "'")
#' # Returns "'A', 'B' and 'C'"
#' @noRd
quote_and_collapse <- function(value, quote_char = "`") {
  paste0(
    quote_char,
    glue_collapse(
      x = value,
      sep = paste0(quote_char, ", ", quote_char),
      last = paste0(quote_char, " and ", quote_char)
    ),
    quote_char
  )
}



utils::globalVariables(
  ".data"
)
