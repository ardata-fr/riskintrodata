#' Validate dataset specifications
#' @param dataset dataset to validate against specs
#' @param spec dataset specifications
#' @importFrom purrr imap
#' @noRd
#' @examples
#' dataset <- mtcars |> tibble::rownames_to_column()
#' spec <- list(
#'   rowname = list(
#'     required = TRUE,
#'     validation_func = list(
#'       "are not characters" = is.character)
#'    ),
#'   mpg = list(
#'     required = TRUE,
#'     validation_func = list(
#'       "are not numeric" = is.numeric,
#'       "are not bigger than 12" = function(x) x > 12
#'     )
#'   )
#' )
#' validate_dataset_specifications(dataset, spec)
#'
validate_dataset_specifications <- function(dataset, spec) {

  # Special cases for particular datasets handled here
  if(!is.null(attr(spec,"geospatial"))){
    if(attr(spec,"geospatial") == "sometimes") {
      if(all(c("lng", "lat") %in% colnames(dataset))) {
        spec$geometry <- NULL
      } else {
        spec$lng <- spec$lat <- NULL
      }
    }
  }

  col_checks_df <- imap(spec, function(x, colname){

    # If column not found cannot do all checks ----
    if (!colname %in% colnames(dataset) && x$required) {
      # This is handled elsewhere and does not need to be repeated here.
      return(NULL)
      # out <- tibble(
      #   colname = colname,
      #   valid = FALSE,
      #   required = x$required,
      #   column_found = FALSE,
      #   n = NA,
      #   index = NA,
      #   value = NA,
      #   msg = glue("Column: \"{colname}\" is missing from the dataset")
      # )
      # return(out)

      # If found do all required checks ----
    } else {

      # Check the current column against all validation functions and put
      # it in a tibble. There will be one line in the tibble for each
      # validation function.
      curr_column <- dataset[[colname]]

      checks <- imap(x$validation_func, function(func, msg) {

        # Create error safe version of "func"
        safely_func <- purrr::safely(func)
        valid_column_values <- safely_func(curr_column)

        if (rlang::is_error(valid_column_values$error)) {
          return(
            tibble(
              colname = colname,
              valid = FALSE,
              required = x$required,
              column_found = TRUE,
              n = NA,
              index = NA,
              value = NA,
              msg = glue("Unable to validate {colname} due to error: `{valid_column_values$error}`."),
              vectorised_check = NA
            )
          )
        }

        # Figure out if this "func" returns a vector of length n or length 1
        # For example the difference between is.na(x) and is.character(x)
        # Ideally, the error message is not the same.


        column_length <- length(curr_column)
        validation_results <- valid_column_values$result
        validation_results[is.na(validation_results)] <- TRUE
        invalid_values <- !validation_results

        if (all(validation_results)) {
          # column is valid
          tibble(
            colname = colname,
            valid = TRUE,
            required = x$required,
            column_found = TRUE,
            n = NA,
            index = NA,
            value = NA,
            msg = glue("\"{colname}\" has been validated"),
            vectorised_check = column_length > length(validation_results)
          )
        } else if (column_length > length(validation_results)) {
          # column is not valid
          # func is not vectorised
          tibble(
            colname = colname,
            valid = FALSE,
            required = x$required,
            column_found = TRUE,
            n = sum(invalid_values),
            index = list(NULL),
            value = list(curr_column[invalid_values]),
            msg = glue("Values for \"{colname}\" {msg}"),
            vectorised_check = FALSE
          )
        } else {
          # column is not valid
          # func is vectorised
          tibble(
            colname = colname,
            valid = FALSE,
            required = x$required,
            column_found = TRUE,
            n = sum(invalid_values),
            index = list(which(invalid_values)),
            value = list(curr_column[invalid_values]),
            msg = glue("{sum(invalid_values)} values for \"{colname}\" {msg}"),
            vectorised_check = TRUE
          )
        }
      })
      bind_rows(checks) # Bind all checks of one column
    }
  })
bind_rows(col_checks_df) # Bind all checks of all columns
}

