#' @export
#' @title Convert ISO3 country codes to country names
#' @description
#' This function converts ISO3 country codes to country names in a specified language.
#' @param x A character vector of ISO3 country codes.
#' @param lang A character string specifying the language for the country names.
#' Default is "en" (English), alternatives include "fr" (French).
#' @return A character vector of country names corresponding to the provided ISO3 codes.
#' @details
#' The function uses a reference data frame `country_ref` that contains ISO3
#' codes and their corresponding country names in multiple languages. The
#' data come from the `countries` package.
#' @examples
#' iso3_to_name(c("USA", "FRA", "DEU"))
iso3_to_name <- function(x, lang = "en") {
  x <- as.character(x)
  riskintrodata::country_ref[[paste0("name_", lang)]][match(x, riskintrodata::country_ref$iso3)] %||% NA
}

#' @export
#' @title Table of ISO3 country codes and names in French and English
#' @description
#' This function returns a data frame containing ISO3 country codes and their
#' corresponding names in languages French and English.
#' @return A data frame with columns for ISO3 codes and country names:
#' - `iso3`: *character* - The ISO3 country code.
#' - `name_en`: *character* - The country name in English.
#' - `name_fr`: *character* - The country name in French.
#' @examples
#' country_reference()
country_reference <- function() {
  riskintrodata::country_ref
}
