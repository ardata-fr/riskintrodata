# few global variables -----

.validate_dataset_tables_names <- c(
  "animal_mobility",
  "epi_units",
  "entry_points",
  "emission_risk_factors"
)

table_name_is_valid <- function(x){
  length(x) == 1 && x %in% .validate_dataset_tables_names
}

.validate_results_columns <- c(
  "label",
  "description",
  "items",
  "passes",
  "warning",
  "fails",
  "error"
)

# main -----
#' @export
#' @title Validate 'riskintro' Datasets
#' @description
#' Validates the datasets with 'riskintro' rules.
#' The function checks the required and optional columns,
#' and validates the data using the rules defined in the specifications.
#' @param x A data frame or an 'sf' object to be validated.
#' @param table_name A character string specifying the name of the dataset. It
#' accepts one of the following values:
#' - "animal_mobility"
#' - "epi_units"
#' - "entry_points"
#' - "emission_risk_factors"
#' @param ... Additional arguments to be passed to the function. It is expected
#' to be a named list of columns to be renamed in the dataset.
#' For example, `col1 = "new_col1", col2 = "new_col2"`.
#' @return A list containing the validation status of the dataset. The list
#' contains the following elements:
#' - `required_columns`: A list with the status of required columns.
#' - `optional_columns`: A list with the status of optional columns.
#' - `validate_rules`: A list with the status of validation rules.
#' - `dataset`: The dataset after renaming and selecting the specified columns.
#'   If validation fails, this element will be NULL, not available.
#' @details
#' The function checks if the dataset contains the required and optional columns
#' as specified in the specifications. It also validates the data using the
#' rules defined in the specifications. If errors are met or validity rules
#' are not satisfied, the function returns a list with the status of the validation.
#' @example examples/read_epi_unit.R
#' @example examples/read_animal_mobility.R
#' @example examples/read_emission_risk_factors.R
#' @example examples/read_entry_points.R
validate_table_content <- function(x, table_name, ...) {
  if (!table_name_is_valid(table_name)) {
    cli_abort(c(
      "Invalid table name {table_name}.",
      "x" = "Valid table names are: {quote_and_collapse(.validate_dataset_tables_names)}"
    ))
  }

  mapping <- list(...)
  if (length(mapping) > 1) {
    class(mapping) <- "mapping"
    attr(mapping, "table_name") <- table_name
    x <- apply_mapping(x, mapping = mapping, validate = FALSE)
  }

  status <- table_content_validation_status(table_name = table_name)

  # define the specifications for the table
  spec <- switch(
    table_name,
    "animal_mobility" = .spec_animal_mobility,
    "epi_units" = .spec_epi_units,
    "entry_points" = .spec_entry_points,
    "emission_risk_factors" = .spec_emission_risk_factors
  )

  results <- validate_dataset_specifications(
    dataset = x,
    spec = spec
  )

  required_columns <- results[results$required, "colname", drop = TRUE]
  missing_cols <- results[results$required & !results$column_found,  "colname", drop = TRUE]
  if (length(missing_cols) > 0) {
    status$required_columns <- validation_status(
      chk = FALSE,
      msg = glue(
        "The following required columns are missing: {quote_and_collapse(missing_cols)}"
      ),
      details = missing_cols
    )
  } else {
    status$required_columns <- validation_status(
      chk = TRUE,
      msg = "All required columns selected.",
      details = character()
    )
  }

  ## check optional columns ---------
  optional_columns <- results[!results$required, "colname", drop = TRUE]
  missing_cols <- results[!results$required & !results$column_found,  "colname", drop = TRUE]
  if (length(optional_columns) == 0L) {
    status$optional_columns <- validation_status(
      chk = TRUE,
      msg = "No optional columns selected.",
      details = character()
    )
  } else if (length(missing_cols) > 0) {
    status$optional_columns <- validation_status(
      chk = TRUE,
      msg = glue(
        "The following optional columns are missing: {quote_and_collapse(missing_cols)}"
      ),
      details = missing_cols
    )
  } else {
    status$optional_columns <- validation_status(
      chk = TRUE,
      msg = "Optional columns selected are available.",
      details = character()
    )
  }


  if (any(!results$valid)) {
    status$validate_rules <- validation_status(
      chk = FALSE,
      msg = "Found invalidities while checking dataset.",
      details = results
    )
  } else {
    status$validate_rules <- validation_status(
      chk = TRUE,
      msg = glue("{nrow(results)} valid rules checking dataset."),
      details = results
    )
  }

  status$dataset <- x

  if (status$validate_rules$chk) {
    modifs <- apply_table_specific_changes(dataset = x, table_name = table_name)
    status$dataset_changes <- modifs$modif_notes
    status$dataset <- modifs$dataset
  }
  attr(status$dataset, "table_name") <- table_name
  attr(status$dataset, "table_validated") <- status$validate_rules$chk
  status
}

#' Format validate_table_content into CLI message
#' @param x the output of [validate_table_content()]
#'
#' @return the dataset of `x`, throws errors if there are any validation issues
#' from [validate_table_content()]
#'
#' @export
#' @examples
#' x <- get_wahis_erf(
#'   disease = "Anthrax",
#'   species = "Cattle",
#'   animal_category = "Domestic",
#'   validate = TRUE # default
#' )
#' status <- validate_table_content(x, table_name = "emission_risk_factors")
#' dataset <- validate_table_content_cli_msg(status)
#' dataset
#'
#' x <- wahis_emission_risk_factors
#' status <- validate_table_content(x, table_name = "emission_risk_factors")
#' z <- try(validate_table_content_cli_msg(status), silent = TRUE) # error here if invalid data
#' message(cli::ansi_strip(z))
#'
#'
#' wrong_data <- mtcars
#' wrong_data$slaughter <- as.integer(round(runif(nrow(mtcars))))
#' wrong_data$last_outbreak_end_date <- "HELLO"
#' status <- validate_table_content(wrong_data, table_name = "emission_risk_factors")
#' dataset <- try(validate_table_content_cli_msg(status), silent = TRUE)
#' message(cli::ansi_strip(z))
validate_table_content_cli_msg <- function(x){
  y <- x$dataset
  if (attr(y, "table_validated")) {
    cli::cli_alert_success("All data in \"{x$table_name}\" valided.")
    return(y)
  }

  invalid <- x$validate_rules$details[!x$validate_rules$details[["valid"]], ]
  messages <- setNames(paste0("Data validation errors (", nrow(invalid) ,") found for ", quote_and_collapse(x$table_name, quote_char = '"'), ":"), "x")
  for (i in seq_len(nrow(invalid))) {
    row <- invalid[i, ]
    if(is.null(unlist(row$index))){
      messages <- c(messages, paste0(i, ". ", row$msg))
    } else {
      messages <- c(
        messages,
        paste0(i, ". ", row$msg),
        setNames(
          sprintf("Invalid values: %s",
                  quote_and_collapse(unlist(row$value), max_out = 6)), "!"
        ),
        setNames(
          sprintf("At rows: %s",
                  quote_and_collapse(unlist(row$index),quote_char = "", max_out = 6)), "i"
        )
      )
    }
  }
  cli_abort(messages)
}


