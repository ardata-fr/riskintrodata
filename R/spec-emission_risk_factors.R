.spec_emission_risk_factors <- list(
  iso3 = list(
    required = TRUE,
    validation_func = list(
      "is not character or has missing values" = function(x) is.character(x) && all(!is.na(x)),
      "has duplicate values" = function(x) length(x) == length(unique(x))
    )
  ),

  country = list(
    required = TRUE,
    validation_func = list(
      "is not character or has missing values" = function(x) is.character(x) && all(!is.na(x))
  ),

  disease = list(
    required = TRUE,
    validation_func = list(
      "is not character or has missing values" = function(x) is.character(x) && all(!is.na(x)),
      "has multiple values, each riskintro study should only have one disease" = function(x) length(unique(x)) %in% c(1,0)
    )
    )
  ),

  animal_category = list(
    required = TRUE,
    validation_func = list(
      "is not character or has missing values" = function(x) is.character(x) && all(!is.na(x)),
      "has multiple values, each riskintro study should only have one animal category" = function(x) length(unique(x)) %in% c(1,0)
    )
  ),

  species = list(
    required = TRUE,
    validation_func = list(
      "is not character or has missing values" = function(x) is.character(x) && all(!is.na(x)),
      "has multiple values, each riskintro study should only have one animal category" = function(x) length(unique(x)) %in% c(1,0)
    )
  ),

  disease_notification = list(
    required = TRUE,
    validation_func = list(
      "is not 0, 1, or NA" = function(x) x %in% c(NA_integer_, 0L, 1L)
    )
  ),

  targeted_surveillance = list(
    required = TRUE,
    validation_func = list(
      "is not 0, 1, or NA" = function(x) x %in% c(NA_integer_, 0L, 1L)
    )
  ),

  general_surveillance = list(
    required = TRUE,
    validation_func = list(
      "is not 0, 1, or NA" = function(x) x %in% c(NA_integer_, 0L, 1L)
    )
  ),

  screening = list(
    required = TRUE,
    validation_func = list(
      "is not 0, 1, or NA" = function(x) x %in% c(NA_integer_, 0L, 1L)
    )
  ),

  precautions_at_the_borders = list(
    required = TRUE,
    validation_func = list(
      "is not 0, 1, or NA" = function(x) x %in% c(NA_integer_, 0L, 1L)
    )
  ),

  slaughter = list(
    required = TRUE,
    validation_func = list(
      "is not 0, 1, or NA" = function(x) x %in% c(NA_integer_, 0L, 1L)
    )
  ),

  selective_killing_and_disposal = list(
    required = TRUE,
    validation_func = list(
      "is not 0, 1, or NA" = function(x) x %in% c(NA_integer_, 0L, 1L)
    )
  ),

  zoning = list(
    required = TRUE,
    validation_func = list(
      "is not 0, 1, or NA" = function(x) x %in% c(NA_integer_, 0L, 1L)
    )
  ),

  official_vaccination = list(
    required = TRUE,
    validation_func = list(
      "is not 0, 1, or NA" = function(x) x %in% c(NA_integer_, 0L, 1L)
    )
  ),

  last_outbreak_end_date = list(
    required = TRUE,
    validation_func = list(
      "is not a Date object" = function(x) inherits(x, "Date")
    )
  ),

  commerce_illegal = list(
    required = TRUE,
    validation_func = list(
      "is not 0, 1, or NA" = function(x) x %in% c(NA_integer_, 0L, 1L)
    )
  ),

  commerce_legal = list(
    required = TRUE,
    validation_func = list(
      "is not 0, 1, or NA" = function(x) x %in% c(NA_integer_, 0L, 1L)
    )
  ),

  data_source = list(
    required = FALSE,
    validation_func = list()
  )
)
