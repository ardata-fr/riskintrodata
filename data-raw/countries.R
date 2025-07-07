## code to prepare `countries` dataset goes here
## data comes from the countries package
library(riskintro)
if (!"countries" %in% rownames(installed.packages())) {
  install.packages("countries")
}
if (!"lwgeom" %in% rownames(installed.packages())) {
  install.packages("lwgeom")
}


# library(giscoR)
library(countries)
library(sf)
library(tidyverse)

# Countries general reference table ----

country_ref <- countries::country_reference_list |>
  dplyr::select(iso3 = ISO3, name_en = simple, name_fr = UN_fr) |>
  tibble::as_tibble()

# Associated with Border Risk -----


get_and_wrangle_countries <- function(res) {
  td <- tempdir()

  countries_splat <- geodata::world(
    resolution = res,
    level = 0,
    path = td,
    version = "latest"
  )

  countries_sf <- sf::st_as_sf(countries_splat, crs = "4326") |>
    select(ISO3 = GID_0) |>
    mutate(
      country_en = country_name(ISO3, to = "name_en", verbose = TRUE),
      country_fr = country_name(ISO3, to = "name_fr", verbose = TRUE)
    ) |>
    tidyr::drop_na()

  countries_sf
}

# countries_sf_highres <- get_and_wrangle_countries(res = 1)
world_sf <- get_and_wrangle_countries(res = 5) |>
  dplyr::rename(
    iso3 = ISO3,
    country_name = country_en,
    country_name_fr = country_fr
  )

neighbours_table <- riskintro:::create_neighbours_table(world_sf)
