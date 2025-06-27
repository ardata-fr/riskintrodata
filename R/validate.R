augment_validate_with_extra <- function(data) {
  mutate(
    .data = data,
    status = case_when(
      .data$error ~ "Error",
      .data$fails > 0 ~ "Failed",
      .default = "OK"
    ),
    extra_label = case_when(
      .data$fails > 0 ~ paste0("failed: ", .data$fails, " / ", .data$items),
      .default = NA_character_
    )
  )
}

# few global variables -----

.validate_dataset_tables_names <- c(
  "animal_mobility",
  "epi_units",
  "entry_points",
  "emission_risk_factors"
)
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
#' @param name A character string specifying the name of the dataset. It
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
#' @examples
#' #
#' @example examples/read_epi_unit.R
#' @example examples/read_animal_mobility.R
#' @example examples/read_emission_risk_factors.R
#' @example examples/read_entry_points.R
validate_table_content <- function(x, name, ...) {
  if (!name %in% .validate_dataset_tables_names) {
    cli_abort(c(
      "Invalid table name {name}.",
      "x" = "Valid table names are: {quote_and_collapse(.validate_dataset_tables_names)}"
    ))
  }

  status <- table_content_validation_status()

  # define the specifications for the table
  spec <- switch(
    name,
    "animal_mobility" = .animal_mobility_spec,
    "epi_units" = .epi_units_spec,
    "entry_points" = .entry_points_spec,
    "emission_risk_factors" = .emission_risk_factors_spec
  )

  is_geospatial <- inherits(x, "sf")

  chosen_columns <- list(...)
  chosen_columns <- nullify(chosen_columns)

  # if no columns are provided, use the default ones
  # this is useful for the emission risk factors where
  # the user does not need to provide any columns
  if (length(chosen_columns) == 0) {
    chosen_columns <- colnames(x)
    names(chosen_columns) <- colnames(x)
  }

  dataset <- rename(x, !!!chosen_columns)
  dataset <- select(dataset, all_of(names(chosen_columns)))
  to_validate <- st_drop_geometry(dataset)

  required_columns <- spec$required_columns
  optional_columns <- spec$optional_columns

  ## check required columns ---------
  if (is_geospatial) {
    # Lat Long not required when importing geometry data
    required_columns <- required_columns[
      !required_columns %in% c("lat", "lng")
    ]
  }
  missing_cols <- setdiff(
    required_columns,
    colnames(to_validate)
  )
  if (length(missing_cols) > 0) {
    status$required_columns <- validation_status(
      chk = FALSE,
      msg = glue(
        "The following required columns are missing: {quote_and_collapse(missing_cols)}"
      ),
      details = missing_cols
    )
    return(status)
  } else {
    status$required_columns <- validation_status(
      chk = TRUE,
      msg = "All required columns selected.",
      details = character()
    )
  }

  ## check optional columns ---------
  missing_cols <- setdiff(
    optional_columns,
    colnames(to_validate)
  )
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

  all_columns <- c(required_columns, optional_columns)

  data_validator <- spec$data_validator
  validate::label(data_validator) <- spec$validator_labels

  # Some validation not required when using lng/lat or optional cols
  # If we have gotten this far, its because the columns are valid, so
  # only validate the ones that exist.
  validate_results <- confront(to_validate, data_validator)
  validate_results <- validate::summary(validate_results)
  columns_not_in_data <- all_columns[
    !all_columns %in% colnames(to_validate)
  ]
  if (length(columns_not_in_data) > 0) {
    validate_results <- validate_results[
      !grepl(
        paste(columns_not_in_data, collapse = "|"),
        validate_results$expression
      ),
    ]
  }

  validate_results <- left_join(
    x = validate_results,
    y = validate::as.data.frame(data_validator),
    by = "name"
  )

  validate_results <- select(
    .data = validate_results,
    all_of(.validate_results_columns)
  )

  validate_results <- augment_validate_with_extra(validate_results)

  if (any(validate_results$error)) {
    status$validate_rules <- validation_status(
      chk = FALSE,
      msg = "Found errors while controling dataset with some rules.",
      details = validate_results
    )
    return(status)
  } else if (any(validate_results$fails > 0)) {
    status$validate_rules <- validation_status(
      chk = FALSE,
      msg = "Found invalidities while controling dataset with some rules.",
      details = validate_results
    )
    return(status)
  } else {
    status$validate_rules <- validation_status(
      chk = TRUE,
      msg = glue("{nrow(validate_results)} valid rules controling dataset."),
      details = validate_results
    )
  }

  status$dataset <- dataset
  status
}
