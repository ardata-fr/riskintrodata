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
quote_and_collapse <- function(value, quote_char = "`", max_out = NULL) {
  n <- length(value)
  if (n == 0) return("")

  # Truncate if needed
  if (!is.null(max_out) && n > max_out) {
    value_display <- value[seq_len(max_out)]
    extra <- n - max_out
  } else {
    value_display <- value
    extra <- 0
  }

  # Apply quoting
  quoted <- paste0(quote_char, value_display, quote_char)

  # Collapse with oxford-style conjunction
  collapsed <- glue::glue_collapse(
    quoted,
    sep = ", ",
    last = if (length(quoted) > 1) paste0(" and ") else NULL
  )

  # Add "... and N more" if truncated
  if (extra > 0) {
    collapsed <- paste0(collapsed, " and ", extra, " more")
  }

  collapsed
}

#' @importFrom glue glue
#' @importFrom dplyr mutate row_number cur_group_id
add_id_column <- function(.data, name, by = NULL, prefix = "") {
  id_width <- nchar(nrow(.data)) + 2
  if(is.null(by)){
    mutate(
      .data, "{name}" := sprintf(glue("{prefix}%0{id_width}i"), row_number()),
      .before = 1
    )
  } else{
    mutate(
      .data,
      .by = all_of(by),
      "{name}" := sprintf(glue(prefix, "%0{id_width}i"), cur_group_id()),
      .before = 1
    )
  }
}


utils::globalVariables(
  c(".data", "country_ref")
)
#' @importFrom sf st_join
st_join_quiet <- function(...) {
  suppressWarnings(suppressMessages(st_join(...)))
}



erf_column_param <- c("#' @param iso3 ISO3 country code (e.g., \"FRA\"), it should be a valid ISO3 code with a match in column `iso3` returned by [riskintrodata::country_reference()] or a string starting with 'JOKER'.",
  "#' @param country Country name (e.g., \"France\"), the name is free text, but is expected to match the country name `name_en` or `name_fr` in the dataset returned by [riskintrodata::country_reference()].",
  "#' @param disease Disease name (e.g., \"ASF\"), it should be a valid disease code or name. For now there is no check for the disease name: it is expected to match the disease name in the dataset of WAHIS diseases but as the data are not covering all deceases, it is not checked so that users can add their own diseases.",
  "#' @param animal_category Animal category, one of \"wild\" or \"domestic\".",
  "#' @param species Species name (e.g., \"pig\"), it is a free text. It's expected to match the species name in the dataset returned by WAHIS species dataset but as the data are not covering all species, it is not checked so that users can add their own species.",
  "#' @param disease_notification Integer (0 or 1). All are either 1 or 0, 0 means 'measure inplace' and 1 means 'no measure inplace', i.e. 1 = there is a risk, 0 = there is no risk.",
  "#' @param targeted_surveillance Integer (0 or 1). Is targeted surveillance applied? All are either 1 or 0, 0 means 'measure inplace' and 1 means 'no measure inplace', i.e. 1 = there is a risk, 0 = there is no risk.",
  "#' @param general_surveillance Integer (0 or 1). Is general surveillance applied? All are either 1 or 0, 0 means 'measure inplace' and 1 means 'no measure inplace', i.e. 1 = there is a risk, 0 = there is no risk.",
  "#' @param screening Integer (0 or 1). Are screening measures in place? All are either 1 or 0, 0 means 'measure inplace' and 1 means 'no measure inplace', i.e. 1 = there is a risk, 0 = there is no risk.",
  "#' @param precautions_at_the_borders Integer (0 or 1). Are precautions taken at the borders? All are either 1 or 0, 0 means 'measure inplace' and 1 means 'no measure inplace', i.e. 1 = there is a risk, 0 = there is no risk.",
  "#' @param slaughter Integer (0 or 1). Are slaughter processes in place? All are either 1 or 0, 0 means 'measure inplace' and 1 means 'no measure inplace', i.e. 1 = there is a risk, 0 = there is no risk.",
  "#' @param selective_killing_and_disposal Integer (0 or 1). Are selective killing and disposal procedures in place? All are either 1 or 0, 0 means 'measure inplace' and 1 means 'no measure inplace', i.e. 1 = there is a risk, 0 = there is no risk.",
  "#' @param zoning Integer (0 or 1). Are zoning strategies applied? All are either 1 or 0, 0 means 'measure inplace' and 1 means 'no measure inplace', i.e. 1 = there is a risk, 0 = there is no risk.",
  "#' @param official_vaccination Integer (0 or 1). Are official vaccination programs applied? All are either 1 or 0, 0 means 'measure inplace' and 1 means 'no measure inplace', i.e. 1 = there is a risk, 0 = there is no risk.",
  "#' @param last_outbreak_end_date Date. The end date of the last outbreak.",
  "#' @param commerce_illegal Integer (0, 1). Indicators of whether illegal commerce are being conducted.",
  "#' @param commerce_legal Integer (0, 1). Indicators of whether legal commerce are being conducted.",
  "#' @param data_source Character. A description of the data source, defaulting to the user name and current date. This is free text."
)

#' @title Check Internet Connection
#' @description
#' The function tests for internet connectivity by performing a dns lookup. If a
#' proxy server is detected, it will also check for connectivity by connecting
#' via the proxy. This is a copy of [curl::has_internet()]
#' @export
#' @examples
#' has_internet()
#' @keywords internal
has_internet <- function() {
  curl::has_internet()
}

cli_abort_if_not <- function(..., .call = .envir, .envir = parent.frame(), .frame = .envir) {
  for (i in seq_len(...length())) {
    if (!all(...elt(i))) {
      cli::cli_abort(
        ...names()[i],
        .call = .call,
        .envir = .envir,
        .frame = .frame
      )
    }
  }
  invisible(NULL)
}
