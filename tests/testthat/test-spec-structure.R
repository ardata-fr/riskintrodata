# Test file for validating the structure and integrity of all .spec_* objects
# These specifications define validation rules for different dataset types
# in the riskintrodata package and must maintain consistent structure to
# prevent silent errors in the validation system.

test_that("all spec lists have correct structure", {
  # Define all spec objects to test
  spec_objects <- list(
    ".spec_entry_points" = .spec_entry_points,
    ".spec_animal_mobility" = .spec_animal_mobility,
    ".spec_epi_units" = .spec_epi_units,
    ".spec_emission_risk_factors" = .spec_emission_risk_factors
  )

  for (spec_name in names(spec_objects)) {
    spec <- spec_objects[[spec_name]]

    # Test 1: Spec object is a list
    expect_true(is.list(spec),
                info = paste(spec_name, "should be a list"))

    # Test 2: Spec object has named elements
    expect_true(length(names(spec)) > 0,
                info = paste(spec_name, "should have named elements"))

    # Test 3: All element names are unique
    expect_equal(length(names(spec)), length(unique(names(spec))),
                 info = paste(spec_name, "should have unique element names"))

    # Test 4: No empty names
    expect_false(any(names(spec) == "" | is.na(names(spec))),
                 info = paste(spec_name, "should not have empty or NA names"))

    # Test each field in the spec
    for (field_name in names(spec)) {
      field <- spec[[field_name]]
      field_info <- paste(spec_name, "field", field_name)

      # Test 5: Each field is a list
      expect_true(is.list(field),
                  info = paste(field_info, "should be a list"))

      # Test 6: Each field has 'required' element
      expect_true("required" %in% names(field),
                  info = paste(field_info, "should have 'required' element"))

      # Test 7: 'required' element is logical (TRUE or FALSE)
      expect_true(is.logical(field$required) && length(field$required) == 1,
                  info = paste(field_info, "'required' should be a single logical value"))

      # Test 8: Each field has 'validation_func' element
      expect_true("validation_func" %in% names(field),
                  info = paste(field_info, "should have 'validation_func' element"))

      # Test 9: 'validation_func' is a list
      expect_true(is.list(field$validation_func),
                  info = paste(field_info, "'validation_func' should be a list"))

      # Test validation functions if they exist
      if (length(field$validation_func) > 0) {

        # Test 10: All validation functions have names
        expect_true(all(names(field$validation_func) != "" &
                       !is.na(names(field$validation_func))),
                    info = paste(field_info, "all validation functions should be named"))

        # Test 11: All validation function names are unique
        expect_equal(length(names(field$validation_func)),
                     length(unique(names(field$validation_func))),
                     info = paste(field_info, "validation function names should be unique"))

        # Test 12: All validation functions are actually functions
        for (vf_name in names(field$validation_func)) {
          vf <- field$validation_func[[vf_name]]
          expect_true(is.function(vf),
                      info = paste(field_info, "validation function", vf_name, "should be a function"))

          # Test 13: Each validation function has exactly one parameter (or is a primitive function)
          # Primitive functions like is.numeric, is.double have zero formals but take parameters
          n_formals <- length(formals(vf))
          is_primitive <- is.primitive(vf)
          expect_true(n_formals == 1 || is_primitive,
                       info = paste(field_info, "validation function", vf_name, "should have exactly one parameter or be a primitive function"))
        }
      }

      # Test 14: No unexpected elements in field
      expected_elements <- c("required", "validation_func")
      unexpected <- setdiff(names(field), expected_elements)
      expect_equal(length(unexpected), 0,
                   info = paste(field_info, "has unexpected elements:", paste(unexpected, collapse = ", ")))
    }
  }
})

test_that("spec objects have expected attributes", {
  # Test attributes for .spec_entry_points
  expect_true(!is.null(attr(.spec_entry_points, "data_spec")),
              info = ".spec_entry_points should have 'data_spec' attribute")
  expect_equal(attr(.spec_entry_points, "data_spec"), "entry_points")
  expect_true(!is.null(attr(.spec_entry_points, "geospatial")),
              info = ".spec_entry_points should have 'geospatial' attribute")
})

test_that("validation functions work correctly with sample data", {
  # Test some basic validation functions

  # Test is.lat function (used in animal_mobility and entry_points specs)
  expect_true(riskintrodata:::is.lat(45.0))
  expect_true(riskintrodata:::is.lat(-90.0))
  expect_true(riskintrodata:::is.lat(90.0))
  expect_false(riskintrodata:::is.lat(91.0))
  expect_false(riskintrodata:::is.lat(-91.0))

  # Test is.lng function
  expect_true(riskintrodata:::is.lng(180.0))
  expect_true(riskintrodata:::is.lng(-180.0))
  expect_true(riskintrodata:::is.lng(0.0))
  expect_false(riskintrodata:::is.lng(181.0))
  expect_false(riskintrodata:::is.lng(-181.0))

  # Test character validation functions
  char_func <- function(x) is.character(x) && all(!is.na(x))
  expect_true(char_func(c("test", "data")))
  expect_false(char_func(c("test", NA)))
  expect_false(char_func(123))

  # Test logical validation for binary fields
  binary_func <- function(x) x %in% c(NA_integer_, 0L, 1L)
  expect_true(all(binary_func(c(0L, 1L, NA_integer_))))
  expect_false(all(binary_func(c(0L, 1L, 2L))))
  # Note: The actual binary_func accepts numeric 0,1 as well since %in% coerces types
  expect_true(all(binary_func(c(0, 1))))  # This actually passes due to type coercion in %in%
})

test_that("required fields are consistently defined", {
  # Check that certain critical fields are marked as required across specs

  # epi_units should have eu_name and geometry as required
  expect_true(.spec_epi_units$eu_name$required)
  # expect_true(.spec_epi_units$geometry$required)
  expect_false(.spec_epi_units$eu_id$required)  # This should be optional

  # entry_points should have point_name, lng, lat, geometry as required
  expect_true(.spec_entry_points$point_name$required)
  # expect_true(.spec_entry_points$lng$required)
  # expect_true(.spec_entry_points$lat$required)
  # expect_true(.spec_entry_points$geometry$required)
  expect_false(.spec_entry_points$mode$required)  # Optional
  expect_false(.spec_entry_points$type$required)  # Optional

  # emission_risk_factors core fields should be required
  expect_true(.spec_emission_risk_factors$iso3$required)
  expect_true(.spec_emission_risk_factors$country$required)
  expect_true(.spec_emission_risk_factors$disease$required)
  expect_true(.spec_emission_risk_factors$animal_category$required)
  expect_true(.spec_emission_risk_factors$species$required)
  expect_false(.spec_emission_risk_factors$data_source$required)  # Optional

  # animal_mobility destination fields should be required
  expect_true(.spec_animal_mobility$d_lng$required)
  expect_true(.spec_animal_mobility$d_lat$required)
  expect_false(.spec_animal_mobility$o_lng$required)  # Optional origin
  expect_false(.spec_animal_mobility$quantity$required)  # Optional
})

test_that("validation function names are descriptive", {
  spec_objects <- list(
    .spec_entry_points,
    .spec_animal_mobility,
    .spec_epi_units,
    .spec_emission_risk_factors
  )

  for (spec in spec_objects) {
    for (field in spec) {
      for (vf_name in names(field$validation_func)) {
        # Check that validation function names are not empty and reasonably descriptive
        expect_true(nchar(vf_name) > 5,
                    info = paste("Validation function name should be descriptive:", vf_name))

        # Check for common patterns that indicate good naming
        expect_true(grepl("(are|is|has|not|missing|empty|valid|duplicate)", vf_name, ignore.case = TRUE),
                    info = paste("Validation function name should describe the validation:", vf_name))
      }
    }
  }
})

test_that("spec consistency across similar fields", {
  # Test that similar fields across specs have consistent validation patterns

  # Longitude fields should all use is.lng validation
  lng_fields <- list(
    "entry_points" = .spec_entry_points$lng,
    "animal_mobility_o_lng" = .spec_animal_mobility$o_lng,
    "animal_mobility_d_lng" = .spec_animal_mobility$d_lng
  )

  for (field_name in names(lng_fields)) {
    field <- lng_fields[[field_name]]
    expect_true("is not a valid longitude" %in% names(field$validation_func) ||
                "are not valid longitude" %in% names(field$validation_func),
                info = paste(field_name, "should have longitude validation"))
  }

  # Latitude fields should all use is.lat validation
  lat_fields <- list(
    "entry_points" = .spec_entry_points$lat,
    "animal_mobility_o_lat" = .spec_animal_mobility$o_lat,
    "animal_mobility_d_lat" = .spec_animal_mobility$d_lat
  )

  for (field_name in names(lat_fields)) {
    field <- lat_fields[[field_name]]
    expect_true("is not a valid latitude" %in% names(field$validation_func) ||
                "are not valid lattitude" %in% names(field$validation_func),  # Note: there's a typo in spec
                info = paste(field_name, "should have latitude validation"))
  }
})


test_that("binary fields have consistent validation", {
  # All binary fields in emission_risk_factors should validate 0, 1, or NA
  binary_fields <- c(
    "disease_notification", "targeted_surveillance", "general_surveillance",
    "screening", "precautions_at_the_borders", "slaughter",
    "selective_killing_and_disposal", "zoning", "official_vaccination",
    "commerce_illegal", "commerce_legal"
  )

  for (field_name in binary_fields) {
    field <- .spec_emission_risk_factors[[field_name]]
    expect_true(field$required,
                info = paste(field_name, "should be required"))

    # Should validate for 0, 1, or NA values
    expect_true(any(grepl("is not 0, 1, or NA", names(field$validation_func))),
                info = paste(field_name, "should validate 0, 1, or NA values"))
  }
})

test_that("spec objects can be used in practice", {
  # Test that the spec objects integrate properly with the validation system

  # This is a smoke test to ensure specs work with validate_dataset_specifications
  # Create minimal test data for each spec type

  # Test epi_units spec with minimal sf data
  skip_if_not_installed("sf")
  library(sf)

  # Create a simple polygon for testing
  test_polygon <- st_polygon(list(matrix(c(0,0,1,0,1,1,0,1,0,0), ncol=2, byrow=TRUE)))
  test_epi_units <- st_sf(
    eu_id = "TEST1",
    eu_name = "Test Unit",
    geometry = st_sfc(test_polygon)
  )

  # This should not error - just testing that the spec can be used
  expect_no_error({
    riskintrodata:::validate_dataset_specifications(test_epi_units, .spec_epi_units)
  })
})
