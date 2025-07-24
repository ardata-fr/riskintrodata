#' @title Download Road Access Raster
#' @description
#' This function downloads a road access raster file from the 'GitHub' repository
#' located at <https://github.com/ardata-fr/road-access-raster> and saves it to
#' a specified destination file.
#' @param force if TRUE, the function will re-download the file even if it already exists
#' in the cache directory.
#' @return The path to the downloaded file.
#' @examples
#' \dontshow{
#' riskintrodata_dummy_setup()
#' }
#' if (curl::has_internet()) {
#'   road_access_raster_file <- download_road_access_raster()
#' }
#' @export
download_road_access_raster <- function(force = FALSE) {

  url <- "https://github.com/ardata-fr/road-access-raster/releases/download/v2015/2015_accessibility_to_cities_v1.0.tif"

  cache_dir <- riskintrodata_cache_dir()
  destfile <- file.path(cache_dir, basename(url))

  if (!file.exists(destfile) || isTRUE(force)) {
    sys_timeout <- getOption('timeout')
    curl_download(url = url, destfile = destfile)
  }

  # Check if the file was downloaded successfully
  if (!file.exists(destfile)) {
    stop("Failed to download the file.")
  }
  destfile
}
