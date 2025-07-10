# read entry points data from Tunisia ----
tun_entry_points <- system.file(
  package = "riskintrodata",
  "samples",
  "tunisia",
  "entry_points",
  "BORDER_CROSSING_POINTS.csv"
)

x <- readr::read_delim(
  tun_entry_points
)

DATA_ENTRY_POINTS <- validate_table_content(
  x = x,
  table_name = "entry_points",
  point_name = "NAME",
  lng = "LONGITUDE_X",
  lat = "LATITUDE_Y",
  mode = "MODE",
  type = "TYPE"
)

DATA_ENTRY_POINTS
