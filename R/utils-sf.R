latlng_to_sf <- function(dat) {
  if (all(c("lat", "lng") %in% colnames(dat))) {

    # Avoid scary warning message when the dataset has no rows
    if (nrow(dat) == 0) {
      dat <- suppressWarnings(st_as_sf(dat, coords = c("lng", "lat"), crs = 4326))
    } else {
      dat <- st_as_sf(dat, coords = c("lng", "lat"), crs = 4326)
    }
  }
  dat
}
