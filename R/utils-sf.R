latlng_to_sf <- function(dat) {
  if (all(c("lat", "lng") %in% colnames(dat))) {
    dat <- st_as_sf(dat, coords = c("lng", "lat"), crs = 4326)
  }
  dat
}
