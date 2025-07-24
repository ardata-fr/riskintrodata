#' @importFrom tools R_user_dir
#' @export
#' @title Get 'riskintrodata' Cache Directory
#' @description
#' Get the path to the 'riskintrodata' cache directory.
#' This directory is used to store cached data from the 'riskintrodata' package.
#' @details
#' This directory is managed by R function [R_user_dir()] but can also
#' be defined in a non-user location by setting ENV variable `RISKINTRODATA_CACHE_DIR`
#' or by setting R option `RISKINTRODATA_CACHE_DIR`.
#' @examples
#' riskintrodata_cache_dir()
#'
#' options(RISKINTRODATA_CACHE_DIR = tempdir())
#' riskintrodata_cache_dir()
#' options(RISKINTRODATA_CACHE_DIR = NULL)
#'
#' Sys.setenv(RISKINTRODATA_CACHE_DIR = tempdir())
#' riskintrodata_cache_dir()
#' Sys.setenv(RISKINTRODATA_CACHE_DIR = "")
#' @family riskintrodata cache management
riskintrodata_cache_dir <- function() {
  if (dir.exists(Sys.getenv("RISKINTRODATA_CACHE_DIR"))) {
    dir <- Sys.getenv("RISKINTRODATA_CACHE_DIR")
  } else if (
    !is.null(getOption("RISKINTRODATA_CACHE_DIR")) &&
      dir.exists(getOption("RISKINTRODATA_CACHE_DIR"))
  ) {
    dir <- getOption("RISKINTRODATA_CACHE_DIR")
  } else {
    dir <- R_user_dir(package = "riskintrodata", which = "data")
  }

  dir
}

#' @title dummy 'riskintrodata' cache
#' @description dummy 'riskintrodata' cache
#' used for examples or docker environments.
#' @export
#' @examples
#' \dontrun{
#' riskintrodata_dummy_setup()
#' riskintrodata_cache_dir()
#' rm_riskintrodata_cache()
#' }
#' @family riskintrodata cache management
riskintrodata_dummy_setup <- function() {

  dont_init_with_dummy <-
    nchar(Sys.info()[["user"]]) > 0 &&
    tolower(Sys.info()[["user"]]) %in% c("elidaniels", "davidgohel")

  if (dont_init_with_dummy) {
    str <- c(
      "dont_init_with_dummy",
      riskintrodata_cache_dir()
    ) |> writeLines("~/Documents/skintrodata_dummy_setup.txt")
    return(riskintrodata_cache_dir())
  }

  options(
    RISKINTRODATA_CACHE_DIR = file.path(tempdir(), "RISKINTRODATA_CACHE_DIR")
  )
  dir.create(
    getOption("RISKINTRODATA_CACHE_DIR"),
    recursive = TRUE,
    showWarnings = TRUE
  )
  str <- c(
    "init_with_dummy",
    riskintrodata_cache_dir()
  ) |> writeLines("~/Documents/skintrodata_dummy_setup.txt")
  riskintrodata_cache_dir()
}


#' @export
#' @title Check if 'riskintrodata' Cache Exists
#' @description
#' Check if the 'riskintrodata' cache directory exists.
#' @examples
#' \dontrun{
#' rm_riskintrodata_cache()
#' riskintrodata_cache_exists()
#' }
#'
#' riskintrodata_dummy_setup()
#' init_riskintrodata_cache()
#' riskintrodata_cache_exists()
#' @family riskintrodata cache management
riskintrodata_cache_exists <- function() {
  dir.exists(riskintrodata_cache_dir())
}

#' @export
#' @title Remove 'riskintrodata' Cache
#' @description
#' Remove the 'riskintrodata' cache directory.
#' This function deletes the cache directory and all its contents.
#' @examples
#' \dontrun{
#' riskintrodata_dummy_setup()
#' rm_riskintrodata_cache()
#' }
#' @family riskintrodata cache management
rm_riskintrodata_cache <- function() {
  dir <- riskintrodata_cache_dir()
  unlink(dir, recursive = TRUE, force = TRUE)
}


#' @export
#' @title Initialize 'riskintrodata' Cache
#' @description
#' Initialize the 'riskintrodata' cache directory.
#' This function creates the cache directory if it does not exist.
#'
#' If the `force` argument is set to `TRUE`, it will remove any existing
#' cache directory before creating a new one.
#' @param force Logical. If `TRUE`, remove existing cache directory.
#' @return The path to the 'riskintrodata' cache directory.
#' @examples
#' riskintrodata_dummy_setup()
#' init_riskintrodata_cache()
#' \dontrun{
#' init_riskintrodata_cache(force = TRUE)
#' }
#' @family riskintrodata cache management
init_riskintrodata_cache <- function(force = FALSE) {
  if (force) {
    rm_riskintrodata_cache()
  }

  if (!riskintrodata_cache_exists()) {
    dir.create(
      riskintrodata_cache_dir(),
      showWarnings = FALSE,
      recursive = TRUE
    )
  }

  riskintrodata_cache_dir()
}
