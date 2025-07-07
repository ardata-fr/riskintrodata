source("data-raw/country_ref.R")
source("data-raw/emission_risk_weights.R")
source("data-raw/wahis_emission_risk_factors.R")
source("data-raw/countries.R")

usethis::use_data(
  country_ref,
  emission_risk_weights,
  wahis_emission_risk_factors,
  world_sf,
  neighbours_table,
  overwrite = TRUE,
  internal = FALSE
)
