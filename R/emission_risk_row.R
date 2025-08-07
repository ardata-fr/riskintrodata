#' new_joker_key <- function(dataset) {
#'   existing_joker_id <- dataset |>
#'     dplyr::filter(grepl("JOKER", .data[["iso3"]], fixed = TRUE)) |>
#'     dplyr::pull("iso3")
#'   next_joker_id <- if (length(existing_joker_id) > 0) {
#'     paste0(
#'       "JOKER",
#'       max(as.integer(gsub("JOKER", "", existing_joker_id, fixed = TRUE)), na.rm = TRUE) + 1
#'     )
#'   } else {
#'     "JOKER1"
#'   }
#' }
#'
#'
#' #' @title Create a new emission risk row
#' #' @description
#' #' Create a new emission risk row for a given country and disease.
#' #' This function generates a new row with the specified parameters and
#' #' returns it as a tibble.
#' #' @param country_id Country ID (iso3). If `new_joker` is TRUE, this will be
#' #' the name of a new joker ID, otherwise it should be an ISO3 code.
#' #' The ISO3 code are available in the `country_ref` dataset.
#' #' @param disease,animal_category,species values to be inserted
#' #' @param emissionRiskFactors table des facteurs d’émission (reactive ou tibble)
#' #' @param new_joker logical, should be TRUE to create a new joker ID
#' #' @return a one row tibble with the specified parameters. The dataset will
#' #' contain the following columns:
#' #' - `iso3`: *character* - The ISO3 country code or a new joker ID.
#' #' - `country`: *character* - The full name of the country.
#' #' - `disease`: *character* - The name of the disease.
#' #' - `animal_category`: *character* - The category of animal ("Domestic" or "Wild").
#' #' - `species`: *character* - The species name affected by disease.
#' #' @export
#' create_emission_risk_row <- function(
#'   country_id,
#'   disease,
#'   animal_category,
#'   species,
#'   emissionRiskFactors,
#'   new_joker = FALSE
#' ) {
#'   if (new_joker) {
#'     next_joker_id <- new_joker_key(emissionRiskFactors)
#'
#'     tibble(
#'       iso3 = next_joker_id,
#'       country = country_id,
#'       disease = disease,
#'       animal_category = animal_category,
#'       species = species
#'     )
#'   } else {
#'     tibble(
#'       iso3 = country_id,
#'       country = iso3_to_name(country_id),
#'       disease = disease,
#'       animal_category = animal_category,
#'       species = species
#'     )
#'   }
#' }
#'
#' #' @title Get an Emission Risk Row from a Country ID
#' #' @description
#' #' Get an emission risk row for a given country ID.
#' #' This function retrieves the row from the emissionRiskFactors dataset
#' #' and returns it as a tibble. If the row does not exist, it creates a new one.
#' #' @param country_id an ISO3 country code (or the name of a joker)
#' #' @param emissionRiskFactors table of emission factors
#' #' @param disease,animal_category,species values to be inserted
#' #' @param new_joker if TRUE, create a new joker ID
#' #' @return a single tibble row with the specified parameters
#' #' @export
#' get_emission_risk_edit_row <- function(
#'   country_id,
#'   emissionRiskFactors,
#'   disease,
#'   animal_category,
#'   species,
#'   new_joker = FALSE
#' ) {
#'   edit_row <- emissionRiskFactors |>
#'     dplyr::filter(.data[["iso3"]] == country_id)
#'
#'   if (nrow(edit_row) == 0L) {
#'     new_row <- create_emission_risk_row(
#'       country_id = country_id,
#'       disease = disease,
#'       animal_category = animal_category,
#'       species = species,
#'       emissionRiskFactors = emissionRiskFactors,
#'       new_joker = new_joker
#'     )
#'     edit_row <- dplyr::bind_rows(edit_row, new_row)
#'   }
#'
#'   edit_row
#' }
#'
#'
#' #' @title Update Emission Risk Row from Input
#' #' @description Updates an edit line with user input values
#' #' @param row ligne tibble à modifier
#' #' @param input objet list ou liste nommée simulant `input$...` de Shiny
#' #' @return tibble modifié avec colonnes binaires pour les facteurs
#' #' @export
#' update_emission_risk_row_from_input <- function(row, input) {
#'   risk_factor_cols <- c(
#'     "disease_notification",
#'     "targeted_surveillance",
#'     "general_surveillance",
#'     "screening",
#'     "precautions_at_the_borders",
#'     "slaughter",
#'     "selective_killing_and_disposal",
#'     "zoning",
#'     "official_vaccination",
#'     "commerce_illegal",
#'     "commerce_legal"
#'   )
#'
#'   row$last_outbreak_end_date <- switch(
#'     input$epistatus_checkbox,
#'     "show_date" = input$last_outbreak_end_date,
#'     "current" = as.Date("2999-01-01"),
#'     "none" = as.Date("1900-01-01")
#'   )
#'
#'   for (col in risk_factor_cols) {
#'     row[[col]] <- input[[col]]
#'   }
#'
#'   row$data_source <- paste0("User ", Sys.info()[["user"]], " - ", Sys.Date())
#'
#'   row <- dplyr::mutate(
#'     row,
#'     dplyr::across(
#'       dplyr::all_of(risk_factor_cols),
#'       ~ dplyr::if_else(.x == TRUE, 0L, 1L)
#'     )
#'   )
#'
#'   row
#' }
