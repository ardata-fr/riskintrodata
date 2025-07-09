
entry_points_fp <-
  list.files(
    system.file(
      package = "riskintrodata",
      "samples",
      "tunisia",
      "entry_points"
    ),
    full.names = TRUE
  )
entry_points <- readr::read_csv(entry_points_fp)


entry_points_mapped <- apply_mapping(
  dataset = entry_points,
  mapping = mapping_entry_points(
    point_name = "NAME",
    lng = "LONGITUDE_X",
    lat = "LATITUDE_Y",
    mode = "MODE",
    type = "TYPE",
    sources = "SOURCES"
  ),
  validate = TRUE
)

if(FALSE){
  entry_points_wrong <- entry_points
  entry_points_wrong$TYPE <- rep_len(c("PIF Maritime", "Passage contrebande", "'ELLO"),
                                     length.out = nrow(entry_points))
  entry_points_wrong$LONGITUDE_X <- rep_len(c(10.00, 15.00, NA_real_),
                                            length.out = nrow(entry_points))
  entry_points_wrong[23:30, "NAME"] <- NA_character_

  entry_points_wrong$NAME <- NULL


  entry_points_mapped <- apply_mapping(
    dataset = entry_points_wrong,
    mapping = mapping_entry_points(
      point_name = "NAME",
      lng = "LONGITUDE_X",
      lat = "LATITUDE_Y",
      mode = "MODE",
      type = "TYPE",
      sources = "SOURCES"
    ),
    validate = TRUE
  )
}


