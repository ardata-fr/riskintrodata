#' @title Create a DuckDB Connection
#' @description
#' The function establishes a connection to a DuckDB database at a
#' specified location.
#' @param location The file path to the DuckDB database. This can be a file path
#' to an existing DuckDB file, or a new path to create a database.
#' @return A `DBI` connection object representing the connection to the DuckDB
#' database.
#' @export
#' @examples
#' # Create a connection to a DuckDB database
#' tf <- tempfile(fileext = ".duckdb")
#' con <- conn_ri(tf)
#' # Use the connection as needed
#' DBI::dbDisconnect(con, shutdown = TRUE) # Remember to disconnect when done
conn_ri <- function(location) {
  # Connect to the DuckDB database at the specified location
  conn <- DBI::dbConnect(duckdb(), location)
  conn
}
