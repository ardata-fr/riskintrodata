#' @title Generate an Operation Status Object
#' @description
#' This function creates a status object for an operation, allowing the specification
#' of error, warning, and informational messages. It also ensures that curly
#' braces `{` and `}` in messages are properly escaped.
#' @param status A character string specifying the status of the node. Must be one of
#'   `"success"`, `"error"`, `"warning"`, or `"none"`.
#' @param error_chr Optional character string containing an error message.
#'   Curly braces `{}` are escaped to `{{` and `}}`.
#' @param warning_chr Optional character string containing a warning message.
#'   Curly braces `{}` are escaped to `{{` and `}}`.
#' @param info_chr Optional character string containing an informational message.
#' @return A named list with the following elements:
#' - `error_chr`: (Character or NULL) Processed error message.
#' - `warning_chr`: (Character or NULL) Processed warning message.
#' - `info_chr`: (Character or NULL) Informational message.
#' - `status`: (Character) The validated status.
#' @examples
#' operation_status("success")
#' operation_status("error", error_chr = "An error occurred.")
#' operation_status("warning", warning_chr = "Check your input.")
#' @noRd
operation_status <- function(
  status,
  error_chr = NULL,
  warning_chr = NULL,
  info_chr = NULL
) {
  x <- list(
    error_chr = error_chr,
    warning_chr = warning_chr,
    info_chr = info_chr
  )
  if (!is.null(x$error_chr)) {
    x$error_chr <- gsub("\\{", "{{", x$error_chr)
    x$error_chr <- gsub("\\}", "}}", x$error_chr)
  }
  if (!is.null(x$warning_chr)) {
    x$warning_chr <- gsub("\\{", "{{", x$warning_chr)
    x$warning_chr <- gsub("\\}", "}}", x$warning_chr)
  }
  if (status %in% c("success", "error", "warning", "none")) {
    x$status <- status
  } else {
    cli_abort(
      c(
        "Invalid status value: {status}",
        "i" = "Valid values are: 'success', 'error', 'warning', or 'none'."
      )
    )
  }
  x
}
