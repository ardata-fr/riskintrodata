## ---- read-animal-mobility-tunisia ----
tun_animal_mobility <-
  list.files(
    system.file(
      package = "riskintrodata",
      "samples",
      "tunisia",
      "animal_mobility"
    ),
    full.names = TRUE
  )

x <- readr::read_delim(
  tun_animal_mobility,
  delim = ";"
)

DATA_ANIMAL_MOBILITY <- validate_table_content(
  x,
  name = "animal_mobility",
  o_name = "ORIGIN_NAME",
  o_lng = "ORIGIN_LONGITUDE_X",
  o_lat = "ORIGIN_LATITUDE_Y",
  d_name = "DESTINATION_NAME",
  d_lng = "DESTINATION_LONGITUDE_X",
  d_lat = "DESTINATION_LATITUDE_Y",
  quantity = "HEADCOUNT"
)

DATA_ANIMAL_MOBILITY
