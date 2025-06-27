source("data-raw/country_ref.R")
source("data-raw/emission_risk_weights.R")

usethis::use_data(
  country_ref,
  emission_risk_weights,
  overwrite = TRUE,
  internal = TRUE
)
