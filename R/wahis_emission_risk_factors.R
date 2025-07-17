#' @title Get WAHIS Emission Risk Factors Dataset
#' @description
#' Helper function for getting the WAHIS emission risk factors dataset. As most
#' analysis done require filtering for one type of each of diease, species and
#' animal_category, this function is a helper for that.
#'
#' For dataset documentation see: [wahis_emission_risk_factors].
#'
#' The function is supposed to be used to get data for all countries that could
#' be involved in the introduction of a risk. The function can not be used to
#' gather data for different diseases, species or animal categories at the same time.
#'
#' @param disease filter dataset for one or more disease
#' @param species filter dataset for one or more species
#' @param animal_category filter dataset for one or more animal_category
#'
#' @return the emission risk factorts dataset as documented here [riskintrodata::wahis_emission_risk_factors]
#' @examples
#' get_wahis_erf(
#'   disease = "Anthrax",
#'   species = "Cattle",
#'   animal_category = "Domestic"
#' )
#' @export
#' @importFrom dplyr filter
#' @family functions for "Emission Risk Factors" management
get_wahis_erf <- function(
    disease = character(),
    species = character(),
    animal_category = character()
){

  filters <- list()

  if (length(disease) > 0) {
    filters <- append(
      filters,
      rlang::expr(disease %in% !!disease)
    )
  }

  if (length(species) > 0) {
    filters <- append(
      filters,
      rlang::expr(species %in% !!species)
    )
  }

  if (length(animal_category) > 0) {
    filters <- append(
      filters,
      rlang::expr(animal_category %in% !!animal_category)
    )
  }

  x <- riskintrodata::wahis_emission_risk_factors |>
    dplyr::filter(!!!filters)

  x <- validate_table_content(x, "emission_risk_factors")
  x <- validate_table_content_cli_msg(x)
  x
}


#' @title Create an Emission Risk Factors (ERF) Row
#' @description
#' Constructs and validates a single row of emission risk factor data for a given country, species, and disease context.
#' This function serves as a robust helper to generate new entries in the emission risk factors dataset, ensuring
#' compatibility with subsequent analytical workflows in the `riskintroanalysis` package.
#'
#' The function performs input validation and data cleaning (e.g., coercing numeric fields to integer) and assigns
#' appropriate data types. It ensures the output meets the schema expected by the emission risk scoring system, which
#' uses this data to calculate risk scores across four weighted domains:
#'
#' - Epidemiological status (e.g., `last_outbreak_end_date`)
#' - Surveillance measures (e.g., `disease_notification`, `targeted_surveillance`, `general_surveillance`, `screening`)
#' - Control measures (e.g., `slaughter`, `zoning`, `official_vaccination`)
#' - Animal commerce (e.g., `commerce_illegal`, `commerce_legal`)
#'
#' The resulting row includes domain-specific fields that will be used by scoring algorithms such as `build_emission_risk_table()`
#' to derive intermediate and final emission risk values.
#' @param iso3 `r erf_param_desc[["iso3"]]`
#' @param country `r erf_param_desc[["country"]]`
#' @param disease `r erf_param_desc[["disease"]]`
#' @param animal_category `r erf_param_desc[["animal_category"]]`
#' @param species `r erf_param_desc[["species"]]`
#' @param disease_notification `r erf_param_desc[["disease_notification"]]`
#' @param targeted_surveillance `r erf_param_desc[["targeted_surveillance"]]`
#' @param general_surveillance `r erf_param_desc[["general_surveillance"]]`
#' @param screening `r erf_param_desc[["screening"]]`
#' @param precautions_at_the_borders `r erf_param_desc[["precautions_at_the_borders"]]`
#' @param slaughter `r erf_param_desc[["slaughter"]]`
#' @param selective_killing_and_disposal `r erf_param_desc[["selective_killing_and_disposal"]]`
#' @param zoning `r erf_param_desc[["zoning"]]`
#' @param official_vaccination `r erf_param_desc[["official_vaccination"]]`
#' @param last_outbreak_end_date `r erf_param_desc[["last_outbreak_end_date"]]`
#' @param commerce_illegal `r erf_param_desc[["commerce_illegal"]]`
#' @param commerce_legal `r erf_param_desc[["commerce_legal"]]`
#' @param data_source `r erf_param_desc[["data_source"]]`
#' @return A [tibble::tibble()] object with cleaned, validated, and
#' structured emission risk factor data. The output is containing the
#' input parameters stored in a table whose columns are:
#' ```{r child = "inst/doc-md/erf-cols.md"}
#' ```
#' @examples
#' erf_row(
#'   iso3 = "FRA",
#'   country = "France",
#'   disease = "ASF",
#'   animal_category = "livestock",
#'   species = "pig",
#'   disease_notification = 1,
#'   targeted_surveillance = 1,
#'   general_surveillance = 0,
#'   screening = 1,
#'   precautions_at_the_borders = 1,
#'   slaughter = 1,
#'   selective_killing_and_disposal = 0,
#'   zoning = 1,
#'   official_vaccination = 0,
#'   last_outbreak_end_date = "2020-05-01",
#'   commerce_illegal = 1,
#'   commerce_legal = 1
#' )
#' @family functions for "Emission Risk Factors" management
#' @export
#' @importFrom tibble tibble
#' @importFrom riskintrodata validate_table_content validate_table_content_cli_msg
erf_row <- function(
    iso3,
    country,
    disease,
    animal_category,
    species,
    disease_notification = 0L,
    targeted_surveillance = 0L,
    general_surveillance = 0L,
    screening = 0L,
    precautions_at_the_borders = 0L,
    slaughter = 0L,
    selective_killing_and_disposal = 0L,
    zoning = 0L,
    official_vaccination = 0L,
    last_outbreak_end_date = as.Date("01/01/1900"),
    commerce_illegal = 0L,
    commerce_legal = 0L,
    data_source = paste0("User ", Sys.info()[["user"]], " - ", Sys.Date())
){



  x <- tibble::tibble(
    iso3 = iso3,
    country = country,
    disease = disease,
    animal_category = animal_category,
    species = species,
    disease_notification = if_numeric_to_int(disease_notification),
    targeted_surveillance = if_numeric_to_int(targeted_surveillance),
    general_surveillance = if_numeric_to_int(general_surveillance),
    screening = if_numeric_to_int(screening),
    precautions_at_the_borders = if_numeric_to_int(precautions_at_the_borders),
    slaughter = if_numeric_to_int(slaughter),
    selective_killing_and_disposal = if_numeric_to_int(selective_killing_and_disposal),
    zoning = if_numeric_to_int(zoning),
    official_vaccination = if_numeric_to_int(official_vaccination),
    last_outbreak_end_date = if_not_date(last_outbreak_end_date),
    commerce_illegal = if_numeric_to_int(commerce_illegal),
    commerce_legal = if_numeric_to_int(commerce_legal),
    data_source = data_source
  )

  status <- validate_table_content(x, table_name = "emission_risk_factors")
  dataset <- validate_table_content_cli_msg(status)

  attr(dataset, "datatype") <- "erf_table"
  dataset
}

if_numeric_to_int <- function(x){
  ifelse(class(x) %in% c("numeric", "logical") , as.integer(x), x)
}

if_not_date <- function(x) {
  if (!inherits(x, "Date")) {
    as.Date(x)
  } else {
    x
  }
}

#' Get Default Emission Risk Weights
#' @return named list of emission risk weights [riskintrodata::emission_risk_weights]
#' @export
#' @importFrom dplyr filter
#' @family functions for "Emission Risk Factors" management
get_erf_weights <- function() {
  riskintrodata::emission_risk_weights
}
