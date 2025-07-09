#' @importFrom cli
#'  cli_abort cli_warn ansi_strip cli_h3 cli_ul cli_ol cli_li cli_alert_success
#' @importFrom sf
#'  as_Spatial read_sf sf_use_s2 st_area st_as_sf st_as_text st_bbox st_cast
#'  st_coordinates st_crs st_difference st_drop_geometry st_geometry_type
#'  st_intersection st_intersects st_is_empty st_join st_length st_line_merge
#'  st_make_valid st_nearest_feature st_point_on_surface st_polygon st_sfc
#'  st_snap st_transform st_union st_write
#' @importFrom DBI
#'  dbConnect dbDisconnect dbReadTable dbWriteTable dbListFields dbListTables
#'  dbIsValid dbExistsTable
#' @importFrom duckdb duckdb
#' @importFrom terra
#'  rast
#' @importFrom dbplyr
#'  window_order
#' @importFrom tibble
#'  tibble
#' @importFrom dplyr
#'  arrange distinct filter rename select mutate summarise
#'  group_by rowwise ungroup
#'  bind_rows rows_append rows_delete rows_update rows_upsert
#'  anti_join inner_join left_join right_join
#'  across all_of everything starts_with
#'  between c_across desc first row_number case_when coalesce if_else
#'  n_distinct n
#'  cur_column cur_group_id
#'  collect compute pull tbl
#' @importFrom readr
#'  read_delim cols col_character col_double col_integer col_date
#' @importFrom stats
#'  na.omit
#' @importFrom validate
#'  validator confront summary
#' @importFrom glue
#'  glue glue_collapse
#' @importFrom tools
#'  file_ext
#' @importFrom yaml
#'  read_yaml write_yaml
#' @importFrom curl
#'  curl_download
#' @importFrom utils
#'  globalVariables
NULL
