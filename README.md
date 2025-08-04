
- [1 riskintrodata](#1-riskintrodata)
  - [1.1 Motivation](#11-motivation)
  - [1.2 Installation](#12-installation)
  - [1.3 Read data](#13-read-data)
  - [1.4 Validate data](#14-validate-data)
    - [1.4.1 Mapping for entry points](#141-mapping-for-entry-points)
    - [1.4.2 Mapping for epidemiological
      units](#142-mapping-for-epidemiological-units)
    - [1.4.3 Mapping for animal
      mobility](#143-mapping-for-animal-mobility)
    - [1.4.4 Mapping for emission risk
      factors](#144-mapping-for-emission-risk-factors)
  - [1.5 Emission risk factors
    management](#15-emission-risk-factors-management)
  - [1.6 References data](#16-references-data)

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

The package provides a function named `validate_dataset_content()` to
validate the content of datasets. This function checks the structure of
the data and ensures that it meets the expected format, the function
will check:

- the presence of required columns
- the data types of the columns, mandatory or optional
- and a set of rules to validate the data.

It can be used with datasets for:

- Epi units, use
  `validate_dataset_content(..., table_name = "epi_units")`.
- Emission risks, use
  `validate_dataset_content(..., table_name = "emission_risk_factors")`.
- Animal mobility, use
  `validate_dataset_content(..., table_name = "animal_mobility")`.
- Entry points, use
  `validate_dataset_content(..., table_name = "entry_points")`.

The function takes a data frame or an ‘sf’ object as input, along with
the type of the dataset and any additional arguments for mapping
columns. It returns a list containing the validation status of the
dataset, i.e. the required and optional columns, the validation rules,
and the dataset itself after renaming and selecting the specified
columns.

``` r
tun_epi_files <-
  system.file(
    package = "riskintrodata",
    "samples",
    "tunisia",
    "epi_units", "tunisia_adm2_raw.gpkg"
  )

tun_epi_unit <- read_geo_file(tun_epi_files)

DATA_EPI_UNITS <- validate_dataset_content(
  x = tun_epi_unit,
  table_name = "epi_units",
  eu_name = "shapeName",
  user_id = "fid"
)

DATA_EPI_UNITS
#> $table_name
#> [1] "epi_units"
#> 
#> $matching_columns
#> $chk
#> [1] FALSE
#> 
#> $msg
#> The mapped names are not available in the dataset: `shapeName` and `fid`.
#> 
#> $details
#> [1] "shapeName" "fid"      
#> 
#> attr(,"class")
#> [1] "validation_status"
#> 
#> $required_columns
#> $chk
#> [1] FALSE
#> 
#> $msg
#> The following required columns are missing: `eu_name`
#> 
#> $details
#> [1] "eu_name"
#> 
#> attr(,"class")
#> [1] "validation_status"
#> 
#> $optional_columns
#> $chk
#> [1] TRUE
#> 
#> $msg
#> [1] "Optional columns selected are available."
#> 
#> $details
#> character(0)
#> 
#> attr(,"class")
#> [1] "validation_status"
#> 
#> $validate_rules
#> $chk
#> [1] FALSE
#> 
#> $msg
#> [1] "Found invalidities while checking dataset."
#> 
#> $details
#> # A tibble: 5 × 8
#>   colname  valid required column_found n     index value msg                    
#>   <chr>    <lgl> <lgl>    <lgl>        <lgl> <lgl> <lgl> <glue>                 
#> 1 eu_id    TRUE  FALSE    TRUE         NA    NA    NA    "eu_id" has been valid…
#> 2 eu_id    TRUE  FALSE    TRUE         NA    NA    NA    "eu_id" has been valid…
#> 3 eu_name  FALSE TRUE     FALSE        NA    NA    NA    Column: "eu_name" is m…
#> 4 geometry TRUE  TRUE     TRUE         NA    NA    NA    "geometry" has been va…
#> 5 geometry TRUE  TRUE     TRUE         NA    NA    NA    "geometry" has been va…
#> 
#> attr(,"class")
#> [1] "validation_status"
#> 
#> $specific_changes
#> $chk
#> [1] FALSE
#> 
#> $msg
#> [1] "transformations not applied."
#> 
#> $details
#> NULL
#> 
#> attr(,"class")
#> [1] "validation_status"
#> 
#> $dataset
#> Simple feature collection with 268 features and 0 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 7.530076 ymin: 30.23681 xmax: 11.59826 ymax: 37.55986
#> Geodetic CRS:  WGS 84
#> # A tibble: 268 × 1
#>                                                                         geometry
#>                                                               <MULTIPOLYGON [°]>
#>  1 (((10.13861 36.89453, 10.14495 36.89476, 10.15127 36.89476, 10.1576 36.89235…
#>  2 (((10.05585 36.84308, 10.06575 36.85019, 10.07327 36.8544, 10.07366 36.85451…
#>  3 (((10.13862 36.89416, 10.1329 36.88994, 10.13283 36.88892, 10.1326 36.88572,…
#>  4 (((10.1317 36.88428, 10.1317 36.88271, 10.1317 36.8797, 10.12929 36.87579, 1…
#>  5 (((10.16651 36.88694, 10.16422 36.88874, 10.1576 36.89235, 10.15127 36.89476…
#>  6 (((10.27118 36.88874, 10.26842 36.88874, 10.26149 36.88783, 10.25577 36.8863…
#>  7 (((10.01018 37.00285, 10.0102 37.00285, 10.01045 37.00283, 10.01063 37.00281…
#>  8 (((10.19313 36.85656, 10.19313 36.85892, 10.19313 36.86404, 10.19313 36.8667…
#>  9 (((9.141866 36.86897, 9.140129 36.86767, 9.137473 36.86604, 9.133329 36.8623…
#> 10 (((9.086732 36.70221, 9.082556 36.70772, 9.078131 36.71146, 9.075724 36.7131…
#> # ℹ 258 more rows
#> 
#> attr(,"class")
#> [1] "table_validation_status"
```

### 1.4.1 Mapping for entry points

Maps columns for entry points datasets (e.g., border crossings,
airports, seaports).

Required:  
- `point_name`: Name/description of the entry point  
- Geospatial info: either `lat`/`lng` or `geometry`

Optional:  
- `mode`: Contraband status (`C`, `NC`, or missing)  
- `type`: Type of entry point (`AIR`, `SEA`, `BC`, `CC`, `TC`, or
missing)  
- `sources`: List of ISO3 codes for source countries

### 1.4.2 Mapping for epidemiological units

Maps columns for epidemiological units datasets (e.g., administrative
areas).

Required:  
- `eu_name`: Name/description of the epi unit  
- `geometry`: Geospatial polygon/multipolygon

Optional:  
- `eu_id`: Unique identifier for the epi unit

### 1.4.3 Mapping for animal mobility

Maps columns for animal movement datasets.

Required:  
- `o_name`: Origin name  
- `d_name`: Destination name  
- `d_lng`, `d_lat`: Destination longitude/latitude

Optional:  
- `o_iso3`, `o_lng`, `o_lat`: Origin ISO3 code or coordinates  
- `d_iso3`: Destination ISO3 code  
- `quantity`: Number of animals moved

### 1.4.4 Mapping for emission risk factors

Maps columns for emission risk factors datasets (used for risk scoring).

Required:  
- `iso3`, `country`, `disease`, `animal_category`, `species`  
- Control/surveillance measures: `disease_notification`,
`targeted_surveillance`, `general_surveillance`, `screening`,
`precautions_at_the_borders`, `slaughter`,
`selective_killing_and_disposal`, `zoning`, `official_vaccination`  
- `last_outbreak_end_date`, `commerce_illegal`, `commerce_legal`

Optional:  
- `data_source`: Source of the data

Each mapping function returns a mapping object that can be passed to
`validate_dataset_content()` to standardize and validate your dataset
for use in the ‘riskintro’ analysis pipeline.

## 1.5 Emission risk factors management

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

## 1.6 References data

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
