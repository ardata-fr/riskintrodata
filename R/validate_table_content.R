# few global variables -----

.validate_dataset_tables_names <- c(
  "animal_mobility",
  "epi_units",
  "entry_points",
  "emission_risk_factors"
)

table_name_is_valid <- function(x) {
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
#'   If validation fails, this element will be NULL, not available. You should
#'   use [extract_dataset()] to extract the dataset from the validation status object.
#' @details
#' The function checks if the dataset contains the required and optional columns
#' as specified in the specifications. It also validates the data using the
#' rules defined in the specifications. If errors are met or validity rules
#' are not satisfied, the function returns a list with the status of the validation.
#' @example examples/read_epi_unit.R
#' @example examples/read_animal_mobility.R
#' @example examples/read_emission_risk_factors.R
#' @example examples/read_entry_points.R
#' @example examples/read_epi_unit_error.R
validate_dataset <- function(x, table_name, ...) {
  if (!table_name_is_valid(table_name)) {
    cli_abort(c(
      "Invalid table name {table_name}.",
      "x" = "Valid table names are: {quote_and_collapse(.validate_dataset_tables_names)}"
    ))
  }

  status <- table_content_validation_status(table_name = table_name)

  mapping <- list(...)

  av_columns <- colnames(x)
  rq_columns <- unname(unlist(mapping))

  not_avail_columns <- setdiff(rq_columns, av_columns)
  if (length(not_avail_columns) > 0) {
    status$matching_columns <- validation_status(
      chk = FALSE,
      msg = glue(
        "The mapped names are not available in the dataset: {quote_and_collapse(not_avail_columns)}."
      ),
      details = not_avail_columns
    )
  } else {
    status$matching_columns <- validation_status(
      chk = TRUE,
      msg = "All columns are in the dataset.",
      details = character()
    )
  }

  if (length(mapping) > 1) {
    class(mapping) <- "mapping"
    attr(mapping, "table_name") <- table_name
    x <- apply_mapping(x, mapping = mapping)
  }

  # define the specifications for the table
  spec <- switch(table_name,
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
  missing_cols <- results[results$required & !results$column_found, "colname", drop = TRUE]
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
  missing_cols <- results[!results$required & !results$column_found, "colname", drop = TRUE]
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
    status$specific_changes <- validation_status(
      chk = TRUE,
      msg = "dataset is valid",
      details = modifs$modif_notes
    )
    status$dataset <- modifs$dataset
  }
  status
}

#' @export
#' @title Check if Dataset is Valid
#' @description
#' Checks if the dataset is valid based on the validation status object
#' returned by [validate_dataset()].
#' @param x A validation status object returned by [validate_dataset()].
#' @return A logical value indicating whether the dataset is valid.
#' @examples
#' library(riskintrodata)
#' tun_epi_files <-
#'   system.file(
#'     package = "riskintrodata",
#'     "samples",
#'     "tunisia",
#'     "epi_units", "tunisia_adm2_raw.gpkg"
#'   )
#'
#' tun_epi_unit <- read_geo_file(tun_epi_files)
#'
#' DATA_EPI_UNITS <- validate_dataset(
#'   x = tun_epi_unit,
#'   table_name = "epi_units",
#'   eu_name = "NAME_2",
#'   user_id = "GID_2"
#' )
#'
#' is_dataset_valid(DATA_EPI_UNITS)
is_dataset_valid <- function(x) {
  inherits(x, "table_validation_status") &&
    x$specific_changes$chk &&
    x$validate_rules$chk &&
    x$required_columns$chk &&
    x$matching_columns$chk &&
    x$optional_columns$chk
}

#' @export
#' @title Extract dataset from validation status
#' @description
#' Extracts the dataset from the validation status object returned by
#' [validate_dataset()].
#'
#' If the dataset is not valid, an error is raised and the details of the
#' validation errors are printed.
#' @param status A validation status object returned by [validate_dataset()].
#' @return The dataset from the validation status object, with attributes
#' `table_name` and `valid` set.
#' @example examples/extract_dataset.R
extract_dataset <- function(status) {
  if (!inherits(status, "table_validation_status")) {
    cli::cli_abort(
      x = "status must be a validation status object"
    )
  }
  if (is.null(status$table_name)) {
    cli::cli_abort(
      x = "status must have a table_name"
    )
  }

  if (!is_dataset_valid(status)) {
    arg <- deparse(substitute(status))
    call <- caller_env()
    z <- validations_for_cli(status)
    cli_abort(z, call = call)
  }

  x <- status$dataset
  attr(x, "table_name") <- status$table_name
  attr(x, "ri_dataset") <- TRUE
  x
}

#' @export
#' @importFrom cli cli_abort
#' @importFrom rlang caller_env
#' @title Check if Dataset is Valid
#' @description
#' Checks if the dataset is valid based on the validation status object
#' returned by [validate_dataset()].
#' @param x A validation status object returned by [validate_dataset()].
#' @param arg A character string representing the name of the argument.
#' @param call The environment from which the function was called.
#' @return NULL, if invalid an error is raised.
#' @examples
#' nc_data <- list.files(
#'     system.file("shape", package="sf"),
#'     full.names = TRUE,
#'     pattern = "^nc"
#'   ) |>
#'   read_geo_file()
#'
#' nc_epi_unit <- validate_dataset(
#'   x = nc_data,
#'   table_name = "epi_units",
#'   eu_name = "NAME",
#'   user_id = "FIPS"
#' )
#'
#' check_dataset_valid(nc_epi_unit)
#'
#' nc_epi_unit <- validate_dataset(
#'   x = nc_data,
#'   table_name = "epi_units",
#'   eu_name = "BLAH",
#'   user_id = "FIPS"
#' )
#'
#' try(check_dataset_valid(nc_epi_unit))
check_dataset_valid <- function(
    x,
    arg = deparse(substitute(x)),
    call = caller_env()) {

  if (!isTRUE(attr(x, "ri_dataset")) && !inherits(x, "table_validation_status")) {
    cli_abort(
      paste(
        "{.arg {arg}} must result from `validate_dataset()` or `extract_dataset()`.",
        "See {.help [{.fun validate_dataset}](riskintrodata::validate_dataset)}"
      ),
      call = call
    )
  }

  if (inherits(x, "table_validation_status")) {
    validated <- is_dataset_valid(x)
    if (!isTruthy(validated)) {
      z <- validations_for_cli(x)
      cli_abort(z, call = call)
    }
  } else if (!isTRUE(attr(x, "ri_dataset"))) {
    cli_abort(
      paste(
        "{.arg {arg}} must result from `validate_dataset()` or `extract_dataset()`.",
        "See {.help [{.fun validate_dataset}](riskintrodata::validate_dataset)}"
      ),
      call = call
    )
  }

  invisible(NULL)
}
