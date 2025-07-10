
#' @importFrom sf read_sf
#' @importFrom readr read_csv
get_riskintro_example_datasets <- function(
    example = c("tunisia", "nigeria"),
    cleaned = TRUE
    ){

  example <- match.arg(example)

  out <- list()

  base_path <- system.file(package = 'riskintrodata',"samples", example)

  if (cleaned) {
    epi_units_fp <- file.path(base_path, "epi_units", "tunisia_adm2_clean.gpkg" )

  } else {
    epi_units_fp <- file.path(base_path, "epi_units", "tunisia_adm2_raw.gpkg" )
    animal_mobility_fp <- file.path(base_path, "animal_mobility", "ANIMAL_MOBILITY.csv" )
  }

  out
}



