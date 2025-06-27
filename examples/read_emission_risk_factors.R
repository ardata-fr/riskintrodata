# read Tunisia emission risk factors dataset
tun_erf_file <-
  system.file(
    package = "riskintrodata",
    "samples",
    "tunisia",
    "emission_risk_factor",
    "emission_risk_factors.csv"
  )
x <- read_emission_risk_factor_file(tun_erf_file)

DATA_ERF <- validate_table_content(x, name = "emission_risk_factors")

DATA_ERF
