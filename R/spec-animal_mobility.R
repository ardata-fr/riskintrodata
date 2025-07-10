
.spec_animal_mobility <- list(
  o_iso3 = list(
    required = FALSE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "is empty" = function(x) nchar(as.character(x)) > 0
    )
  ),
  o_name = list(
    required = FALSE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "is empty" = function(x) nchar(as.character(x)) > 0
    )
  ),
  o_lng = list(
    required = FALSE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "are not numeric" = is.numeric,
      "is not a valid longitude" = is.lng
    )
  ),
  o_lat = list(
    required = FALSE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "are not numeric" = is.numeric,
      "is not a valid latitude" = is.lat
    )
  ),
  d_iso3 = list(
    required = FALSE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "is empty" = function(x) nchar(as.character(x)) > 0
    )
  ),
  d_name = list(
    required = FALSE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "is empty" = function(x) nchar(as.character(x)) > 0
    )
  ),
  d_lng = list(
    required = TRUE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "are not numeric" = is.numeric,
      "is not a valid longitude" = is.lng
    )
  ),
  d_lat = list(
    required = TRUE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "are not numeric" = is.numeric,
      "is not a valid latitude" = is.lat
    )
  ),
  quantity = list(
    required = FALSE,
    validation_func = list(
      "are not numeric" = is.numeric
    )
  )
)
