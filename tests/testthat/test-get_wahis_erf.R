test_that("wahis validation works", {

  rowss <- expect_no_error({
    get_wahis_erf(
      disease = "Anthrax",
      species = "Cattle",
      animal_category = "Domestic"
    ) |>
      nrow()
  })
  expect_equal(rowss, 65L)

  expect_error({
    get_wahis_erf()
  })

  expect_warning({
    get_wahis_erf(
      disease = "Avian infectious laryngotracheitis",
      species = "Cattle",
      animal_category = "Domestic"
    )
  })


  zz <- get_wahis_erf(
    disease = "Anthrax",
    species = "Cattle",
    animal_category = "Domestic"
  )
  expect_true(attr(zz, "table_name") == "emission_risk_factors")
  expect_true(attr(zz, "table_validated"))

})
