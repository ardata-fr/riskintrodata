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
      out <- tibble(
        colname = colname,
        valid = FALSE,
        required = x$required,
        column_found = FALSE,
        n = NA,
        index = NA,
        value = NA,
        msg = glue("Column: \"{colname}\" is missing from the dataset")
      )
      return(out)
      # If found do all required checks ----
    } else {
      yy <- dataset[[colname]]
      checks <- imap(x$validation_func, function(func, msg){
        bools <- !func(yy)
        bools[is.na(bools)] <- FALSE
        if (any(bools)) {
          is_vectorised_func <- length(func(c(1, 2))) == 2L
          if (is_vectorised_func) {
            tibble(
              colname = colname,
              valid = FALSE,
              required = x$required,
              column_found = TRUE,
              n = sum(bools),
              index = list(which(bools)),
              value = list(yy[bools]),
              msg = glue("{sum(bools)} values for \"{colname}\" {msg}")
            )
          } else {
            tibble(
              colname = colname,
              valid = FALSE,
              required = x$required,
              column_found = TRUE,
              n = sum(bools),
              index = list(NULL),
              value = list(yy[bools]),
              msg = glue("Values for \"{colname}\" {msg}")
            )
          }
        } else {
          tibble(
            colname = colname,
            valid = TRUE,
            required = x$required,
            column_found = TRUE,
            n = NA,
            index = NA,
            value = NA,
            msg = glue("\"{colname}\" has been validated")
          )
        }
      })
      bind_rows(checks) # Bind all checks of one column
    }
  })
bind_rows(col_checks_df) # Bind all checks of all columns
}

