.spec_epi_units <- list(
  eu_name = list(
    required = TRUE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "are empty" = function(x) nchar(as.character(x)) > 0
    )
  ),
  user_id = list(
    required = FALSE,
    validation_func = list(
      "contains missing values" = function(x) !is.na(x),
      "has duplicate values" = function(x) length(unique(x)) == length(x)
    )
  ),
  eu_id = list(
    required = FALSE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "is empty" = function(x) length(unique(x)) == length(x)
    )
  ),
  "geometry" = list(
    required = TRUE,
    validation_func = list(
      "are missing" = function(x) !sf::st_is_empty(x),
      "are not geospatial polygons" = function(x) {
        sf::st_geometry_type(x) %in% c("POLYGON", "MULTIPOLYGON")
        }
    )
  )
)
