#' @title Import Geo Data from Files
#' @description
#' This function imports geographic data from files. It handles shapefiles
#' specifically, as they consist of multiple files. The function checks for
#' the presence of shapefiles and reads them accordingly.
#' @param x A character vector of file path(s) to the geographic data file(s).
#' @return A `sf` object representing the imported geographic data.
#' @details
#' This function is designed to read geographic data files, it's a wrapper
#' around the [sf::read_sf()] function. It checks if the input files are
#' shapefiles and handles them accordingly. If the input files are not
#' shapefiles, it reads them directly using [sf::read_sf()].
#' @examples
#' tun_files <-
#'   list.files(
#'     system.file(
#'       package = "riskintrodata",
#'       "samples",
#'       "tunisia",
#'       "epi_units"
#'     ),
#'     full.names = TRUE
#'   )
#' read_geo_file(tun_files)
#'
#' nga_files <- system.file(
#'   package = "riskintrodata",
#'   "samples",
#'   "nigeria",
#'   "epi_units",
#'   "NGA-ADM1.geojson"
#' )
#' read_geo_file(nga_files)
#' @export
read_geo_file <- function(x) {
  # Handling shapefiles differently because they are made up of multiple files
  shp <- x[endsWith(x, suffix = ".shp")]
  is_shp <- length(shp) > 0
  is_shp_not_unique <- length(shp) > 1
  is_shp_not_alone <- is_shp && length(x) > 1

  if (!is_shp) {
    polygon <- read_sf(x)
    return(polygon)
  }

  if (!is_shp_not_alone) {
    cli_warn(
      c(
        "Shapefiles should be multiple files, only one is selected.",
        "i" = "Please select all the files with the same name."
      )
    )
  } else if (is_shp_not_unique) {
    cli_abort(
      c(
        "Shapefiles should be multiple files, but only one shape file.",
        "i" = "Please select all the files with the same name."
      )
    )
  }
  read_sf(shp)
}


#' @export
#' @title Read Emission Risk Factor File
#' @description
#' Reads a text file containing emission risk factors for animal diseases.
#' The file should be in a tabular format with specific columns (see details).
#' @param filepath A character string specifying the path to the text file.
#' @details
#' The text file is expected to be in a tabular format with the following columns:
#'
#' Country information:
#'
#' - `iso3`: *character* - A three-letter ISO 3166-1 alpha-3 country code.
#' - `country`: *character* - The full name of the country.
#'
#' Disease information (should be the same for the whole dataset):
#' - `disease`: *character* - The name of the disease.
#' - `animal_category`: *character* - The category of animal ("Domestic" or "Wild").
#' - `species`: *character* - The species name affected by disease.
#'
#' Measures of control and surveillence, all are either 1 or 0 (0 = measure inplace, 1 = no measure inplace, i.e. 1 = there is a risk, 0 = there is no risk).
#' - `disease_notification`: *integer* - Indicator of notification
#' - `targeted_surveillance`: *integer* - Risk factor score for targeted surveillance efforts.
#' - `general_surveillance`: *integer* - Risk factor score for general surveillance activities.
#' - `screening`: *integer* - Risk factor score for screening measures.
#' - `precautions_at_the_borders`: *integer* - Risk factor score for precautions taken at borders.
#' - `slaughter`: *integer* - Risk factor score related to the slaughter process.
#' - `selective_killing_and_disposal`: *integer* - Risk factor score for selective killing and disposal procedures.
#' - `zoning`: *integer* - Risk factor score for zoning strategies.
#' - `official_vaccination`: *integer* - Risk factor score for official vaccination programs.
#'
#' Epidemiological status:
#' - `last_outbreak_end_date`: *Date* (YYYY-MM-DD) - The end date of the last outbreak.
#'
#' Animal commerce (indicators of level of illegality of commerce)
#' - `commerce_illegal`: *integer* -  either 1 or 0
#' - `commerce_legal`: *integer* -  either 1 or 0
#'
#' Other information:
#' - `data_source`: *character* - Reference or source of the data.
#' @examples
#' tun_erf_file <-
#'   system.file(
#'     package = "riskintrodata",
#'     "samples",
#'     "tunisia",
#'     "emission_risk_factor",
#'     "emission_risk_factors.csv"
#'   )
#' x <- read_emission_risk_factor_file(tun_erf_file)
#' x
read_emission_risk_factor_file <- function(filepath) {
  if (!file.exists(filepath)) {
    cli_abort(c(
      "The file {filepath} does not exist.",
      "x" = "Please provide a valid file."
    ))
  }

  if (!file_ext(filepath) %in% c("csv", "txt")) {
    cli_abort(c(
      "The file {filepath} is not a valid csv or txt file.",
      "x" = "Please provide a valid file."
    ))
  }

  read_delim(
    filepath,
    col_types = cols(
      iso3 = col_character(),
      country = col_character(),
      disease = col_character(),
      animal_category = col_character(),
      species = col_character(),
      disease_notification = col_integer(),
      targeted_surveillance = col_integer(),
      general_surveillance = col_integer(),
      screening = col_integer(),
      precautions_at_the_borders = col_integer(),
      slaughter = col_integer(),
      selective_killing_and_disposal = col_integer(),
      zoning = col_integer(),
      official_vaccination = col_integer(),
      last_outbreak_end_date = col_date(),
      commerce_illegal = col_integer(),
      commerce_legal = col_integer(),
      data_source = col_character()
    )
  )
}

#' @export
#' @title Read Raster File
#' @description
#' Reads a raster file from the specified path. The function checks if the
#' file exists and if it is a valid raster file (tif, tiff, png).
#' @param x A character string specifying the path to the raster file.
#' @return A `SpatRaster` object representing the raster data.
#' @examples
#' if (curl::has_internet()) {
#'   road_access_raster_file <- download_road_access_raster()
#'   ra_raster <- read_raster(x = road_access_raster_file)
#' }
read_raster <- function(x) {
  if (!file.exists(x)) {
    cli_abort(c(
      "The file {x} does not exist.",
      "x" = "Please provide a valid file."
    ))
  }

  if (!file_ext(x) %in% c("tiff", "tif", "tff", "png")) {
    cli_abort(c(
      "The file {x} is not a valid tif or tiff file.",
      "x" = "Please provide a valid file."
    ))
  }

  rast(x)
}
