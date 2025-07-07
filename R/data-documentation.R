

#' Default Emission Risk Weights
#'
#' The emission risk weights by default used to calculate emission risk scores and
#' emission risk from emission risk factors. Each of the measures of control and surveillence,
#' (see [riskintrodata::wahis_emission_risk_factors]) has an associated weighting
#' that has been determined.
#'
#' Intended for use with [riskintroanalysis::get_weighted_emission_risk()].
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
