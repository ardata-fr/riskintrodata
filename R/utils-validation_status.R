validation_status <- function(chk = NULL, msg = NULL, details = NULL) {
  test_chk <- !is.null(chk) && is.logical(chk) && length(chk) == 1L
  if (!test_chk) {
    cli_abort(c(
      "Argument `chk` must be a single logical value.",
      "i" = "Use `validation_status(chk = TRUE, ...)` or `validation_status(chk = FALSE, ...)`."
    ))
  }

  test_msg <- !is.null(msg) &&
    is.character(msg) &&
    length(msg) == 1L &&
    !is.na(msg)
  if (!test_msg) {
    cli_abort(c(
      "Argument `msg` must be a single character value.",
      "i" = "Use `validation_status(msg = 'your message here', ...)`."
    ))
  }

  x <- list(chk = chk, msg = msg, details = details)
  class(x) <- "validation_status"
  x
}

table_content_validation_status <- function() {
  status <- list(
    required_columns = validation_status(
      chk = FALSE,
      msg = "validation has not run yet."
    ),
    optional_columns = validation_status(
      chk = FALSE,
      msg = "validation has not run yet."
    ),
    validate_rules = validation_status(
      chk = FALSE,
      msg = "validation has not run yet."
    ),
    dataset = NULL
  )
  class(status) <- "table_validation_status"
  status
}
