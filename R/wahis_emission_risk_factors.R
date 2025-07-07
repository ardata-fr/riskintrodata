#' Emission Risk Factors dataset from WAHIS
#'
#' This data set is a combination of two datasets downloaded from the WAHIS
#' ([World Animal Health Information System](https://wahis.woah.org/#/home)).
#'
#' The dataset categories measures taken by governments to control and survey the
#' animal disease situation in any one country for a specific animal and disease.
#'
#' This dataset serves as the starting point for risk of introduction analysis.
#' An analysis would begin by filtering the data for one type of animal species and
#' disease, then calculating the risk of introduction of this disease through movements
#' of this species.
#'
#' Note that for some countries, diseases or animals - or cross section of the three -
#' there is no data.
#'
#' ### Data source
#'
#' 1. [Control measures dataset](https://wahis.woah.org/#/dashboards/control-measure-dashboard)
#'    exported from the
#'    corresponding WAHIS dashboard. Exported for the most recent time period for all countries,
#'    diseases and species.
#' 2. [Disease situation dataset](https://wahis.woah.org/#/dashboards/country-or-disease-dashboard)
#'    exported from the
#'    corresponding WAHIS dashboard. Exported all data for all countries, then filtered to have
#'    data for the most recent outbreak across each country, disease and species.
#'
#' These two datasets are transformed and combined to create the WAHIS emission
#' risk factors dataset which is essential to the analysis methods in this package.
#'
#' ### Data specifications
#'
#' The dataset contains 17 columns, each with specific types and data rules:
#'
#' Country information:
#'
#' - `iso3`: *character* - A three-letter ISO 3166-1 alpha-3 country code.
#' - `country`: *character* - The full name of the country.
#'
#' Disease information (should be the same for the whole dataset):
#' - `disease`: *character* - The name of the disease.
#' - `animal_category`: *character* - The category of animal ("Domestic" or "Wild").
#' - `species`: *character* - The species name affected by disease.
#'
#' Measures of control and surveillence, all are either 1 or 0 (0 = measure inplace, 1 = no measure inplace, i.e. 1 = there is a risk, 0 = there is no risk).
#' - `disease_notification`: *integer* - Indicator of notification
#' - `targeted_surveillance`: *integer* - Risk factor score for targeted surveillance efforts.
#' - `general_surveillance`: *integer* - Risk factor score for general surveillance activities.
#' - `screening`: *integer* - Risk factor score for screening measures.
#' - `precautions_at_the_borders`: *integer* - Risk factor score for precautions taken at borders.
#' - `slaughter`: *integer* - Risk factor score related to the slaughter process.
#' - `selective_killing_and_disposal`: *integer* - Risk factor score for selective killing and disposal procedures.
#' - `zoning`: *integer* - Risk factor score for zoning strategies.
#' - `official_vaccination`: *integer* - Risk factor score for official vaccination programs.
#'
#' Epidemiological status:
#' - `last_outbreak_end_date`: *Date* (YYYY-MM-DD) - The end date of the last outbreak.
#'
#' Animal commerce (indicators of level of illegality of commerce)
#' - `commerce_illegal`: *integer* -  either 1 or 0
#' - `commerce_legal`: *integer* -  either 1 or 0
#'
#' Other information:
#' - `data_source`: *character* - Reference or source of the data.
#'
#' @docType data
#' @keywords data
"wahis_emission_risk_factors"


#' Get WAHIS Emission Risk Factors Dataset
#'
#' Helper function for getting the WAHIS emission risk factors dataset. As most
#' analysis done require filtering for one type of each of diease, species and
#' animal_category, this function is a helper for that.
#'
#' @param disease filter dataset for one or more disease
#' @param species filter dataset for one or more species
#' @param animal_category filter dataset for one or more animal_category
#'
#' @return the emission risk factorts dataset as documented here [riskintrodata::wahis_emission_risk_factors]
#' @export
#' @importFrom dplyr filter
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

  x
}

#' @export
#' @importFrom tibble tibble
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
    last_outbreak_end_date = if (class(last_outbreak_end_date) != "Date") as.Date(last_outbreak_end_date) else last_outbreak_end_date,
    commerce_illegal = if_numeric_to_int(commerce_illegal),
    commerce_legal = if_numeric_to_int(commerce_legal),
    data_source = data_source
  )

  status <- validate_table_content(x, name = "emission_risk_factors")
  dataset <- validate_table_content_cli_msg(status)

  attr(dataset, "datatype") <- "erf_table"
  dataset
}

if_numeric_to_int <- function(x){
  ifelse(class(x) %in% c("numeric", "logical") , as.integer(x), x)
}


