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

table_content_validation_status <- function(table_name) {
  status <- list(
    table_name = table_name,
    matching_columns = validation_status(
      chk = FALSE,
      msg = "validation has not run yet."
    ),
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
    specific_changes = validation_status(
      chk = FALSE,
      msg = "transformations not applied."
    ),
    dataset = NULL
  )
  class(status) <- "table_validation_status"
  status
}

collect_validations <- function (x) {

  val_matching_columns <- tibble(
    type = if(x$matching_columns$chk) "success" else "error",
    message = x$matching_columns$msg,
    index = 0, # first to show
    sub_index = 1 # does not matter
  )

  val_required_columns <- tibble(
    type = if(x$required_columns$chk) "success" else "error",
    message = x$required_columns$msg,
    index = 1, # second to show
    sub_index = 1 # does not matter
  )

  val_optional_columns <- tibble(
    type = if(x$optional_columns$chk) "success" else "error",
    message = x$optional_columns$msg,
    index = 2,
    sub_index = 1
  )

  val_specific_changes <- tibble(
    type = if(x$specific_changes$chk) "success" else "error",
    message = x$specific_changes$msg,
    index = 4,
    sub_index = 1
  )

  val_validate_rules <- x$validate_rules$details |>
    transmute(
      type = ifelse(.data$valid, "success", "error"),
      message = .data$msg,
      index = 3,
      sub_index = seq_len(n())
    )

  validations <- bind_rows(
    val_matching_columns,
    val_required_columns,
    val_optional_columns,
    val_validate_rules,
    val_specific_changes
  )
  validations <- arrange(validations, .data$index, .data$sub_index)
  validations <- mutate(
    validations,
    index = NULL, sub_index = NULL
  )
  validations
}

validations_for_cli <- function(x) {
  z <- collect_validations(x)
  z <- filter(z, .data$type %in% "error")
  z <- mutate(z, name = "x")
  z <- setNames(
    c("{.arg {arg}} is invalid because of validation errors.",
      as.character(z$message),
      "See {.help [{.fun validate_dataset}](riskintrodata::validate_dataset)}"
    ),
    c("", z$name, "?")
  )
  z
}

