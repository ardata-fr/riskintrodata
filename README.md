
- [1 riskintrodata](#1-riskintrodata)
  - [1.1 Motivation](#11-motivation)
  - [1.2 Installation](#12-installation)
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
    - [1.5.2 Building emission risk
      datasets](#152-building-emission-risk-datasets)
      - [1.5.2.1 Example: Combining WAHIS data with custom
        entries](#1521-example-combining-wahis-data-with-custom-entries)
  - [1.6 Reference datasets](#16-reference-datasets)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# 1 riskintrodata

The ‘riskintrodata’ package is designed to provide a set of functions
and datasets that support the management of data used to estimate the
risk of introducing an animal disease into a specific geographical
region.

It includes tools for reading and validating both geographic and tabular
datasets commonly used in the context of animal disease risk estimation.

## 1.1 Motivation

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

## 1.2 Installation

You can install the development version of riskintrodata like so:

``` r
pak::pak("ardata-fr/riskintrodata")
```

## 1.3 Read data

``` r
library(riskintrodata)
```

The package provides functions to read and validate geographic and
tabular datasets.

To read geographic data from a file, you can use the `read_geo_file()`
function:

``` r
tun_files <-
  system.file(
    package = "riskintrodata",
    "samples",
    "tunisia",
    "epi_units",
    "tunisia_adm2_clean.gpkg"
  )
read_geo_file(tun_files)
#> Simple feature collection with 268 features and 1 field
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 7.530076 ymin: 30.23681 xmax: 11.59826 ymax: 37.55986
#> Geodetic CRS:  WGS 84
#> # A tibble: 268 × 2
#>    eu_name                                                              geometry
#>  * <chr>                                                      <MULTIPOLYGON [°]>
#>  1 Ariana Médina      (((10.13861 36.89453, 10.14495 36.89476, 10.15127 36.8947…
#>  2 Ettadhamen         (((10.05585 36.84308, 10.06575 36.85019, 10.07327 36.8544…
#>  3 Kalaat El Andalous (((10.13862 36.89416, 10.1329 36.88994, 10.13283 36.88892…
#>  4 Mnihla             (((10.1317 36.88428, 10.1317 36.88271, 10.1317 36.8797, 1…
#>  5 Raoued             (((10.16651 36.88694, 10.16422 36.88874, 10.1576 36.89235…
#>  6 Sebkhet Ariana     (((10.27118 36.88874, 10.26842 36.88874, 10.26149 36.8878…
#>  7 Sidi Thabet        (((10.01018 37.00285, 10.0102 37.00285, 10.01045 37.00283…
#>  8 Soukra             (((10.19313 36.85656, 10.19313 36.85892, 10.19313 36.8640…
#>  9 Amdoun             (((9.141866 36.86897, 9.140129 36.86767, 9.137473 36.8660…
#> 10 Béja Nord          (((9.086732 36.70221, 9.082556 36.70772, 9.078131 36.7114…
#> # ℹ 258 more rows

nga_files <- system.file(
  package = "riskintrodata",
  "samples",
  "nigeria",
  "epi_units",
  "NGA-ADM1.geojson"
)
read_geo_file(nga_files)
#> Simple feature collection with 37 features and 5 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 2.692613 ymin: 4.270204 xmax: 14.67797 ymax: 13.88571
#> Geodetic CRS:  WGS 84
#> # A tibble: 37 × 6
#>    shapeName     shapeISO shapeID shapeGroup shapeType                  geometry
#>  * <chr>         <chr>    <chr>   <chr>      <chr>                 <POLYGON [°]>
#>  1 Cross River   NG-CR    276711… NGA        ADM1      ((8.274303 4.854739, 8.3…
#>  2 Abuja Federa… NG-FC    276711… NGA        ADM1      ((6.980815 8.443728, 7.0…
#>  3 Ogun          NG-OG    276711… NGA        ADM1      ((4.483238 6.326054, 4.4…
#>  4 Oyo           NG-OY    276711… NGA        ADM1      ((4.088356 7.133446, 4.0…
#>  5 Sokoto        NG-SO    276711… NGA        ADM1      ((4.126405 13.24967, 4.1…
#>  6 Zamfara       NG-ZA    276711… NGA        ADM1      ((4.941011 11.73083, 4.9…
#>  7 Lagos         NG-LA    276711… NGA        ADM1      ((2.704644 6.459847, 2.6…
#>  8 Akwa Ibom     NG-AK    276711… NGA        ADM1      ((7.88037 5.366796, 7.87…
#>  9 Bayelsa       NG-BY    276711… NGA        ADM1      ((5.448385 5.133691, 5.4…
#> 10 Ondo          NG-ON    276711… NGA        ADM1      ((4.483238 6.326054, 4.5…
#> # ℹ 27 more rows
```

To read raster data, you can use the `read_raster_file()` function:

``` r
road_access_raster_file <- download_road_access_raster()
ra_raster <- read_raster_file(x = road_access_raster_file)
ra_raster
```

A third function, `read_emission_risk_factor_file()`, is available to
read tabular data related to emission risk factors. This function reads
a text file containing emission risk factors for animal diseases. The
file should be in a tabular format with specific columns (see details in
the function documentation).

There is no other function to read tabular data, but you can use the
package ‘readr’ or ‘readxl’ to read the data if the format is CSV or
Excel.

## 1.4 Validate data

All input datasets used in risk analysis must be validated before they
can be processed. The `validate_dataset()` function ensures that
datasets meet the expected format and contain the required information
for risk calculations.

The validation system checks:

- **Required columns**: Presence of essential fields needed for analysis
- **Data types**: Correct formats for different column types (character,
  numeric, spatial, etc.)
- **Data values**: Content validation using predefined rules (e.g.,
  valid coordinates, acceptable category values)  
- **Consistency**: Cross-field validation and logical constraints

### 1.4.1 Supported dataset types

The function can validate four types of datasets used in risk analysis:

- **Epidemiological units**: `table_name = "epi_units"` - Administrative
  areas or regions for risk assessment
- **Entry points**: `table_name = "entry_points"` - Border crossings,
  airports, seaports where animals/products enter  
- **Animal mobility**: `table_name = "animal_mobility"` - Animal
  movement flows between locations
- **Emission risk factors**: `table_name = "emission_risk_factors"` -
  Disease control and surveillance measures by country

### 1.4.2 Column mapping with the `...` argument

When your dataset has different column names than expected, use the
`...` argument to map your columns to the required field names. This
allows you to rename columns during validation without modifying your
original dataset.

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
colnames(clean_epi_units)
#> [1] "eu_name"  "eu_id"    "geometry" "user_id"
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
```

### 1.4.3 Validation workflow

1.  **Import your data** using `read_geo_file()`,
    `read_emission_risk_factor_file()`, or standard R functions
2.  **Check column names** and identify which fields need mapping
3.  **Validate with column mapping** using `validate_dataset()` with
    appropriate `...` arguments  
4.  **Extract clean dataset** using `extract_dataset()` if validation
    passes
5.  **Use in analysis** - validated datasets can be passed directly to
    risk calculation functions

### 1.4.4 Error handling

If validation fails, `validate_dataset()` returns detailed error
messages indicating: - Missing required columns  
- Invalid data types or values - Specific rows/values that don’t meet
validation criteria

Use these messages to fix your data and re-validate. Only datasets that
pass all validation checks can be used in the risk analysis pipeline.

## 1.5 Data structures utilities

### 1.5.1 Emission risk factors management

`get_wahis_erf` is an helper function for getting the WAHIS emission
risk factors dataset. As most analysis done require filtering for one
type of each of diease, species and animal_category, this function is a
helper for that.

`erf_row` is a function to create a single row of emission risk factors
data. It takes parameters corresponding to the columns of the emission
risk factors dataset and returns a tibble with the provided values.

`read_emission_risk_factor_file()` reads a text file containing emission
risk factors for animal diseases. The file should be in a tabular format
with specific columns (see details in the function documentation).

### 1.5.2 Building emission risk datasets

Emission risk is calclated from emission risk factors. These factors
were originally intended to have come from WAHIS and therefore that
dataset is provided in this package.

A common workflow is to start with WAHIS data for your study parameters
and then add custom rows for countries not covered or with updated
information.

Note that to calcaulate emission risk score from emission risk factors,
you’ll need to use the `riskintroanalysis::calc_emission_risk()`
function. This uses the default emission risk weights found as shown
below.

#### 1.5.2.1 Example: Combining WAHIS data with custom entries

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

# Check what we got from WAHIS
nrow(wahis_data)
#> [1] 65
head(wahis_data[, c("iso3", "country", "disease", "species", "animal_category")])
#> # A tibble: 6 × 5
#>   iso3  country                     disease species animal_category
#>   <chr> <chr>                       <chr>   <chr>   <chr>          
#> 1 ALB   Albania                     Anthrax Cattle  Domestic       
#> 2 ARM   Armenia                     Anthrax Cattle  Domestic       
#> 3 CYM   Cayman Islands              Anthrax Cattle  Domestic       
#> 4 HRV   Croatia                     Anthrax Cattle  Domestic       
#> 5 FLK   Falkland Islands (Malvinas) Anthrax Cattle  Domestic       
#> 6 JPN   Japan                       Anthrax Cattle  Domestic

# Add custom entries for countries not in WAHIS or with updated information
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

# Combine WAHIS data with custom entries
complete_erf <- bind_rows(wahis_data, custom_entry1)

# Verify the combined dataset
nrow(complete_erf)
#> [1] 66
tail(complete_erf[, c("iso3", "country", "data_source")])
#> # A tibble: 6 × 3
#>   iso3  country                  data_source                          
#>   <chr> <chr>                    <chr>                                
#> 1 GBR   United Kingdom           WAHIS                                
#> 2 USA   United States of America WAHIS                                
#> 3 URY   Uruguay                  WAHIS                                
#> 4 COK   Cook Islands             WAHIS                                
#> 5 MLI   Mali                     WAHIS                                
#> 6 XYZ   Example Country          Custom entry - Local expert knowledge

emission_risk_weights
#> $disease_notification
#> [1] 0.25
#> 
#> $targeted_surveillance
#> [1] 0.5
#> 
#> $general_surveillance
#> [1] 0.5
#> 
#> $screening
#> [1] 0.75
#> 
#> $precautions_at_the_borders
#> [1] 1
#> 
#> $slaughter
#> [1] 0.5
#> 
#> $selective_killing_and_disposal
#> [1] 0.5
#> 
#> $zoning
#> [1] 0.75
#> 
#> $official_vaccination
#> [1] 0.25
```

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
