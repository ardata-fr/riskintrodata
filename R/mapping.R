
#' Apply dataset mapping to dataset
#'
#' Utility function to use alongside the mapping object creator functions such as
#'  `mapping_entry_points`, `mapping_animal_mobility`, etc.. To mapping column names
#'  to the required values and validate the dataset for use in riskintro analysis
#'  workflows.
#'
#' @param dataset dataset to apply mapping to
#' @param mapping mapping to apply to dataset
#' @param validate whether to validate the dataset, TRUE by default
#' @return `dataset` with renamed columns based on mapping and with attribute
#'  "table_name" set to the expected table type and attribute "valid" indicating
#'  if validated or not.
#' @export
#' @example examples/apply_mapping.R
#' @seealso [mapping_entry_points()], [mapping_epi_units()],
#' [mapping_emission_risk_factors()], [mapping_animal_mobility()]
apply_mapping <- function(dataset, mapping, validate = TRUE){

  mapping_attr <- attributes(mapping)
  stopifnot(
    "mapping should have class mapping" =  "mapping" %in% mapping_attr$class,
    "mapping should have attribute table_name" = !is.null(mapping_attr$table_name),
    "mapping attribute table_name is invalid" = table_name_is_valid(mapping_attr$table_name)
  )

  # missing columns are checked by validate_table_content
  clean_mapping <- nullify(mapping[mapping %in% colnames(dataset)])
  x <- dataset |> rename(!!!clean_mapping) |>
    dplyr::select(all_of(names(clean_mapping)))

  if(validate){
    validation_status <- validate_table_content(
      x = x,
      table_name = attr(mapping, "table_name")
    )
    x <- validate_table_content_cli_msg(validation_status)
  } else {
    attr(x, "table_name") <- attr(mapping, "table_name")
    attr(x, "valid") <- FALSE
  }

  x
}

#' Entry points dataset mapping
#'
#' A dataset mapping is used with [apply_mapping()] to renames, select and validation
#' the columns in a dataset that correspond to the parameter names below.
#'
#' @param point_name character column naming or describing the point
#' @param lng numeric column, latitude of point
#' @param lat numeric column, longitude of point (required if no geometry column present)
#' @param geometry sf_POINTS column if the dataset is of class `sf` (simple feature)
#' @param mode character or factor, optional, indicates whether points are contraband (C)
#' or non-contraband (NC). Values should be either `C`, `NC` or missing.
#' @param type character or factors, option, should be one of the following:
#'  \"PIF Aerien\", \"PIF Maritime\", \"PIF terrestre\", \"Passage contrebande\",
#'  \"Passage transhumance\" or missing". Indicates the type of transport being used.
#' @param sources character, optional, this is a list of all the ISO3 country codes
#' that animals enter from through this entry point.
#' @return mapping object to be used with [apply_mapping()]
#' @export
#' @importFrom cli cli_abort
mapping_entry_points <- function(
    point_name, lng = NULL, lat = NULL, geometry = NULL,
    mode = NULL, type = NULL, sources = NULL
){
  if (all(is.null(lat), is.null(lng), is.null(geometry))) {
    cli_abort(
      c(
        "No geospatial data included in `mapping_entry_points()`, include either:",
        "*" = "{.var lat} and {.var lng} columns",
        "*" = "{.var geometry} columns.",
        "See: {.code ?mapping_entry_points}"
      )
    )
  }
  x <- list(
    point_name = point_name,
    lng = lng,
    lat = lat,
    geometry = geometry,
    mode = mode,
    type = type,
    sources = sources
  )
  class(x) <- c("mapping")
  attr(x, "table_name") <- "entry_points"
  attr(x, "convert_to_sf") <- TRUE
  x
}

#' Epidemiological units dataset mapping
#'
#' A dataset mapping is used with [apply_mapping()] to renames, select and validation
#' the columns in a dataset that correspond to the parameter names below.
#'
#' @param eu_name character, required, name or description of epi units
#' @param eu_id charcter, optional, can be provided to join other datasets if needed
#' @param geometry sf_POLYGON or sf_MULTIPOLYGON geospatial data type, representing
#' the geographical areas of each epi unit.
#' @return mapping object to be used with [apply_mapping()]
#' @export
mapping_epi_units <- function(
    eu_id = NULL,
    eu_name,
    geometry
){
  x <- list(
    eu_id = eu_id,
    eu_name = eu_name,
    geometry = geometry
  )
  class(x) <- c("mapping")
  attr(x, "table_name") <- "epi_units"
  x
}

#' Animal movement dataset mapping
#'
#' A dataset mapping is used with [apply_mapping()] to renames, select and validation
#' the columns in a dataset that correspond to the parameter names below.
#'
#' @param o_name character, reauired, origin name or description
#' @param o_iso3 character, optional,  origin country iso3 code
#' @param o_lng numeric, optional, origin point longitude
#' @param o_lat numeric, option, origin point latitude
#' @param d_name character, origin name or description
#' @param d_iso3 character, optional,  destination country iso3 code
#' @param d_lng numeric, required, destination point longitude
#' @param d_lat numeric, required, destination point latitude
#' @param quantity numeric, optional, used to weight animal movement flows by quantity
#' of animals, if not provided no weighting is done.
#' @return mapping object to be used with [apply_mapping()]
#' @export
mapping_animal_mobility <- function(
    o_iso3 = NULL,
    o_name,
    o_lng = NULL,
    o_lat = NULL,
    d_iso3 = NULL,
    d_name,
    d_lng,
    d_lat,
    quantity = NULL
){

  lat_lng_nulls <- sum(c(is.null(o_lng), is.null(o_lat)))
  if(!lat_lng_nulls %in% c(0, 2)) {
    cli_abort(
      c("If {.var o_lng} is provided then {.var o_lat} and vice versa")
    )
  }
  if (lat_lng_nulls == 0 && is.null(o_name) && is.null(o_iso3)) {
    cli_abort(
      c("One of the following must be provided in \"animal_mobility\" mapping:",
        "*" = "{.var o_lng} and {.var o_lat}",
        "*" = "{.var o_iso3}",
        "This is used to identify country of provenance."
        )
    )
  }

  x <- list(
    o_iso3 = o_iso3,
    o_name = o_name,
    o_lng = o_lng,
    o_lat = o_lat,
    d_iso3 = d_iso3,
    d_name = d_name,
    d_lng = d_lng,
    d_lat = d_lat,
    quantity = quantity
  )
  class(x) <- c("mapping")
  attr(x, "table_name") <- "animal_mobility"
  x
}


#' Emission risk factors dataset mapping
#'
#' A dataset mapping is used with [apply_mapping()] to renames, select and validation
#' the columns in a dataset that correspond to the parameter names below.
#'
#' For more about the data requirements of this dataset see [riskintrodata::wahis_emission_risk_factors] documentation
#'
#' @param iso3 character, required, country iso3 code
#' @param country character, required, country name
#' @param disease character, required, disease name
#' @param animal_category character, required, animal category "Wild" or "Domestic"
#' @param species character, required, animal species name
#' @param disease_notification integer, required, must be NA, 1 or 0: 1 representing this policy is not
#' enforced in that country (i.e. 1 is risky, 0 is not).
#' @param targeted_surveillance as `disease_notification`
#' @param general_surveillance as `disease_notification`
#' @param screening as `disease_notification`
#' @param precautions_at_the_borders as `disease_notification`
#' @param slaughter as `disease_notification`
#' @param selective_killing_and_disposal as `disease_notification`
#' @param zoning as `disease_notification`
#' @param official_vaccination as `disease_notification`
#' @param last_outbreak_end_date date, required, must be a date: represents the
#' last time there was an outbreak of this disease in this country.
#' @param commerce_illegal integer, required, must be NA, 1 or 0: 1 representing
#' this type of commerce is conducted between this country and country for which
#' risk of introduction is been calcalated (i.e. 1 is risky, 0 is not).
#' @param commerce_legal as `commerce_illegal`
#' @param data_source character, optional, used to keep track of where the data
#' is sourced.
#' @return mapping object to be used with [apply_mapping()]
#' @export
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
  class(x) <- c("mapping")
  attr(x, "table_name") <- "emission_risk_factors"
  x
}

