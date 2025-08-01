test_that("wahis validation works", {

  rowss <- expect_no_error({
    get_wahis_erf(
      disease = "Anthrax",
      species = "Cattle",
      animal_category = "Domestic",
      validate = TRUE
    ) |>
      nrow()
  })
  expect_equal(rowss, 65L)

  rowss <- expect_no_error({
    get_wahis_erf(
      validate = FALSE
    ) |>
      nrow()
  })
  expect_equal(rowss, 16940L)

  expect_error({
    get_wahis_erf(
      disease = "Avian infectious laryngotracheitis",
      species = "Cattle",
      animal_category = "Domestic",
      validate = TRUE
    )
  })

  expect_warning({
    get_wahis_erf(
      disease = "Avian infectious laryngotracheitis",
      species = "Cattle",
      animal_category = "Domestic",
      validate = FALSE
    )
  })

  zz <- get_wahis_erf(
    disease = "Avian infectious laryngotracheitis",
    species = "Cattle",
    animal_category = "Domestic",
    validate = FALSE
  )

  expect_true(attr(zz, "valid"))
  expect_true(attr(zz, "table_name") == "emission_risk_factors")

})
