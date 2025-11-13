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
#' For example, `col1 = "new_col1", col2 = "new_col2"`. See the Column Mapping Requirements
#' by Dataset Type section below.
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
#'
#' @section Column Mapping Requirements by Dataset Type:
#'
#' The `...` parameter accepts column mappings that rename your dataset columns
#' to the standardized names expected by riskintro. Below are the mapping
#' requirements for each dataset type:
#'
#' ## Entry Points (`table_name = "entry_points"`)
#'
#' - Required columns:
#'   - `point_name`: Character or factor column naming or describing the point.
#'     Must not be missing.
#' - Conditional requirement (at least one must be provided):
#'   - Either (`lat` AND `lng`) OR `geometry` must be present for geospatial data
#'   - Any missing data for `mode` and `sources` should be completed, the option
#'   to have missing values is so that RiskIntroApp users can do so using the
#'   graphical interface.
#' - Optional columns:
#'   - `lng`: Numeric column (double), longitude of point. Must be valid longitude
#'     values (-180 to 180).
#'   - `lat`: Numeric column (double), latitude of point. Must be valid latitude
#'     values (-90 to 90).
#'   - `geometry`: sf POINT geometry column if the dataset is of class `sf`
#'     (simple feature). Must not be empty and must be POINT geometry type.
#'   - `mode`: Character or factor, indicates whether points are controlled (C)
#'     or non-controlled (NC). Valid values: "C", "NC", or NA.
#'   - `type`: Character or factor, indicates the type of transport being used.
#'     This is for displaying on maps and does not affect risk analysis scores.
#'     Valid values:
#'     - "AIR" (airport)
#'     - "SEA" (sea port)
#'     - "BC" (border crossing)
#'     - "CC" (contraband crossing)
#'     - "TC" (transhumance crossing)
#'     - NA (missing)
#'   - `sources`: Character column, list of all the ISO3 country codes
#'     that animals enter from through this entry point.
#'
#' ## Epidemiological Units (`table_name = "epi_units"`)
#'
#' - Required columns:
#'   - `eu_name`: Character column, name or description of epi units.
#'     Must not be missing or empty.
#'   - `geometry`: sf POLYGON or MULTIPOLYGON geometry column representing
#'     the geographical areas of each epi unit. Must not be empty and must be
#'     POLYGON or MULTIPOLYGON geometry types.
#' - Optional columns:
#'   - `eu_id`: Character column, can be provided to join other datasets if needed.
#'     Must not have duplicate values if provided.
#'
#' ## Animal Movement (`table_name = "animal_mobility"`)
#'
#' - Required columns:
#'   - `d_lng`: Numeric column, destination point longitude. Must be valid
#'     longitude values (-180 to 180) and not missing.
#'   - `d_lat`: Numeric column, destination point latitude. Must be valid
#'     latitude values (-90 to 90) and not missing.
#' - Conditional requirement:
#'   - At least one of the following must be provided to identify country of provenance:
#'     - (`o_lng` AND `o_lat`)
#'     - `o_iso3`
#' - Optional columns:
#'   - `o_iso3`: Character column, origin country ISO3 code. Must not be empty if provided.
#'   - `o_name`: Character column, origin name or description. Must not be empty if provided.
#'   - `o_lng`: Numeric column, origin point longitude. Must be valid longitude
#'     values (-180 to 180) if provided.
#'   - `o_lat`: Numeric column, origin point latitude. Must be valid latitude
#'     values (-90 to 90) if provided.
#'   - `d_iso3`: Character column, destination country ISO3 code. Must not be empty if provided.
#'   - `d_name`: Character column, destination name or description. Must not be empty if provided.
#'   - `quantity`: Numeric column, used to weight animal movement flows by quantity
#'     of animals. If not provided, no weighting is done.
#'
#' ## Emission Risk Factors (`table_name = "emission_risk_factors"`)
#'
#' For more about the data requirements of this dataset see
#' [riskintrodata::wahis_emission_risk_factors] documentation.
#'
#' - Required columns:
#'   - `iso3`: Character column, ISO3 country code. Must not have missing values
#'     or duplicate values.
#'   - `country`: Character column, country name. Must not have missing values.
#'   - `disease`: Character column, disease name. Must not have missing values.
#'     Each riskintro study should only have one disease (single unique value).
#'   - `animal_category`: Character column, animal category. Must not have missing values.
#'     Each riskintro study should only have one animal category (single unique value).
#'   - `species`: Character column, species name. Must not have missing values.
#'     Each riskintro study should only have one species (single unique value).
#'   - `disease_notification`: Integer column, must be 0, 1, or NA.
#'   - `targeted_surveillance`: Integer column, must be 0, 1, or NA.
#'   - `general_surveillance`: Integer column, must be 0, 1, or NA.
#'   - `screening`: Integer column, must be 0, 1, or NA.
#'   - `precautions_at_the_borders`: Integer column, must be 0, 1, or NA.
#'   - `slaughter`: Integer column, must be 0, 1, or NA.
#'   - `selective_killing_and_disposal`: Integer column, must be 0, 1, or NA.
#'   - `zoning`: Integer column, must be 0, 1, or NA.
#'   - `official_vaccination`: Integer column, must be 0, 1, or NA.
#'   - `last_outbreak_end_date`: Date object column. Must be a valid Date object.
#'   - `commerce_illegal`: Integer column, must be 0, 1, or NA.
#'   - `commerce_legal`: Integer column, must be 0, 1, or NA.
#' - Optional columns:
#'   - `data_source`: Character column, data source identifier.
#' @example examples/read_epi_unit.R
#' @example examples/read_animal_mobility.R
#' @example examples/read_emission_risk_factors.R
#' @example examples/read_entry_points.R
#' @example examples/read_epi_unit_error.R
#' @importFrom dplyr select
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

  # if(nrow(x) == 0) {
  #   status$row_count <- validation_status(
  #     chk = FALSE,
  #     msg = "The dataset has no rows.",
  #     details = character()
  #   )
  # } else {
    status$row_count <- validation_status(
      chk = TRUE,
      msg = glue("The dataset has {nrow(x)} rows."),
      details = character()
    )
  # }

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

  if (length(mapping) > 0) {
    # missing columns are checked by validate_dataset
    clean_mapping <- nullify(mapping[mapping %in% colnames(x)])

    mapping_names <- names(clean_mapping)
    if (length(unique(mapping_names)) != length(mapping_names)) {
      cli_abort("Column mapping names must be unique.")
    }
    x <- x |> rename(!!!clean_mapping)
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

  spec_columns <- sapply(spec, function(y) y$required)
  all_columns <- names(spec_columns)

  # Keep only any relevant columns
  x <- dplyr::select(x, dplyr::any_of(all_columns))

  dataset_columns <- colnames(x)

  required_columns <- names(spec_columns[spec_columns])
  missing_cols <- required_columns[!required_columns %in% dataset_columns]
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
  optional_columns <- names(spec_columns[!spec_columns])
  missing_cols <- optional_columns[!optional_columns %in% dataset_columns]
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

  if (!is.null(results[["valid"]])) {
    n_invalid_checks <- sum(!results[["valid"]])
  } else {
    n_invalid_checks <- 0
  }

  if (n_invalid_checks > 0) {
    status$validate_rules <- validation_status(
      chk = FALSE,
      msg = glue("{n_invalid_checks}/{nrow(results)} checks failed."),
      details = results
    )
  } else {
    status$validate_rules <- validation_status(
      chk = TRUE,
      msg = glue("{nrow(results)}/{nrow(results)} checks are valid."),
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
    x$row_count$chk &&
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
    cli::cli_abort("{.arg status} must be a validation status object")
  }
  if (is.null(status$table_name)) {
    cli::cli_abort("{.arg status} must have a table_name")
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
