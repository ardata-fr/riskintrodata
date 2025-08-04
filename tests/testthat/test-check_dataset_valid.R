test_that("error when invalid", {
  zz <- mtcars
  expect_error(check_dataset_valid(zz))
})

test_that("check_dataset_valid errors as expected", {
  tun_epi_files <-
    system.file(
      package = "riskintrodata",
      "samples",
      "tunisia",
      "epi_units", "tunisia_adm2_raw.gpkg"
    )

  tun_epi_unit <- read_geo_file(tun_epi_files)

  x <- validate_dataset(
    x = tun_epi_unit,
    table_name = "epi_units",
    eu_name = "NAME_2",
    user_id = "GID_2"
  )
  testthat::expect_silent(check_dataset_valid(x))

  x <- validate_dataset(
    x = tun_epi_unit,
    table_name = "epi_units",
    eu_name = "shape Name",
    user_id = "fid"
  )
  testthat::expect_error(check_dataset_valid(x))
})


