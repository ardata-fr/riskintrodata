test_that("works properly", {
  zz <- mtcars
  expect_true(check_dataset_valid(zz))
  attr(zz, "table_validated") <- FALSE
  expect_error(check_dataset_valid(zz))
  attr(zz, "table_validated") <- NULL
  expect_error(check_dataset_valid(zz))
})
