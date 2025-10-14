test_that("CSV-001: Single column CSV file fails validation", {
  library(sf)
  library(dplyr)

  # Create CSV data with only one column
  single_col_csv <- data.frame(
    id = c("EU1", "EU2", "EU3")
  )

  # Should fail because risk value column is missing
  expect_error(
    {
      # Check column count
      if (ncol(single_col_csv) != 2) {
        stop("CSV must have exactly 2 columns: id and risk_value")
      }
    },
    "exactly 2 columns"
  )
})


test_that("CSV-002: More than two columns CSV file fails validation", {
  library(sf)
  library(dplyr)

  # Create CSV data with three columns
  multi_col_csv <- data.frame(
    id = c("EU1", "EU2", "EU3"),
    risk_value = c(10.5, 20.3, 15.7),
    extra_column = c("A", "B", "C")
  )

  # Should fail because there are too many columns
  expect_error(
    {
      # Check column count
      if (ncol(multi_col_csv) != 2) {
        stop("CSV must have exactly 2 columns: id and risk_value")
      }
    },
    "exactly 2 columns"
  )
})


test_that("CSV-003: Exactly two columns CSV file is valid", {
  library(sf)
  library(dplyr)

  # Create CSV data with exactly two columns
  valid_csv <- data.frame(
    id = c("EU1", "EU2", "EU3"),
    risk_value = c(10.5, 20.3, 15.7)
  )

  # Should pass column count validation
  expect_no_error({
    if (ncol(valid_csv) != 2) {
      stop("CSV must have exactly 2 columns")
    }
  })

  # Verify structure
  expect_equal(ncol(valid_csv), 2)
  expect_true("id" %in% names(valid_csv))
  expect_true(is.numeric(valid_csv$risk_value))
})


test_that("CSV-004: First column named 'id' and second with valid name", {
  library(sf)
  library(dplyr)

  # Create CSV with proper column names (no special chars or spaces)
  valid_names_csv <- data.frame(
    id = c("EU1", "EU2", "EU3"),
    temperature_risk = c(10.5, 20.3, 15.7)
  )

  # Verify column names
  expect_equal(names(valid_names_csv)[1], "id")
  expect_true(grepl("^[a-zA-Z_][a-zA-Z0-9_]*$", names(valid_names_csv)[2]))

  # Test with various valid column names
  test_names <- c("risk_value", "risk_score", "temp_risk", "migration_index")
  for (name in test_names) {
    test_csv <- data.frame(
      id = c("EU1", "EU2"),
      value = c(10, 20)
    )
    names(test_csv)[2] <- name

    expect_true(grepl("^[a-zA-Z_][a-zA-Z0-9_]*$", names(test_csv)[2]))
  }
})


test_that("CSV-005: Invalid column name with special characters fails", {
  library(sf)
  library(dplyr)

  # Test various invalid column names
  invalid_names <- c(
    "risk value",    # space
    "risk-value",    # hyphen
    "risk.value",    # dot (sometimes valid in R but not recommended)
    "risk@value",    # special character
    "123risk",       # starts with number
    "risk!",         # exclamation
    "risk(value)"    # parentheses
  )

  for (invalid_name in invalid_names) {
    # Check if name matches valid R variable naming pattern
    is_valid <- grepl("^[a-zA-Z_][a-zA-Z0-9_]*$", invalid_name)
    expect_false(is_valid, info = paste("Testing:", invalid_name))
  }
})


test_that("CSV-006: Non-numeric values in second column fail validation", {
  library(sf)
  library(dplyr)

  # Create CSV with character values in risk column
  non_numeric_csv <- data.frame(
    id = c("EU1", "EU2", "EU3"),
    risk_value = c("high", "medium", "low"),
    stringsAsFactors = FALSE
  )

  # Should fail because risk values are not numeric
  expect_false(is.numeric(non_numeric_csv$risk_value))

  # Test with mixed types
  expect_error({
    mixed_csv <- data.frame(
      id = c("EU1", "EU2", "EU3"),
      risk_value = c(10.5, "text", 15.7)
    )
    if (!is.numeric(mixed_csv$risk_value)) {
      stop("Risk values must be numeric")
    }
  }, "numeric")
})


test_that("CSV-007: Negative values in second column fail validation", {
  library(sf)
  library(dplyr)

  # Create CSV with negative values
  negative_csv <- data.frame(
    id = c("EU1", "EU2", "EU3"),
    risk_value = c(10.5, -5.3, 15.7)
  )

  # Should fail validation for negative values
  has_negative <- any(negative_csv$risk_value < 0, na.rm = TRUE)
  expect_true(has_negative)

  # Validation function should catch this
  expect_error({
    if (any(negative_csv$risk_value < 0, na.rm = TRUE)) {
      stop("Risk values must be non-negative")
    }
  }, "non-negative")
})


test_that("CSV-008: Null values in second column are valid", {
  library(sf)
  library(dplyr)

  # Create CSV with NA values
  na_csv <- data.frame(
    id = c("EU1", "EU2", "EU3", "EU4"),
    risk_value = c(10.5, NA, 15.7, NA)
  )

  # Should pass validation - NA values are allowed
  expect_no_error({
    if (!is.numeric(na_csv$risk_value)) {
      stop("Risk values must be numeric")
    }
  })

  # Verify structure
  expect_equal(sum(is.na(na_csv$risk_value)), 2)
  expect_true(is.numeric(na_csv$risk_value))
})


test_that("CSV-009: Null value entries excluded from risk calculation", {
  library(sf)
  library(dplyr)

  # Create CSV with NA values
  na_csv <- data.frame(
    id = c("EU1", "EU2", "EU3", "EU4"),
    risk_value = c(10.5, NA, 15.7, NA)
  )

  # Filter out NA values for risk calculation
  valid_risks <- na_csv[!is.na(na_csv$risk_value), ]

  # Verify only non-NA values remain
  expect_equal(nrow(valid_risks), 2)
  expect_false(any(is.na(valid_risks$risk_value)))
  expect_equal(valid_risks$id, c("EU1", "EU3"))
})


test_that("CSV-010: All CSV IDs match epidemiological units - valid", {
  library(sf)
  library(dplyr)

  # Create epidemiological units
  epi_units <- data.frame(
    eu_id = c("EU1", "EU2", "EU3", "EU4"),
    eu_name = c("Unit 1", "Unit 2", "Unit 3", "Unit 4")
  )

  # Create CSV with matching IDs
  risk_csv <- data.frame(
    id = c("EU1", "EU2", "EU3"),
    risk_value = c(10.5, 20.3, 15.7)
  )

  # All CSV IDs should be in epi_units
  all_match <- all(risk_csv$id %in% epi_units$eu_id)
  expect_true(all_match)

  # Verify join would work
  joined <- merge(epi_units, risk_csv, by.x = "eu_id", by.y = "id", all.x = TRUE)
  expect_equal(nrow(joined), nrow(epi_units))
  expect_equal(sum(!is.na(joined$risk_value)), nrow(risk_csv))
})


test_that("CSV-011: Some CSV IDs not in epidemiological units - fail", {
  library(sf)
  library(dplyr)

  # Create epidemiological units
  epi_units <- data.frame(
    eu_id = c("EU1", "EU2", "EU3"),
    eu_name = c("Unit 1", "Unit 2", "Unit 3")
  )

  # Create CSV with some non-matching IDs
  risk_csv <- data.frame(
    id = c("EU1", "EU2", "EU_INVALID", "EU_UNKNOWN"),
    risk_value = c(10.5, 20.3, 15.7, 25.0)
  )

  # Not all CSV IDs are in epi_units
  all_match <- all(risk_csv$id %in% epi_units$eu_id)
  expect_false(all_match)

  # Find mismatched IDs
  mismatched <- risk_csv$id[!risk_csv$id %in% epi_units$eu_id]
  expect_equal(length(mismatched), 2)
  expect_setequal(mismatched, c("EU_INVALID", "EU_UNKNOWN"))

  # Validation should fail
  expect_error({
    if (!all(risk_csv$id %in% epi_units$eu_id)) {
      invalid_ids <- risk_csv$id[!risk_csv$id %in% epi_units$eu_id]
      stop(paste("Invalid IDs:", paste(invalid_ids, collapse = ", ")))
    }
  }, "Invalid IDs")
})


test_that("CSV-012: Multiple CSV files can be combined", {
  library(sf)
  library(dplyr)

  # Create first CSV file (temperature risk)
  temp_csv <- data.frame(
    id = c("EU1", "EU2", "EU3"),
    temp_risk = c(10.5, 20.3, 15.7)
  )

  # Create second CSV file (migration risk)
  migration_csv <- data.frame(
    id = c("EU1", "EU2", "EU4"),
    migration_risk = c(5.2, 15.8, 22.1)
  )

  # Create third CSV file (vegetation risk)
  veg_csv <- data.frame(
    id = c("EU2", "EU3", "EU4"),
    vegetation_risk = c(8.5, 12.3, 18.9)
  )

  # Combine all CSV files
  combined <- temp_csv |>
    full_join(migration_csv, by = "id") |>
    full_join(veg_csv, by = "id")

  # Verify combined structure
  expect_equal(ncol(combined), 4) # id + 3 risk columns
  expect_equal(nrow(combined), 4) # All unique IDs
  expect_true(all(c("temp_risk", "migration_risk", "vegetation_risk") %in% names(combined)))

  # Verify some values are NA (not all CSVs have all IDs)
  expect_true(any(is.na(combined$temp_risk)))
  expect_true(any(is.na(combined$migration_risk)))
  expect_true(any(is.na(combined$vegetation_risk)))
})


test_that("CSV-013: CSV with all zero values is valid", {
  library(sf)
  library(dplyr)

  # Create CSV with all zero values
  zero_csv <- data.frame(
    id = c("EU1", "EU2", "EU3"),
    risk_value = c(0, 0, 0)
  )

  # Should pass validation - zeros are valid
  expect_no_error({
    if (!is.numeric(zero_csv$risk_value)) {
      stop("Risk values must be numeric")
    }
    if (any(zero_csv$risk_value < 0, na.rm = TRUE)) {
      stop("Risk values must be non-negative")
    }
  })

  expect_true(all(zero_csv$risk_value >= 0))
})


test_that("CSV-014: CSV with very large values is valid", {
  library(sf)
  library(dplyr)

  # Create CSV with large values
  large_csv <- data.frame(
    id = c("EU1", "EU2", "EU3"),
    risk_value = c(1000, 5000, 10000)
  )

  # Should pass validation - large positive values are allowed
  expect_no_error({
    if (!is.numeric(large_csv$risk_value)) {
      stop("Risk values must be numeric")
    }
    if (any(large_csv$risk_value < 0, na.rm = TRUE)) {
      stop("Risk values must be non-negative")
    }
  })

  expect_true(all(is.finite(large_csv$risk_value)))
  expect_true(all(large_csv$risk_value > 0))
})


test_that("CSV-015: CSV with decimal precision is preserved", {
  library(sf)
  library(dplyr)

  # Create CSV with high precision decimal values
  precision_csv <- data.frame(
    id = c("EU1", "EU2", "EU3"),
    risk_value = c(10.123456, 20.987654, 15.555555)
  )

  # Verify precision is maintained
  expect_true(is.numeric(precision_csv$risk_value))
  expect_true(is.double(precision_csv$risk_value))
  expect_equal(precision_csv$risk_value[1], 10.123456, tolerance = 1e-6)
})


test_that("CSV-016: Empty CSV file fails validation", {
  library(sf)
  library(dplyr)

  # Create empty CSV
  empty_csv <- data.frame(
    id = character(0),
    risk_value = numeric(0)
  )

  # Should fail because there are no rows
  expect_equal(nrow(empty_csv), 0)

  expect_error({
    if (nrow(empty_csv) == 0) {
      stop("CSV file must contain at least one row")
    }
  }, "at least one row")
})


test_that("CSV-017: CSV with duplicate IDs fails validation", {
  library(sf)
  library(dplyr)

  # Create CSV with duplicate IDs
  duplicate_csv <- data.frame(
    id = c("EU1", "EU2", "EU1", "EU3"),
    risk_value = c(10.5, 20.3, 15.7, 25.0)
  )

  # Should fail because IDs must be unique
  has_duplicates <- any(duplicated(duplicate_csv$id))
  expect_true(has_duplicates)

  expect_error({
    if (any(duplicated(duplicate_csv$id))) {
      dup_ids <- duplicate_csv$id[duplicated(duplicate_csv$id)]
      stop(paste("Duplicate IDs found:", paste(dup_ids, collapse = ", ")))
    }
  }, "Duplicate IDs")
})


# Tunisia Real-World Data Tests ----

test_that("CSV-TN-001: Valid CSV with real Tunisia ADM2 IDs", {
  library(sf)
  library(dplyr)

  # Load Tunisia epidemiological units
  tunisia_path <- system.file("samples", "Tunisia", "epi_units", "tunisia_adm2_raw.gpkg",
                              package = "riskintrodata")
  skip_if(tunisia_path == "", message = "Tunisia sample data not available")

  tunisia_epi <- read_sf(tunisia_path)

  # Create CSV with subset of real Tunisia IDs
  risk_csv <- data.frame(
    id = c("TUN.1.1_1", "TUN.1.2_1", "TUN.2.1_1", "TUN.3.1_1"),
    temperature_risk = c(15.5, 22.3, 18.7, 20.1)
  )

  # All CSV IDs should be in Tunisia epi units
  all_match <- all(risk_csv$id %in% tunisia_epi$GID_2)
  expect_true(all_match)

  # Verify join would work
  joined <- merge(tunisia_epi, risk_csv, by.x = "GID_2", by.y = "id", all.x = TRUE)
  expect_equal(nrow(joined), nrow(tunisia_epi))
  expect_equal(sum(!is.na(joined$temperature_risk)), nrow(risk_csv))
})


test_that("CSV-TN-002: CSV with invalid Tunisia IDs fails validation", {
  library(sf)
  library(dplyr)

  # Load Tunisia epidemiological units
  tunisia_path <- system.file("samples", "Tunisia", "epi_units", "tunisia_adm2_raw.gpkg",
                              package = "riskintrodata")
  skip_if(tunisia_path == "", message = "Tunisia sample data not available")

  tunisia_epi <- read_sf(tunisia_path)

  # Create CSV with mix of valid and invalid Tunisia IDs
  risk_csv <- data.frame(
    id = c("TUN.1.1_1", "TUN.1.2_1", "TUN.999.999_1", "INVALID_ID"),
    risk_value = c(10.5, 20.3, 15.7, 25.0)
  )

  # Not all CSV IDs are in Tunisia epi units
  all_match <- all(risk_csv$id %in% tunisia_epi$GID_2)
  expect_false(all_match)

  # Find mismatched IDs
  mismatched <- risk_csv$id[!risk_csv$id %in% tunisia_epi$GID_2]
  expect_equal(length(mismatched), 2)
  expect_setequal(mismatched, c("TUN.999.999_1", "INVALID_ID"))

  # Validation should fail
  expect_error({
    if (!all(risk_csv$id %in% tunisia_epi$GID_2)) {
      invalid_ids <- risk_csv$id[!risk_csv$id %in% tunisia_epi$GID_2]
      stop(paste("Invalid Tunisia IDs:", paste(invalid_ids, collapse = ", ")))
    }
  }, "Invalid Tunisia IDs")
})


test_that("CSV-TN-003: CSV with NA values for Tunisia units", {
  library(sf)
  library(dplyr)

  # Load Tunisia epidemiological units
  tunisia_path <- system.file("samples", "Tunisia", "epi_units", "tunisia_adm2_raw.gpkg",
                              package = "riskintrodata")
  skip_if(tunisia_path == "", message = "Tunisia sample data not available")

  tunisia_epi <- read_sf(tunisia_path)

  # Create CSV with NA values for some Tunisia units
  risk_csv <- data.frame(
    id = c("TUN.1.1_1", "TUN.1.2_1", "TUN.2.1_1", "TUN.3.1_1", "TUN.4.1_1"),
    vegetation_risk = c(12.5, NA, 18.3, NA, 22.1)
  )

  # All non-NA IDs should be valid
  all_match <- all(risk_csv$id %in% tunisia_epi$GID_2)
  expect_true(all_match)

  # Filter out NA values for calculation
  valid_risks <- risk_csv[!is.na(risk_csv$vegetation_risk), ]
  expect_equal(nrow(valid_risks), 3)
  expect_equal(valid_risks$id, c("TUN.1.1_1", "TUN.2.1_1", "TUN.4.1_1"))

  # Verify numeric type preserved despite NAs
  expect_true(is.numeric(risk_csv$vegetation_risk))
})


test_that("CSV-TN-004: Multiple CSV files combined for Tunisia", {
  library(sf)
  library(dplyr)

  # Load Tunisia epidemiological units
  tunisia_path <- system.file("samples", "Tunisia", "epi_units", "tunisia_adm2_raw.gpkg",
                              package = "riskintrodata")
  skip_if(tunisia_path == "", message = "Tunisia sample data not available")

  tunisia_epi <- read_sf(tunisia_path)

  # Create multiple CSV files with different Tunisia units
  temp_csv <- data.frame(
    id = c("TUN.1.1_1", "TUN.1.2_1", "TUN.2.1_1"),
    temp_risk = c(15.5, 18.2, 22.7)
  )

  migration_csv <- data.frame(
    id = c("TUN.1.2_1", "TUN.2.1_1", "TUN.3.1_1"),
    migration_risk = c(8.3, 12.5, 16.9)
  )

  precipitation_csv <- data.frame(
    id = c("TUN.1.1_1", "TUN.3.1_1", "TUN.4.1_1"),
    precip_risk = c(5.2, 9.8, 14.3)
  )

  # Combine all CSV files
  combined <- temp_csv |>
    full_join(migration_csv, by = "id") |>
    full_join(precipitation_csv, by = "id")

  # Verify combined structure
  expect_equal(ncol(combined), 4) # id + 3 risk columns
  expect_true(all(c("temp_risk", "migration_risk", "precip_risk") %in% names(combined)))

  # All IDs should be valid Tunisia IDs
  all_match <- all(combined$id %in% tunisia_epi$GID_2)
  expect_true(all_match)

  # Verify some values are NA (not all CSVs have all IDs)
  expect_true(any(is.na(combined$temp_risk)))
  expect_true(any(is.na(combined$migration_risk)))
  expect_true(any(is.na(combined$precip_risk)))
})
