## ---- read-epi-units-tunisia ----
tun_epi_files <-
  system.file(
    package = "riskintrodata",
    "samples",
    "tunisia",
    "epi_units", "tunisia_adm2_raw.gpkg"
  )

tun_epi_unit <- read_geo_file(tun_epi_files)

validate_dataset_content(
  x = tun_epi_unit,
  table_name = "epi_units",
  eu_name = "NAME_2",
  user_id = "GID_2"
) |> extract_dataset()

x <- validate_dataset_content(
  x = tun_epi_unit,
  table_name = "epi_units",
  eu_name = "NAME_ 2",
  user_id = "GID_ 2"
)
try(extract_dataset(x))
