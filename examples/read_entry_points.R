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

DATA_ENTRY_POINTS <- validate_dataset(
  x = x,
  table_name = "entry_points",
  point_name = "NAME",
  lng = "LONGITUDE_X",
  lat = "LATITUDE_Y",
  mode = "MODE",
  type = "TYPE"
)

DATA_ENTRY_POINTS

DATA_ENTRY_POINTS <- validate_dataset(
  x = x,
  table_name = "entry_points",
  point_name = "NAME",
  lng = "LONGITUDE_X",
  lat = "LATITUDE_Y",
  mode = "MODE",
  type = "TYPE",
  sources = "SOURCES"
)
extract_dataset(DATA_ENTRY_POINTS)





entry_points_wrong <- x
entry_points_wrong$TYPE <- rep_len(c("PIF Maritime", "Passage contrebande", "'ELLO"),
                                   length.out = nrow(x))
entry_points_wrong$LONGITUDE_X <- rep_len(c(10.00, 15.00, NA_real_),
                                          length.out = nrow(x))
entry_points_wrong[23:30, "NAME"] <- NA_character_

entry_points_wrong$NAME <- NULL

entry_points_mapped <- validate_dataset(
  x = entry_points_wrong,
  table_name = "entry_points",
  point_name = "NAME",
  lng = "LONGITUDE_X",
  lat = "LATITUDE_Y",
  mode = "MODE",
  type = "TYPE",
  sources = "SOURCES"
)
try(extract_dataset(entry_points_mapped))
