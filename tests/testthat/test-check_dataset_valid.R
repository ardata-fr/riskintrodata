test_that("works properly", {
  zz <- mtcars
  expect_true(check_dataset_valid(zz))
  attr(zz, "valid") <- FALSE
  expect_error(check_dataset_valid(zz))
  attr(zz, "valid") <- NULL
  expect_error(check_dataset_valid(zz))
})
