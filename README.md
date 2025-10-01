
- [1 riskintrodata](#1-riskintrodata)
  - [1.1 Installation](#11-installation)
  - [1.2 Analysis of introduction risk
    workflow](#12-analysis-of-introduction-risk-workflow)
  - [1.3 Read data](#13-read-data)
  - [1.4 Validate data](#14-validate-data)
    - [1.4.1 Supported dataset types](#141-supported-dataset-types)
    - [1.4.2 Column mapping with the `...`
      argument](#142-column-mapping-with-the--argument)
      - [1.4.2.1 Example: Validating epidemiological
        units](#1421-example-validating-epidemiological-units)
      - [1.4.2.2 Example: Validating entry
        points](#1422-example-validating-entry-points)
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

See the following code blocks for examples.

#### 1.4.2.1 Example: Validating epidemiological units

``` r
# Load a sample dataset with non-standard column names
nga_files <- system.file(
  package = "riskintrodata", "samples", "nigeria", "epi_units", "NGA-ADM1.geojson"
)
nga_raw <- read_geo_file(nga_files)
colnames(nga_raw)
#> [1] "shapeName"  "shapeISO"   "shapeID"    "shapeGroup" "shapeType" 
#> [6] "geometry"

# Validate by mapping columns: your_column = "required_field"
validated_epi_units <- validate_dataset(
  x = nga_raw,
  table_name = "epi_units", 
  eu_name = "shapeName",     # Map "shapeName" to required "eu_name"
  eu_id = "shapeISO"         # Map "shapeISO" to optional "eu_id"
)

# Extract the clean, validated dataset
clean_epi_units <- extract_dataset(validated_epi_units)
clean_epi_units
#> Simple feature collection with 37 features and 3 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 2.692613 ymin: 4.270204 xmax: 14.67797 ymax: 13.88571
#> Geodetic CRS:  WGS 84
#> # A tibble: 37 × 4
#>    eu_name                         eu_id                        geometry user_id
#>  * <chr>                           <chr>                   <POLYGON [°]> <chr>  
#>  1 Cross River                     NG-CR ((8.274303 4.854739, 8.302391 … NG-CR  
#>  2 Abuja Federal Capital Territory NG-FC ((6.980815 8.443728, 7.035885 … NG-FC  
#>  3 Ogun                            NG-OG ((4.483238 6.326054, 4.488367 … NG-OG  
#>  4 Oyo                             NG-OY ((4.088356 7.133446, 4.087642 … NG-OY  
#>  5 Sokoto                          NG-SO ((4.126405 13.24967, 4.17857 1… NG-SO  
#>  6 Zamfara                         NG-ZA ((4.941011 11.73083, 4.944116 … NG-ZA  
#>  7 Lagos                           NG-LA ((2.704644 6.459847, 2.698831 … NG-LA  
#>  8 Akwa Ibom                       NG-AK ((7.88037 5.366796, 7.876112 5… NG-AK  
#>  9 Bayelsa                         NG-BY ((5.448385 5.133691, 5.437778 … NG-BY  
#> 10 Ondo                            NG-ON ((4.483238 6.326054, 4.560864 … NG-ON  
#> # ℹ 27 more rows
```

#### 1.4.2.2 Example: Validating entry points

``` r
# Load sample entry points data  
entry_files <- system.file(
  package = "riskintrodata", "samples", "tunisia", "entry_points", 
  "BORDER_CROSSING_POINTS.csv"
)
entry_raw <- read.csv(entry_files)
colnames(entry_raw)
#> [1] "NAME"        "TYPE"        "MODE"        "LONGITUDE_X" "LATITUDE_Y" 
#> [6] "SOURCES"

# Map your columns to required fields
validated_entry_points <- validate_dataset(
  x = entry_raw,
  table_name = "entry_points",
  point_name = "NAME",       # Required: point name
  lng = "LONGITUDE_X",       # Required: longitude  
  lat = "LATITUDE_Y",        # Required: latitude
  mode = "MODE",             # Optional: contraband status
  type = "TYPE"              # Optional: transport type
)

clean_entry_points <- extract_dataset(validated_entry_points)
clean_entry_points
#> Simple feature collection with 110 features and 5 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 7.572541 ymin: 31.94455 xmax: 11.59319 ymax: 37.26487
#> Geodetic CRS:  WGS 84
#> First 10 features:
#>    point_id             point_name mode type                  geometry sources
#> 1  ep-00001        aeroport Djerba    C  AIR POINT (10.77592 33.87149)      NA
#> 2  ep-00002       aeroport enfidha    C  AIR POINT (10.43123 36.07011)      NA
#> 3  ep-00003      aeroport monastir    C  AIR POINT (10.75472 35.75806)      NA
#> 4  ep-00004          aeroport sfax    C  AIR POINT (10.68861 34.72056)      NA
#> 5  ep-00005       aeroport tabarka    C  AIR  POINT (8.87528 36.98028)      NA
#> 6  ep-00006        Aeroport tozeur    C  AIR  POINT (8.10139 33.93889)      NA
#> 7  ep-00007 aeroport tunis cathage    C  AIR POINT (10.22694 36.85111)      NA
#> 8  ep-00001        aeroport Djerba    C  AIR POINT (10.77592 33.87149)      NA
#> 9  ep-00002       aeroport enfidha    C  AIR POINT (10.43123 36.07011)      NA
#> 10 ep-00003      aeroport monastir    C  AIR POINT (10.75472 35.75806)      NA
```

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
