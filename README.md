
- [1 riskintrodata](#1-riskintrodata)
  - [1.1 Installation](#11-installation)
  - [1.2 Analysis of introduction risk
    workflow](#12-analysis-of-introduction-risk-workflow)
  - [1.3 Read data](#13-read-data)
  - [1.4 Validate data](#14-validate-data)
    - [1.4.1 Supported dataset types](#141-supported-dataset-types)
    - [1.4.2 Column mapping with the `...`
      argument](#142-column-mapping-with-the--argument)
    - [1.4.3 Validation workflow](#143-validation-workflow)
    - [1.4.4 Error handling](#144-error-handling)
  - [1.5 Data structures utilities](#15-data-structures-utilities)
    - [1.5.1 Emission risk factors
      management](#151-emission-risk-factors-management)
  - [1.6 Reference datasets](#16-reference-datasets)
  - [1.7 Package motivation](#17-package-motivation)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# 1 riskintrodata

The ‘riskintrodata’ package provides functions and datasets for managing
data used to estimate the risk of introducing an animal disease into a
specific geographical region.

## 1.1 Installation

You can install the development version of riskintrodata like so:

``` r
# Install pak if you don't already have it
install.packages("pak")
pak::pak("git::https://gitlab.cirad.fr/astre/riskintro-app/riskintrodata.git")

# Accept updates to other dependencies
```

## 1.2 Analysis of introduction risk workflow

This package is the first step to analysing the risk of introduction
using the riskintroanalysis package. Before analysis can begin, we need
to ensure that the input datasets are validated which makes sure
analysis is correct and there are no errors.

The overall workflow is:

1.  Import data
2.  Validate data
3.  Analyse data
4.  Visualise data

The first two steps are done here, by this package. The latter two are
done by riskintroanalysis. There is also the riskintroapp package, a
shiny application that brings all these steps into a graphical user
interface.

The first step is reading the data…

## 1.3 Read data

``` r
library(riskintrodata)
```

The package provides functions to read and validate geographic and
tabular datasets.

1.  For geospatial vector datasets (such as adminstrative boundaries)
    use `read_geo_file()`.

This is most often used for epidemiological units and entry points
datasets.

``` r
tun_files <- system.file(
    package = "riskintrodata",
    "samples", "tunisia", "epi_units", "tunisia_adm2_clean.gpkg"
  )
read_geo_file(tun_files)
```

2.  For raster datasets use `read_raster_file()`.

``` r
road_access_raster_file <- download_road_access_raster()
ra_raster <- read_raster_file(x = road_access_raster_file)
ra_raster
```

A third function, `read_emission_risk_factor_file()`, is available to
read tabular data related to emission risk factors. This function reads
a csv file containing emission risk factors for animal diseases. The
file should be in a tabular format with specific columns (see details in
the function documentation).

There is no other function to read tabular data, but you can use the
package ‘readr’ or ‘readxl’ to read common data formats.

## 1.4 Validate data

All input datasets used in risk analysis must be validated before they
can be processed. The `validate_dataset()` function ensures that
datasets meet the expected format and contain the required information
for risk calculations.

The validation system checks:

- Required columns: Presence of essential fields needed for analysis
- Data types: Correct formats for different column types (character,
  numeric, spatial, etc.)
- Data values: Content validation using predefined rules (e.g., valid
  coordinates, acceptable category values)

If your dataset isn’t valid, don’t worry it will give you the details
why.

### 1.4.1 Supported dataset types

The function `validate_dataset()` validates the 4 input datasets.

- Epidemiological units: `table_name = "epi_units"` - Administrative
  areas or regions for risk assessment. Used in all riskintroanalysis
  analyis methods.

- Entry points: `table_name = "entry_points"` - Border crossings,
  airports, seaports where animals/products enter. Used in
  riskintroanalysis entry points analysis.

- Animal mobility: `table_name = "animal_mobility"` - Animal movement
  flows between locations. Used in riskintroanalysis animal mobility
  analysis.

- Emission risk factors: `table_name = "emission_risk_factors"` -
  Disease control and surveillance measures by country. Used in entry
  points, border risk and animal mobility introduction risk analysis.

### 1.4.2 Column mapping with the `...` argument

When your dataset has different column names than those that are
required by `validate_dataset()`, use the `...` argument to map your
columns to the required field names. Alternatively, you can rename your
columns to match data requirements, which case you don’t need to provide
`...` arguments.

Make sure to see the documentation for `validate_dataset()` for examples
and more details.

### 1.4.3 Validation workflow

1.  **Import your data** using `read_geo_file()`,
    `read_emission_risk_factor_file()`, or other R functions and
    packages.
2.  **Check column names** and identify which fields need mapping
3.  **Validate with column mapping** using `validate_dataset()` with
    appropriate `...` arguments  
4.  **Extract clean dataset** using `extract_dataset()` if validation
    passes
5.  **Use in analysis** - validated datasets can be passed directly to
    risk calculation functions

### 1.4.4 Error handling

If validation fails, `extract_dataset()` returns detailed error messages
indicating: - Missing required columns  
- Invalid data types or values - Specific rows/values that don’t meet
validation criteria

Use these messages to fix your data and re-validate. Only datasets that
pass all validation checks can be used in the risk analysis workflow.

## 1.5 Data structures utilities

### 1.5.1 Emission risk factors management

`get_wahis_erf` gives access the WAHIS emission risk factors dataset.
Introduction risk analysis is done for one animal disease, one species,
and one animal category at a time. Use the arguments `disease`,
`species` and `animal_category` to choose.

``` r
# Start with WAHIS data for your study parameters
wahis_data <- get_wahis_erf(
  disease = "Anthrax", 
  species = "Cattle", 
  animal_category = "Domestic"
)
#> WAHIS emission risk factors dataset has 65 entries for
#> • `disease` = "Anthrax"
#> • `species` = "Cattle"
#> • `animal_category` = "Domestic"
```

`erf_row` is a function to create a single row of emission risk factors
data. It takes parameters corresponding to the columns of the emission
risk factors dataset and returns a tibble with the provided values.

This is useful when you want to update or add rows to the WAHIS data.
Use dplyr functions such `rows_upsert` to update and insert rows.

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
custom_entry1 <- erf_row(
  iso3 = "XYZ", 
  country = "Example Country",
  disease = "Anthrax",
  animal_category = "Domestic", 
  species = "Cattle",
  disease_notification = 0,        # Good surveillance in place
  targeted_surveillance = 0,       # Active targeted surveillance  
  general_surveillance = 1,        # Limited general surveillance
  screening = 0,                   # Good screening measures
  precautions_at_the_borders = 0,  # Border controls active
  slaughter = 0,                   # Proper slaughter protocols
  selective_killing_and_disposal = 0, # Culling procedures ready
  zoning = 0,                      # Zoning strategies implemented
  official_vaccination = 1,        # No vaccination program
  last_outbreak_end_date = as.Date("2020-01-15"),
  commerce_illegal = 1,            # Some illegal trade suspected
  commerce_legal = 0,              # Legal trade well regulated
  data_source = "Custom entry - Local expert knowledge"
)
complete_erf <- dplyr::rows_upsert(wahis_data, custom_entry1, by = "iso3") |> 
  arrange(desc(iso3))
complete_erf
#> # A tibble: 66 × 18
#>    iso3  country            disease animal_category species disease_notification
#>    <chr> <chr>              <chr>   <chr>           <chr>                  <int>
#>  1 XYZ   Example Country    Anthrax Domestic        Cattle                     0
#>  2 VCT   Saint Vincent and… Anthrax Domestic        Cattle                     0
#>  3 USA   United States of … Anthrax Domestic        Cattle                     0
#>  4 URY   Uruguay            Anthrax Domestic        Cattle                     0
#>  5 UKR   Ukraine            Anthrax Domestic        Cattle                     0
#>  6 TZA   Tanzania           Anthrax Domestic        Cattle                     0
#>  7 TWN   Chinese Taipei     Anthrax Domestic        Cattle                     0
#>  8 TUR   Türkiye (Rep. of)  Anthrax Domestic        Cattle                     0
#>  9 SYR   Syria              Anthrax Domestic        Cattle                     0
#> 10 SYC   Seychelles         Anthrax Domestic        Cattle                     0
#> # ℹ 56 more rows
#> # ℹ 12 more variables: targeted_surveillance <int>, general_surveillance <int>,
#> #   screening <int>, precautions_at_the_borders <int>, slaughter <int>,
#> #   selective_killing_and_disposal <int>, zoning <int>,
#> #   official_vaccination <int>, last_outbreak_end_date <date>,
#> #   commerce_illegal <int>, commerce_legal <int>, data_source <chr>
```

Incase you have a premade dataset you can use the
`read_emission_risk_factor_file()` reads a text file containing emission
risk factors for animal diseases. The file should be in a tabular format
with specific columns (see details in the function documentation). You
can also validate emission risk factors with
`validate_dataset(table_name = "emission_risk_factors",...)`.

## 1.6 Reference datasets

The package includes several reference datasets that are used in the
context of animal disease risk estimation:

- iso3 country codes, available with the function `country_reference()`.
  Also a utility function `iso3_to_name()` is provided to convert ISO3
  codes to country names.
- list `emission_risk_weights` contains the emission risk weights by
  default used to calculate emission risk scores and emission risk from
  emission risk factors.
- `neighbours_table` A correspondence table of all countries and their
  neighbours,
- `world_sf`, an SF dataset containing global administrative boundaries
  for most countries,
- `wahis_emission_risk_factors`: Emission Risk Factors dataset from
  WAHIS,
- get default emission risk weights with `get_erf_weights()` function.

## 1.7 Package motivation

The primary motivation for creating ‘riskintrodata’ is to isolate and
centralize the datasets and data import functions required by the
‘riskintro’ application into a dedicated package. This separation
simplifies testing, improves clarity, and makes it easier to document
the datasets used in the application in a structured way.

Additionally, the ‘riskintrodata’ package is designed to simplify
package management. It helps reduce the complexity of handling the
numerous packages required by the ‘riskintro’ application. By
centralizing essential datasets and their associated import functions,
‘riskintrodata’ minimizes package dependencies.
