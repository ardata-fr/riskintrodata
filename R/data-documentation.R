

#' Default Emission Risk Weights
#'
#' The emission risk weights by default used to calculate emission risk scores and
#' emission risk from emission risk factors. Each of the measures of control and surveillence,
#' (see [riskintrodata::wahis_emission_risk_factors]) has an associated weighting
#' that has been determined.
#'
#' @docType data
#' @keywords data
"emission_risk_weights"


#' Neighbours table
#'
#' A correspondence table of all countries and their neighbours.
#'
#' Columns:
#'
#' * country_id: country iso3 code
#' * neighbour_id: neighbouring country iso3 code
#' * border_id: primary key, combination of country_id-neighbour_id
#' * border_length: shared border estimated length
#'
#' @docType data
#' @keywords data
"neighbours_table"


#' World Simple Features
#'
#' SF dataset containing global administrative boundaries for most countries.
#'
#' @source [geodata::gadm()]
#'
#' @docType data
#' @keywords data
"world_sf"

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
#' Animal commerce, indicators of wherther legal and illegal commerce are being conducted
#' between the epidemiological units and this country.
#' - `commerce_illegal`: *integer* -  either 1 or 0
#' - `commerce_legal`: *integer* -  either 1 or 0
#'
#' Other information:
#' - `data_source`: *character* - Reference or source of the data.
#'
#' @docType data
#' @keywords data
"wahis_emission_risk_factors"
