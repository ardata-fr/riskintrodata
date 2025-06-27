## code to prepare `country_ref` dataset goes here
library(countries)
library(tidyverse)

country_ref <- countries::country_reference_list |>
  dplyr::select(iso3 = ISO3, name_en = simple, name_fr = UN_fr) |>
  tibble::as_tibble()
