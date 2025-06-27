# export functions used for validation ----
#' @export
#' @title Check if a vector is a valid latitude
#' @description Check if a vector is a valid latitude
#' @param x numeric vector
#' @return logical vector of the same length as x
#' @family functions for validation process
is.lat <- function(x) {
  z <- na.omit(x)
  z <= 90 & z >= -90
}

#' @export
#' @title Check if a vector is a valid longitude
#' @description Check if a vector is a valid longitude
#' @param x numeric vector
#' @return logical vector of the same length as x
#' @family validation process
is.lng <- function(x) {
  z <- na.omit(x)
  z <= 180 & z >= -180
}

# specifications per tables ------
## Epi units specifications ----------
.epi_units_spec <- list(
  required_columns = c("eu_name"),
  optional_columns = c("user_id"),

  data_validator = validator(
    nchar((as.character(eu_name))) > 0 & !is.na(eu_name),
    length(unique(user_id)) == length(user_id),
    !is.na(user_id)
  ),

  validator_labels = c(
    "EU name has no missing or empty values",
    "All values of user id are different",
    "No missing values of user id"
  )
)


## Animal mobility specifications ----------

.animal_mobility_spec <- list(
  required_columns = c("o_name", "o_lng", "o_lat", "d_name", "d_lng", "d_lat"),
  optional_columns = c("quantity"),

  data_validator = validator(
    nchar((as.character(o_name))) > 0 & !is.na(o_name),

    !is.na(o_lng),
    is.numeric(o_lng),
    is.lng(o_lng),

    !is.na(o_lat),
    is.numeric(o_lat),
    is.lat(o_lat),

    nchar((as.character(o_name))) > 0 & !is.na(o_name),

    !is.na(d_lng),
    is.numeric(d_lng),
    is.lng(d_lng),

    !is.na(d_lat),
    is.numeric(d_lat),
    is.lat(d_lat)
  ),

  validator_labels = c(
    "Origin name has missing values",

    "Origin longitude has no missing values",
    "Origin longitude is numeric",
    "Origin longitude is between -180 and 180",

    "Origin latitude has no missing values",
    "Origin latitude is numeric",
    "Origin latitude is between -90 and 90",

    "Desination name has missing values",

    "Desination longitude has no missing values",
    "Desination longitude is numeric",
    "Desination longitude is between -180 and 180",

    "Desination latitude has no missing values",
    "Desination latitude is numeric",
    "Desination latitude is between -90 and 90"
  )
)


## Entry points specifications ----------

.entry_points_spec <- list(
  required_columns = c("point_name", "lng", "lat"),
  optional_columns = c("mode", "type", "sources"),
  data_validator = validator(
    nchar((as.character(point_name))) > 0 & !is.na(point_name),

    is.character(type),
    all(
      unique(type) %in%
        c(
          "PIF Aerien",
          "PIF Maritime",
          "PIF terrestre",
          "Passage contrebande",
          "Passage transhumance",
          NA_character_
        )
    ),

    is.character(mode),
    all(unique(mode) %in% c("C", "NC")),

    is.numeric(lng),
    is.lng(lng),
    !is.na(lng),

    is.numeric(lat),
    is.lat(lat),
    !is.na(lat),

    is.character(sources),
    all(nchar(sources) == 3) && all(sources %in% country_ref$iso3)
  ),
  validator_labels = c(
    "Entry point name has no missing or empty values",

    'Type contains only character values',
    'Type contains only values "PIF Aerien", "PIF Maritime", "PIF terrestre", "Passage contrebande","Passage transhumance"',

    'Mode contains only character values',
    'Mode contains only values "C" (contreband/illegal entry) or "NC" (non-contraband/legal entry)',

    "Longitude is numeric value",
    "Longitude values are between -180 and 180",
    "Latitude has no missing values",

    "Latitude is numeric value",
    "Latitude values are between -180 and 180",
    "Latitude has no missing values",

    "Sources is character value",
    "Sources are all ISO 3166-1 alpha-3 country codes"
  )
)

## Emission Risk ----------

.emission_risk_factors_spec <- list(
  required_columns = c(
    "iso3",
    "country",
    "disease",
    "animal_category",
    "species",
    "disease_notification",
    "targeted_surveillance",
    "general_surveillance",
    "screening",
    "precautions_at_the_borders",
    "slaughter",
    "selective_killing_and_disposal",
    "zoning",
    "official_vaccination",
    "last_outbreak_end_date",
    "commerce_illegal",
    "commerce_legal"
  ),
  optional_columns = c("data_source"),
  data_validator = validator(
    # ID cols
    is.character(iso3) && all(!is.na(iso3)),
    is.character(country) && all(!is.na(country)),
    is.character(disease) && all(!is.na(disease)),
    length(unique(disease)) == 1,
    is.character(animal_category) && all(!is.na(animal_category)),
    length(unique(animal_category)) == 1,
    is.character(species) && all(!is.na(species)),
    length(unique(species)) == 1,

    # Factor cols
    is.integer(disease_notification) &&
      all(disease_notification %in% c(NA_integer_, 0L, 1L)),
    is.integer(targeted_surveillance) &&
      all(targeted_surveillance %in% c(NA_integer_, 0L, 1L)),
    is.integer(general_surveillance) &&
      all(general_surveillance %in% c(NA_integer_, 0L, 1L)),
    is.integer(screening) && all(screening %in% c(NA_integer_, 0L, 1L)),
    is.integer(precautions_at_the_borders) &&
      all(precautions_at_the_borders %in% c(NA_integer_, 0L, 1L)),
    is.integer(slaughter) && all(slaughter %in% c(NA_integer_, 0L, 1L)),
    is.integer(selective_killing_and_disposal) &&
      all(selective_killing_and_disposal %in% c(NA_integer_, 0L, 1L)),
    is.integer(zoning) && all(zoning %in% c(NA_integer_, 0L, 1L)),
    is.integer(official_vaccination) &&
      all(official_vaccination %in% c(NA_integer_, 0L, 1L)),

    #Other factors cols
    inherits(last_outbreak_end_date, 'Date') == TRUE,

    is.integer(commerce_illegal) &&
      all(commerce_illegal %in% c(NA_integer_, 0L, 1L)),
    is.integer(commerce_legal) &&
      all(commerce_legal %in% c(NA_integer_, 0L, 1L)),

    # Misc cols
    is.character(data_source) && all(nchar(data_source) < 500)
  ),
  validator_labels = c(
    # ID cols
    "iso3 column should have no missing values",
    "country column should have no missing values",
    "disease column should have no missing values",
    "disease column should have only one value",
    "animal_category column should have no missing values",
    "animal_category column should have only one value",
    "species column should have no missing values",
    "species column should have only one value",

    # Factor cols
    "disease_notification should be integer values of 0, 1 or be missing (NA)",
    "targeted_surveillance should be integer values of 0, 1 or be missing (NA)",
    "general_surveillance should be integer values of 0, 1 or be missing (NA)",
    "screening should be integer values of 0, 1 or be missing (NA) ",
    "precautions_at_the_borders should be integer values of 0, 1 or be missing (NA)",
    "slaughter should be integer values of 0, 1 or be missing (NA)",
    "selective_killing_and_disposal should be integer values of 0, 1 or be missing (NA)",
    "zoning should be integer values of 0, 1 or be missing (NA)",
    "official_vaccination should be integer values of 0, 1 or be missing (NA)",

    #Other factors cols
    "last_outbreak_end_date is a date",
    "commerce_illegal should be integer values of 0, 1  or be missing (NA)",
    "commerce_legal should be integer values of 0, 1 or be missing (NA)",

    # Misc cols
    "data_source should be character of length less than 500 characters"
  )
)
