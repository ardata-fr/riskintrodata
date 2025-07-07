
#' @importFrom dplyr rename
apply_mapping <- function(dataset, mapping, validate = TRUE){

  x <- dataset |>
    rename(
      mapping
    )

  x
}

mapping_epi_units <- function(
    eu_name,
    user_id = NULL
){
  x <- list(
    eu_name = eu_name,
    user_id = user_id
  )
  class(x) <- c("mapping","mapping_epi_units")
  x
}


mapping_animal_mobility <- function(
    o_name,
    o_lng,
    o_lat,
    d_name,
    d_lng,
    d_lat,
    quantity = NULL,
    dataset = NULL
){
  x <- list(
    o_name = o_name,
    o_lng = o_lng,
    o_lat = o_lat,
    d_name = d_name,
    d_lng = d_lng,
    d_lat = d_lat,
    quantity = quantity
  )
  class(x) <- c("mapping","mapping_animal_mobility")
  x
}

mapping_entry_points <- function(
    point_name, lng, lat,
    mode = NULL, type = NULL, sources = NULL
    ){
  x <- list(
    point_name = point_name,
    lng = lng,
    lat = lat,
    mode = mode,
    type = type,
    sources = sources
  )
  class(x) <- c("mapping","mapping_entry_points")
  x
}

mapping_emission_risk_factors <- function(
    iso3,
    country,
    disease,
    animal_category,
    species,
    disease_notification,
    targeted_surveillance,
    general_surveillance,
    screening,
    precautions_at_the_borders,
    slaughter,
    selective_killing_and_disposal,
    zoning,
    official_vaccination,
    last_outbreak_end_date,
    commerce_illegal,
    commerce_legal,
    data_source = NULL
    ){
  x <- list(
    iso3 = iso3,
    country = country,
    disease = disease,
    animal_category = animal_category,
    species = species,
    disease_notification = disease_notification,
    targeted_surveillance = targeted_surveillance,
    general_surveillance = general_surveillance,
    screening = screening,
    precautions_at_the_borders = precautions_at_the_borders,
    slaughter = slaughter,
    selective_killing_and_disposal = selective_killing_and_disposal,
    zoning = zoning,
    official_vaccination = official_vaccination,
    last_outbreak_end_date = last_outbreak_end_date,
    commerce_illegal = commerce_illegal,
    commerce_legal = commerce_legal,
    data_source = data_source
  )
  class(x) <- c("mapping","mapping_emission_risk_factors")
  x
}













