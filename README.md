
<!-- README.md is generated from README.Rmd. Please edit that file -->

# riskintrodata

The ‘riskintrodata’ package is designed to provide a set of functions
and datasets  
that support the management of data used to estimate the risk of
introducing an animal  
disease into a specific geographical region.

It includes tools for reading and validating both geographic and tabular
datasets  
commonly used in the context of animal disease risk estimation.

## Motivation

The primary motivation for creating ‘riskintrodata’ is to isolate and
centralize the datasets and data import functions required by the
‘riskintro’ application  
into a dedicated package. This separation simplifies testing, improves
clarity,  
and makes it easier to document the datasets used in the application in
a structured way.

Additionally, the ‘riskintrodata’ package is designed to simplify
package management.  
It helps reduce the complexity of handling the numerous packages
required by the  
‘riskintro’ application. By centralizing essential datasets and their
associated  
import functions, ‘riskintrodata’ minimizes package dependencies.

## Installation

You can install the development version of riskintrodata like so:

``` r
pak::pak("ardata-fr/riskintrodata")
```

## Usage

### Read data

``` r
library(riskintrodata)
```

The package provides functions to read and validate geographic and
tabular datasets.

To read geographic data from a file, you can use the `read_geo_file()`
function:

``` r
tun_files <-
  list.files(
    system.file(
      package = "riskintrodata",
      "samples",
      "tunisia",
      "epi_units"
    ),
    full.names = TRUE
  )
read_geo_file(tun_files)
#> Simple feature collection with 264 features and 6 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 7.52228 ymin: 30.1601 xmax: 11.59919 ymax: 37.54166
#> Geodetic CRS:  WGS 84
#> # A tibble: 264 × 7
#>      fid id    shapeName  shapeID shapeGroup shapeType                  geometry
#>    <dbl> <chr> <chr>      <chr>   <chr>      <chr>            <MULTIPOLYGON [°]>
#>  1 39510 <NA>  القصور     119338… TUN        ADM2      (((8.797576 35.77613, 8.…
#>  2 39511 <NA>  المزونة    119338… TUN        ADM2      (((9.453087 34.48146, 9.…
#>  3 39512 <NA>  العروسة    119338… TUN        ADM2      (((9.315254 36.37285, 9.…
#>  4 39513 <NA>  ماطر       119338… TUN        ADM2      (((9.517707 36.96143, 9.…
#>  5 39514 <NA>  الجم       119338… TUN        ADM2      (((10.67215 35.35733, 10…
#>  6 39515 <NA>  القصر      119338… TUN        ADM2      (((8.820876 34.437, 8.83…
#>  7 39516 <NA>  صفاقس الج… 119338… TUN        ADM2      (((10.67733 34.93905, 10…
#>  8 39517 <NA>  غزالة      119338… TUN        ADM2      (((9.628822 37.11138, 9.…
#>  9 39518 <NA>  سيدي عيش   119338… TUN        ADM2      (((8.62474 34.65819, 8.6…
#> 10 39519 <NA>  الشبيكة    119338… TUN        ADM2      (((9.83956 35.74353, 9.8…
#> # ℹ 254 more rows

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
#>    <chr>         <chr>    <chr>   <chr>      <chr>                 <POLYGON [°]>
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

There is no specific function to read tabular data, but you can use the
package ‘readr’ or ‘readxl’ to read the data if the format is CSV or
Excel.

### Validate data

The package provides a function named `validate_table_content()` to
validate the content of datasets. This function checks the structure of
the data and ensures that it meets the expected format, the function
will check:

- the presence of required columns
- the data types of the columns, mandatory or optional
- and a set of rules to validate the data.

It can be used with datasets for:

- Epi units, use `validate_table_content(..., name = "epi_units")`.
- Emission risks, use
  `validate_table_content(..., name = "emission_risk_factors")`.
- Animal mobility, use
  `validate_table_content(..., name = "animal_mobility")`.
- Entry points, use
  `validate_table_content(..., name = "entry_points")`.

The function takes a data frame or an ‘sf’ object as input, along with
the type of the dataset and any additional arguments for mapping
columns. It returns a list containing the validation status of the
dataset, i.e. the required and optional columns, the validation rules,
and the dataset itself after renaming and selecting the specified
columns.

``` r
tun_epi_files <-
  list.files(
    system.file(
      package = "riskintrodata",
      "samples",
      "tunisia",
      "epi_units"
    ),
    full.names = TRUE
  )

tun_epi_unit <- read_geo_file(tun_epi_files)

DATA_EPI_UNITS <- validate_table_content(
  x = tun_epi_unit,
  name = "epi_units",
  eu_name = "shapeName",
  user_id = "fid"
)

DATA_EPI_UNITS
#> $required_columns
#> $chk
#> [1] TRUE
#> 
#> $msg
#> [1] "All required columns selected."
#> 
#> $details
#> character(0)
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
#> [1] TRUE
#> 
#> $msg
#> 3 valid rules controling dataset.
#> 
#> $details
#>                                    label description items passes warning fails
#> 1 EU name has no missing or empty values               264    264   FALSE     0
#> 2    All values of user id are different                 1      1   FALSE     0
#> 3           No missing values of user id               264    264   FALSE     0
#>   error status extra_label
#> 1 FALSE     OK        <NA>
#> 2 FALSE     OK        <NA>
#> 3 FALSE     OK        <NA>
#> 
#> attr(,"class")
#> [1] "validation_status"
#> 
#> $dataset
#> Simple feature collection with 264 features and 2 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 7.52228 ymin: 30.1601 xmax: 11.59919 ymax: 37.54166
#> Geodetic CRS:  WGS 84
#> # A tibble: 264 × 3
#>    eu_name        user_id                                               geometry
#>    <chr>            <dbl>                                     <MULTIPOLYGON [°]>
#>  1 القصور           39510 (((8.797576 35.77613, 8.800061 35.78545, 8.806482 35.…
#>  2 المزونة          39511 (((9.453087 34.48146, 9.456919 34.48654, 9.460233 34.…
#>  3 العروسة          39512 (((9.315254 36.37285, 9.327888 36.37904, 9.332237 36.…
#>  4 ماطر             39513 (((9.517707 36.96143, 9.519985 36.97143, 9.51605 36.9…
#>  5 الجم             39514 (((10.67215 35.35733, 10.67516 35.34927, 10.68002 35.…
#>  6 القصر            39515 (((8.820876 34.437, 8.833821 34.45662, 8.842519 34.45…
#>  7 صفاقس الجنوبية   39516 (((10.67733 34.93905, 10.67826 34.93152, 10.68095 34.…
#>  8 غزالة            39517 (((9.628822 37.11138, 9.617742 37.1028, 9.619917 37.0…
#>  9 سيدي عيش         39518 (((8.62474 34.65819, 8.650837 34.67699, 8.6585 34.679…
#> 10 الشبيكة          39519 (((9.83956 35.74353, 9.838628 35.75733, 9.840595 35.7…
#> # ℹ 254 more rows
#> 
#> attr(,"class")
#> [1] "table_validation_status"
```

## References data

The package includes several reference datasets that are used in the
context of animal disease risk estimation:

- iso3 country codes, available with the function `country_reference()`.
  Also a utility function `iso3_to_name()` is provided to convert ISO3
  codes to country names.

# TODO

- [ ] document and illustrate `read_emission_risk_factor_file()`
- [ ] fortify `create_emission_risk_row()` and ensure it works as
  expected.
- [ ] *Entry point* type is in French (“PIF Aerien”), CIRAD suggested to
  use English names but the data we have is in French, so we need to
  decide whether to keep it in French or translate it to English.
