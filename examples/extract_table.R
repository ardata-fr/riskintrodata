## ---- read-epi-units-tunisia ----
tun_epi_files <-
  system.file(
    package = "riskintrodata",
    "samples",
    "tunisia",
    "epi_units", "tunisia_adm2_raw.gpkg"
  )

tun_epi_unit <- read_geo_file(tun_epi_files)

DATA_EPI_UNITS <- validate_table_content(
  x = tun_epi_unit,
  table_name = "epi_units",
  eu_name = "shapeName",
  user_id = "fid"
)

dat <- extract_table(DATA_EPI_UNITS)
# dat
# attr(dat, "table_name")
# attr(dat, "valid")
# check_dataset_valid(dat)
