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

test_that("validate_dataset handles non-sfc geometry without error", {
  library(sf)

  # Create test data with non-sfc geometry column
  test_data <- data.frame(
    eu_id = c("EU1", "EU2"),
    eu_name = c("Unit 1", "Unit 2"),
    geometry = c("POLYGON((0 0,1 0,1 1,0 1,0 0))", "POLYGON((1 0,2 0,2 1,1 1,1 0))")
  )

  # validate_dataset should NOT error, but return validation status
  expect_no_error({
    validation_result <- validate_dataset(
      x = test_data,
      table_name = "epi_units",
      eu_id = "eu_id",
      eu_name = "eu_name",
      geometry = "geometry"
    )
  })

  validation_result <- validate_dataset(
    x = test_data,
    table_name = "epi_units",
    eu_id = "eu_id",
    eu_name = "eu_name",
    geometry = "geometry"
  )

  # The validation should indicate that the dataset is not valid
  expect_false(is_dataset_valid(validation_result))

  # check_dataset_valid should error because geometry is not sfc
  expect_error(check_dataset_valid(validation_result))
})

# Entry Points validation tests ----
test_that("validate_dataset handles entry_points edge cases", {
  library(sf)

  # Test with missing required fields
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        name = c("Point A", "Point B"),
        longitude = c(10.5, 11.2),
        latitude = c(45.3, 46.1)
      ),
      table_name = "entry_points",
      point_name = "name",
      lng = "longitude",
      lat = "latitude"
    )
  })

  # Test with invalid longitude values
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        point_name = c("Point A", "Point B"),
        lng = c(190, -190),  # Invalid longitudes
        lat = c(45.3, 46.1)
      ),
      table_name = "entry_points",
      point_name = "point_name",
      lng = "lng",
      lat = "lat"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with invalid latitude values
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        point_name = c("Point A", "Point B"),
        lng = c(10.5, 11.2),
        lat = c(95, -95)  # Invalid latitudes
      ),
      table_name = "entry_points",
      point_name = "point_name",
      lng = "lng",
      lat = "lat"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with invalid mode values
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        point_name = c("Point A", "Point B"),
        lng = c(10.5, 11.2),
        lat = c(45.3, 46.1),
        mode = c("INVALID", "C")  # Invalid mode value
      ),
      table_name = "entry_points",
      point_name = "point_name",
      lng = "lng",
      lat = "lat",
      mode = "mode"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with invalid type values
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        point_name = c("Point A", "Point B"),
        lng = c(10.5, 11.2),
        lat = c(45.3, 46.1),
        type = c("INVALID", "AIR")  # Invalid type value
      ),
      table_name = "entry_points",
      point_name = "point_name",
      lng = "lng",
      lat = "lat",
      type = "type"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with non-character point names
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        point_name = c(123, 456),  # Numeric instead of character
        lng = c(10.5, 11.2),
        lat = c(45.3, 46.1)
      ),
      table_name = "entry_points",
      point_name = "point_name",
      lng = "lng",
      lat = "lat"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with NA values in required fields
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        point_name = c("Point A", NA_character_),  # Missing required value
        lng = c(10.5, 11.2),
        lat = c(45.3, 46.1)
      ),
      table_name = "entry_points",
      point_name = "point_name",
      lng = "lng",
      lat = "lat"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with non-numeric coordinates
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        point_name = c("Point A", "Point B"),
        lng = c("10.5", "11.2"),  # Character instead of numeric
        lat = c(45.3, 46.1)
      ),
      table_name = "entry_points",
      point_name = "point_name",
      lng = "lng",
      lat = "lat"
    )
    expect_false(is_dataset_valid(validation_result))
  })
})

# Emission Risk Factors validation tests ----
test_that("validate_dataset handles emission_risk_factors edge cases", {

  # Test with missing required iso3
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        iso3 = c(NA_character_, "USA"),  # Missing required value
        country = c("Algeria", "United States"),
        disease = c("FMD", "FMD"),
        animal_category = c("Domestic", "Domestic"),
        species = c("Cattle", "Cattle"),
        disease_notification = c(1L, 0L),
        targeted_surveillance = c(1L, 1L),
        general_surveillance = c(0L, 1L),
        screening = c(1L, 0L),
        precautions_at_the_borders = c(0L, 1L),
        slaughter = c(1L, 1L),
        selective_killing_and_disposal = c(0L, 1L),
        zoning = c(1L, 0L),
        official_vaccination = c(1L, 1L),
        last_outbreak_end_date = c(as.Date("2020-01-01"), as.Date("2021-01-01")),
        commerce_illegal = c(0L, 1L),
        commerce_legal = c(1L, 0L)
      ),
      table_name = "emission_risk_factors",
      iso3 = "iso3",
      country = "country",
      disease = "disease",
      animal_category = "animal_category",
      species = "species",
      disease_notification = "disease_notification",
      targeted_surveillance = "targeted_surveillance",
      general_surveillance = "general_surveillance",
      screening = "screening",
      precautions_at_the_borders = "precautions_at_the_borders",
      slaughter = "slaughter",
      selective_killing_and_disposal = "selective_killing_and_disposal",
      zoning = "zoning",
      official_vaccination = "official_vaccination",
      last_outbreak_end_date = "last_outbreak_end_date",
      commerce_illegal = "commerce_illegal",
      commerce_legal = "commerce_legal"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with duplicate iso3 values
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        iso3 = c("DZA", "DZA"),  # Duplicates not allowed
        country = c("Algeria", "Algeria"),
        disease = c("FMD", "FMD"),
        animal_category = c("Domestic", "Domestic"),
        species = c("Cattle", "Cattle"),
        disease_notification = c(1L, 0L),
        targeted_surveillance = c(1L, 1L),
        general_surveillance = c(0L, 1L),
        screening = c(1L, 0L),
        precautions_at_the_borders = c(0L, 1L),
        slaughter = c(1L, 1L),
        selective_killing_and_disposal = c(0L, 1L),
        zoning = c(1L, 0L),
        official_vaccination = c(1L, 1L),
        last_outbreak_end_date = c(as.Date("2020-01-01"), as.Date("2021-01-01")),
        commerce_illegal = c(0L, 1L),
        commerce_legal = c(1L, 0L)
      ),
      table_name = "emission_risk_factors",
      iso3 = "iso3",
      country = "country",
      disease = "disease",
      animal_category = "animal_category",
      species = "species",
      disease_notification = "disease_notification",
      targeted_surveillance = "targeted_surveillance",
      general_surveillance = "general_surveillance",
      screening = "screening",
      precautions_at_the_borders = "precautions_at_the_borders",
      slaughter = "slaughter",
      selective_killing_and_disposal = "selective_killing_and_disposal",
      zoning = "zoning",
      official_vaccination = "official_vaccination",
      last_outbreak_end_date = "last_outbreak_end_date",
      commerce_illegal = "commerce_illegal",
      commerce_legal = "commerce_legal"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with multiple diseases (should fail)
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        iso3 = c("DZA", "USA"),
        country = c("Algeria", "United States"),
        disease = c("FMD", "Anthrax"),  # Multiple diseases not allowed
        animal_category = c("Domestic", "Domestic"),
        species = c("Cattle", "Cattle"),
        disease_notification = c(1L, 0L),
        targeted_surveillance = c(1L, 1L),
        general_surveillance = c(0L, 1L),
        screening = c(1L, 0L),
        precautions_at_the_borders = c(0L, 1L),
        slaughter = c(1L, 1L),
        selective_killing_and_disposal = c(0L, 1L),
        zoning = c(1L, 0L),
        official_vaccination = c(1L, 1L),
        last_outbreak_end_date = c(as.Date("2020-01-01"), as.Date("2021-01-01")),
        commerce_illegal = c(0L, 1L),
        commerce_legal = c(1L, 0L)
      ),
      table_name = "emission_risk_factors"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with invalid binary values (should be 0, 1, or NA)
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        iso3 = c("DZA", "USA"),
        country = c("Algeria", "United States"),
        disease = c("FMD", "FMD"),
        animal_category = c("Domestic", "Domestic"),
        species = c("Cattle", "Cattle"),
        disease_notification = c(2L, 0L),  # Invalid value (should be 0, 1, or NA)
        targeted_surveillance = c(1L, 1L),
        general_surveillance = c(0L, 1L),
        screening = c(1L, 0L),
        precautions_at_the_borders = c(0L, 1L),
        slaughter = c(1L, 1L),
        selective_killing_and_disposal = c(0L, 1L),
        zoning = c(1L, 0L),
        official_vaccination = c(1L, 1L),
        last_outbreak_end_date = c(as.Date("2020-01-01"), as.Date("2021-01-01")),
        commerce_illegal = c(0L, 1L),
        commerce_legal = c(1L, 0L)
      ),
      table_name = "emission_risk_factors",
      iso3 = "iso3",
      country = "country",
      disease = "disease",
      animal_category = "animal_category",
      species = "species",
      disease_notification = "disease_notification",
      targeted_surveillance = "targeted_surveillance",
      general_surveillance = "general_surveillance",
      screening = "screening",
      precautions_at_the_borders = "precautions_at_the_borders",
      slaughter = "slaughter",
      selective_killing_and_disposal = "selective_killing_and_disposal",
      zoning = "zoning",
      official_vaccination = "official_vaccination",
      last_outbreak_end_date = "last_outbreak_end_date",
      commerce_illegal = "commerce_illegal",
      commerce_legal = "commerce_legal"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with non-Date outbreak end date
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        iso3 = c("DZA", "USA"),
        country = c("Algeria", "United States"),
        disease = c("FMD", "FMD"),
        animal_category = c("Domestic", "Domestic"),
        species = c("Cattle", "Cattle"),
        disease_notification = c(1L, 0L),
        targeted_surveillance = c(1L, 1L),
        general_surveillance = c(0L, 1L),
        screening = c(1L, 0L),
        precautions_at_the_borders = c(0L, 1L),
        slaughter = c(1L, 1L),
        selective_killing_and_disposal = c(0L, 1L),
        zoning = c(1L, 0L),
        official_vaccination = c(1L, 1L),
        last_outbreak_end_date = c("2020-01-01", "2021-01-01"),  # Character instead of Date
        commerce_illegal = c(0L, 1L),
        commerce_legal = c(1L, 0L)
      ),
      table_name = "emission_risk_factors",
      iso3 = "iso3",
      country = "country",
      disease = "disease",
      animal_category = "animal_category",
      species = "species",
      disease_notification = "disease_notification",
      targeted_surveillance = "targeted_surveillance",
      general_surveillance = "general_surveillance",
      screening = "screening",
      precautions_at_the_borders = "precautions_at_the_borders",
      slaughter = "slaughter",
      selective_killing_and_disposal = "selective_killing_and_disposal",
      zoning = "zoning",
      official_vaccination = "official_vaccination",
      last_outbreak_end_date = "last_outbreak_end_date",
      commerce_illegal = "commerce_illegal",
      commerce_legal = "commerce_legal"
    )
    expect_false(is_dataset_valid(validation_result))
  })
})

# Animal Mobility validation tests ----
test_that("validate_dataset handles animal_mobility edge cases", {

  # Test with invalid longitude values
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        o_iso3 = c("DZA", "USA"),
        o_name = c("Algeria", "United States"),
        o_lng = c(200, -200),  # Invalid longitudes
        o_lat = c(25.0, 40.0),
        d_lng = c(10.0, 15.0),
        d_lat = c(45.0, 50.0),
        quantity = c(100, 200)
      ),
      table_name = "animal_mobility",
      o_iso3 = "o_iso3",
      o_name = "o_name",
      o_lng = "o_lng",
      o_lat = "o_lat",
      d_lng = "d_lng",
      d_lat = "d_lat",
      quantity = "quantity"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with invalid latitude values
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        o_iso3 = c("DZA", "USA"),
        o_name = c("Algeria", "United States"),
        o_lng = c(2.0, -100.0),
        o_lat = c(95.0, -95.0),  # Invalid latitudes
        d_lng = c(10.0, 15.0),
        d_lat = c(45.0, 50.0),
        quantity = c(100, 200)
      ),
      table_name = "animal_mobility",
      o_iso3 = "o_iso3",
      o_name = "o_name",
      o_lng = "o_lng",
      o_lat = "o_lat",
      d_lng = "d_lng",
      d_lat = "d_lat",
      quantity = "quantity"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with missing required destination coordinates
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        o_iso3 = c("DZA", "USA"),
        o_name = c("Algeria", "United States"),
        o_lng = c(2.0, -100.0),
        o_lat = c(25.0, 40.0),
        d_lng = c(NA_real_, 15.0),  # Missing required value
        d_lat = c(45.0, 50.0),
        quantity = c(100, 200)
      ),
      table_name = "animal_mobility",
      o_iso3 = "o_iso3",
      o_name = "o_name",
      o_lng = "o_lng",
      o_lat = "o_lat",
      d_lng = "d_lng",
      d_lat = "d_lat",
      quantity = "quantity"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with non-numeric coordinates
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        o_iso3 = c("DZA", "USA"),
        o_name = c("Algeria", "United States"),
        o_lng = c("2.0", "-100.0"),  # Character instead of numeric
        o_lat = c(25.0, 40.0),
        d_lng = c(10.0, 15.0),
        d_lat = c(45.0, 50.0),
        quantity = c(100, 200)
      ),
      table_name = "animal_mobility",
      o_iso3 = "o_iso3",
      o_name = "o_name",
      o_lng = "o_lng",
      o_lat = "o_lat",
      d_lng = "d_lng",
      d_lat = "d_lat",
      quantity = "quantity"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with non-numeric quantity
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        o_iso3 = c("DZA", "USA"),
        o_name = c("Algeria", "United States"),
        o_lng = c(2.0, -100.0),
        o_lat = c(25.0, 40.0),
        d_lng = c(10.0, 15.0),
        d_lat = c(45.0, 50.0),
        quantity = c("100", "200")  # Character instead of numeric
      ),
      table_name = "animal_mobility",
      o_iso3 = "o_iso3",
      o_name = "o_name",
      o_lng = "o_lng",
      o_lat = "o_lat",
      d_lng = "d_lng",
      d_lat = "d_lat",
      quantity = "quantity"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test with empty string names (should fail)
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        o_iso3 = c("DZA", "USA"),
        o_name = c("", "United States"),  # Empty string not allowed
        o_lng = c(2.0, -100.0),
        o_lat = c(25.0, 40.0),
        d_lng = c(10.0, 15.0),
        d_lat = c(45.0, 50.0),
        quantity = c(100, 200)
      ),
      table_name = "animal_mobility",
      o_iso3 = "o_iso3",
      o_name = "o_name",
      o_lng = "o_lng",
      o_lat = "o_lat",
      d_lng = "d_lng",
      d_lat = "d_lat",
      quantity = "quantity"
    )
    expect_false(is_dataset_valid(validation_result))
  })
})

# Additional edge case tests ----
test_that("validate_dataset handles general edge cases", {

  # Test with invalid table name
  expect_error({
    validate_dataset(
      x = data.frame(x = 1, y = 2),
      table_name = "invalid_table_name"
    )
  }, "Invalid table name")

  # Test with empty data frame
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(),
      table_name = "epi_units",
      eu_name = "name",
      geometry = "geom"
    )
  })

  # Test with missing columns in mapping
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        existing_col = c("A", "B"),
        another_col = c(1, 2)
      ),
      table_name = "epi_units",
      eu_name = "missing_column",  # Column doesn't exist
      geometry = "also_missing"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test epi_units with duplicate eu_id values (if eu_id is provided)
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        eu_id = c("EU1", "EU1"),  # Duplicates not allowed
        eu_name = c("Unit 1", "Unit 2"),
        geometry = c("POLYGON((0 0,1 0,1 1,0 1,0 0))", "POLYGON((1 0,2 0,2 1,1 1,1 0))")
      ),
      table_name = "epi_units",
      eu_id = "eu_id",
      eu_name = "eu_name",
      geometry = "geometry"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test epi_units with missing eu_name values
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        eu_id = c("EU1", "EU2"),
        eu_name = c("Unit 1", NA_character_),  # Missing required value
        geometry = c("POLYGON((0 0,1 0,1 1,0 1,0 0))", "POLYGON((1 0,2 0,2 1,1 1,1 0))")
      ),
      table_name = "epi_units",
      eu_id = "eu_id",
      eu_name = "eu_name",
      geometry = "geometry"
    )
    expect_false(is_dataset_valid(validation_result))
  })

  # Test epi_units with empty eu_name values
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        eu_id = c("EU1", "EU2"),
        eu_name = c("Unit 1", ""),  # Empty string not allowed
        geometry = c("POLYGON((0 0,1 0,1 1,0 1,0 0))", "POLYGON((1 0,2 0,2 1,1 1,1 0))")
      ),
      table_name = "epi_units",
      eu_id = "eu_id",
      eu_name = "eu_name",
      geometry = "geometry"
    )
    expect_false(is_dataset_valid(validation_result))
  })
})

test_that("validate_dataset handles entry_points geometry edge cases", {
  library(sf)

  # Test entry_points with non-POINT geometry (should fail)
  entry_points_with_polygons <- st_as_sf(
    data.frame(
      point_name = c("Point A", "Point B"),
      lng = c(10.5, 11.2),
      lat = c(45.3, 46.1),
      geometry = st_sfc(
        st_polygon(list(matrix(c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE))),
        st_polygon(list(matrix(c(1, 0, 2, 0, 2, 1, 1, 1, 1, 0), ncol = 2, byrow = TRUE)))
      )
    ),
    crs = 4326
  )

  # TODO -----
  # expect_no_error({
  #   validation_result <- validate_dataset(
  #     x = entry_points_with_polygons,
  #     table_name = "entry_points",
  #     point_name = "point_name",
  #     lng = "lng",
  #     lat = "lat",
  #     geometry = "geometry"
  #   )
  #   expect_false(is_dataset_valid(validation_result))
  # })

  # Test entry_points with empty geometry
  entry_points_empty_geom <- st_as_sf(
    data.frame(
      point_name = c("Point A", "Point B"),
      lng = c(10.5, 11.2),
      lat = c(45.3, 46.1),
      geometry = st_sfc(
        st_point(),  # Empty point
        st_point(c(11.2, 46.1))
      )
    ),
    crs = 4326
  )

  # TODO -----
  # expect_no_error({
  #   validation_result <- validate_dataset(
  #     x = entry_points_empty_geom,
  #     table_name = "entry_points",
  #     point_name = "point_name",
  #     lng = "lng",
  #     lat = "lat",
  #     geometry = "geometry"
  #   )
  #   expect_false(is_dataset_valid(validation_result))
  # })
})

test_that("validate_dataset handles boundary coordinate values", {

  # Test with boundary longitude values (exactly ±180)
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        point_name = c("Point A", "Point B"),
        lng = c(180, -180),  # Boundary values
        lat = c(45.3, 46.1)
      ),
      table_name = "entry_points",
      point_name = "point_name",
      lng = "lng",
      lat = "lat"
    )
    # These should be valid (boundaries are typically inclusive)
  })

  # Test with boundary latitude values (exactly ±90)
  expect_no_error({
    validation_result <- validate_dataset(
      x = data.frame(
        point_name = c("Point A", "Point B"),
        lng = c(10.5, 11.2),
        lat = c(90, -90)  # Boundary values
      ),
      table_name = "entry_points",
      point_name = "point_name",
      lng = "lng",
      lat = "lat"
    )
    # These should be valid (boundaries are typically inclusive)
  })
})


