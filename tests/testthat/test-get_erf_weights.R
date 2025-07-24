test_that("weights meet data model requirements", {
  weights <- get_erf_weights()
  expect_length(weights, 9)
  expect_equal(weights |> unlist() |> sum(), 5)
})
