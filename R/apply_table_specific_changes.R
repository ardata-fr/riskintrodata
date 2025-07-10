#' @importFrom dplyr arrange mutate cur_group_id
#' @importFrom sf st_nearest_feature
apply_table_specific_changes <- function(dataset, table_name){

  out <- dataset
  modif_notes <- character()

  if (table_name %in% "animal_mobility") {
    out <- add_id_column(out, name = "animal_mobility_id", prefix = "am-")

    if (!"o_iso3" %in% colnames(dataset)) {
      o_geo <- st_as_sf(out, coords = c("o_lng", "o_lat"), crs = 4326)
      o_geo <- st_make_valid(o_geo)
      o_countries <- suppressMessages({
        sf::sf_use_s2(FALSE)
        o_countries <- st_join_quiet(o_geo, riskintrodata::world_sf, join = st_nearest_feature)
        sf::sf_use_s2(TRUE)
        o_countries <- o_countries |>
          st_drop_geometry() |>
          select(
            .data$animal_mobility_id,
            o_country = .data$country_name,
            o_iso3 = .data$iso3
          )
        o_countries
      })

      out <- left_join(out, o_countries, by = "animal_mobility_id")
      modif_notes <- c(modif_notes, "Animal mobility table augmented with origin iso3 codes")
    }

    if (!"d_iso3" %in% colnames(dataset)){
      d_geo <- st_as_sf(out, coords = c("d_lng", "d_lat"), crs = 4326)
      d_geo <- st_make_valid(d_geo)
      d_countries <- suppressMessages({
        sf::sf_use_s2(FALSE)
        d_countries <- st_join_quiet(d_geo, riskintrodata::world_sf, join = st_nearest_feature)
        sf::sf_use_s2(TRUE)
        d_countries <- d_countries |>
          st_drop_geometry() |>
          select(
            .data$animal_mobility_id,
            d_country = .data$country_name,
            d_iso3 = .data$iso3
          )
        d_countries
      })

      out <- left_join(out, d_countries, by = "animal_mobility_id")
      modif_notes <- c(modif_notes, "Animal mobility table augmented with destination iso3 codes")
    }

  } else if (table_name %in% "epi_units") {

    col_names <- colnames(dataset)
    if (!"eu_id" %in% col_names) {
      modif_notes <- c(modif_notes, "`eu_id` column generated for \"epi_units\", as none was provided")
      out <- add_id_column(out, name = "eu_id", prefix = 'eu-')
    } else {
      out$user_id <- out$eu_id
    }

  } else if (table_name %in% "entry_points") {

    if (!inherits(dataset, "sf") && all(c("lat", "lng") %in% colnames(dataset))) {
      modif_notes <- c(modif_notes,"\"Entry points\" `lat` and `lng` table converted to type POINT_sf" )
      out <- latlng_to_sf(out)
    }

    out <- out |> mutate(
      .by = all_of("geometry"),
      point_id = cur_group_id()
    ) |> arrange(.data[["point_id"]])

  } else if (table_name %in% "emission_risk_factors") {

  }

  list(
    dataset = out,
    modif_notes = modif_notes
  )
}
