## ---- read-epi-units-tunisia ----
tun_epi_files <-
  list.files(
    system.file(
      package = "riskintrodata",
      "samples",
      "tunisia",
      "epi_units"
    ),
    full.names = TRUE
  )

tun_epi_unit <- read_geo_file(tun_epi_files)

DATA_EPI_UNITS <- validate_table_content(
  x = tun_epi_unit,
  name = "epi_units",
  eu_name = "shapeName",
  user_id = "fid"
)

DATA_EPI_UNITS
