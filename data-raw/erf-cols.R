library(tidyverse)
library(jsonlite)
erf_cols <- yaml::yaml.load_file("data-raw/erf-columns.yaml")

erf_param_desc <- map(erf_cols, function(erf_col) {
  stringr::str_trim(erf_col$text)
}) |> setNames(map_chr(erf_cols, "name"))
dump("erf_param_desc", file = "R/erf_param_desc.R")

map_chr(erf_cols, function(erf_col) {
  sprintf("- `%s`: %s", erf_col$name, stringr::str_trim(erf_col$text))
}) |> writeLines(useBytes = TRUE, con = "inst/doc-md/erf-cols.md")

