#' @title Download Road Access Raster
#' @description
#' This function downloads a road access raster file from the 'GitHub' repository
#' located at <https://github.com/ardata-fr/road-access-raster> and saves it to
#' a specified destination file.
#' @param destfile A character string with the name where the downloaded file
#' is saved. If NULL, a temporary file is created.
#' @return The path to the downloaded file.
#' @examples
#' if (curl::has_internet()) {
#'   road_access_raster_file <- download_road_access_raster()
#' }
#' @export
download_road_access_raster <- function(destfile = NULL) {
  url <- "https://github.com/ardata-fr/road-access-raster/releases/download/v2015/2015_accessibility_to_cities_v1.0.tif"
  if (is.null(destfile)) {
    destfile <- tempfile(fileext = '.tif')
  }
  curl_download(url = url, destfile = destfile)
  # Check if the file was downloaded successfully
  if (!file.exists(destfile)) {
    stop("Failed to download the file.")
  }
  destfile
}
