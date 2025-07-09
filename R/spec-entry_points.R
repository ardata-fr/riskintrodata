
# Values for "point_name" "are missing"
# Values for "point_name" "are not of type character or factor"

.spec_entry_points <- list(
  "point_name" = list(
    required = TRUE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "are not of type character or factor" = function(x) is.character(x) || is.factor(x)
    )
  ),
  "lng" = list(
    required = TRUE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "are not valid numeric" = is.double,
      "are not valid longitude" = is.lng
    )
  ),
  "lat" = list(
    required = TRUE,
    validation_func = list(
      "are missing" = function(x) !is.na(x),
      "are not valid numeric" = is.double,
      "are not valid lattitude" = is.lat
    )
  ),
  "geometry" = list(
    required = TRUE,
    validation_func = list(
      "are missing" = function(x) !sf::st_is_empty(x),
      "are not geospatial points" = function(x) sf::st_geometry_type(x) == "POINT"
    )
  ),
  "mode" = list(
    required = FALSE,
    validation_func = list(
      "should be one of the following: \"NC\", \"C\" or missing" =
        function(x) x %in% c("C", "NC", NA_character_)
    )
  ),
  "type" = list(
    required = FALSE,
    validation_func = list(
      "should be one of the following:  \"PIF Aerien\", \"PIF Maritime\", \"PIF terrestre\", \"Passage contrebande\", \"Passage transhumance\" or missing" =
        function(x) x %in% c(
          "PIF Aerien",
          "PIF Maritime",
          "PIF terrestre",
          "Passage contrebande",
          "Passage transhumance",
          NA_character_
        )
    )
  )
)
attr(.spec_entry_points, "data_spec") <- "entry_points"
attr(.spec_entry_points, "geospatial") <- "sometimes"

