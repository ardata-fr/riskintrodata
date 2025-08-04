## ---- read-animal-mobility-tunisia ----
tun_animal_mobility <-
  system.file(
    package = "riskintrodata",
    "samples",
    "tunisia",
    "animal_mobility", "ANIMAL_MOBILITY_raw.csv"
  )

x <- readr::read_csv(
  tun_animal_mobility,
)

DATA_ANIMAL_MOBILITY <- validate_dataset(
  x,
  table_name = "animal_mobility",
  o_name = "ORIGIN_NAME",
  o_lng = "ORIGIN_LONGITUDE_X",
  o_lat = "ORIGIN_LATITUDE_Y",
  d_name = "DESTINATION_NAME",
  d_lng = "DESTINATION_LONGITUDE_X",
  d_lat = "DESTINATION_LATITUDE_Y",
  quantity = "HEADCOUNT"
)

extract_dataset(DATA_ANIMAL_MOBILITY)
