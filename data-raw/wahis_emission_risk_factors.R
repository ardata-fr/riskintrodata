## code to prepare data from probability d'emission Excel file
## data located in 'data-src'

data_source <- "https://wahis.woah.org/#/dashboards/control-measure-dashboard"

# How to -----------------------------------------------------------------------
#
# Steps to download data:
#
#   1.  Go to the above link, ensure you are browsing in English, as
#       this will have an impact on the column names of downloaded data.
#
#   2.  Filter for the most recent year,
#
#   3.  Scroll down to the "Liste des mesuresde lutte" table and click export
#       (on the right)
#
# The CSV you have just downloaded is the input data for this script and should
# be placed in 'data-src' folder of this R package.

# Setup ------------------------------------------------------------------------

# Packages
libs <- c(
  "tidyverse", "readxl", "janitor", "countries", "riskintro"
)
installed_libs <- libs %in% rownames(installed.packages())

if (any(installed_libs == FALSE)) {
  install.packages(libs[!installed_libs], dependencies = TRUE)
}

lapply(
  libs, library,
  character.only = TRUE
)

# On garde seulement les données les plus recentes
ensure_most_recent <- function(dat) {
  out <- dat |>
    mutate(
      semester_factor = if_else(str_detect(semester, "Jan-Jun"), 1, 2),
      semester_rank = year + semester_factor / 10
    ) |>
    filter(semester_rank == max(semester_rank)) |>
    select(-semester_factor, -semester_rank)
  out
}

# Check that primary keys are valid
check_pk <- function(dat, PKcols) {
  nr <- dat |>
    group_by(across(all_of(PKcols))) |>
    filter(n() > 1) |>
    nrow()
  if (nr == 0) {
    cli::cli_alert_success("The primary key(s) is unique!")
  } else {
    cli::cli_abort("The primary key(s) is not unique!")
  }
}


# WAHIS Imports - Mesures de lutte et de surveillance --------------------------

## Mesures de Lutte -------------------------

file_name <- "Surveillance and control measures - List of control measures 2024-12-11.csv"
surv_ctrl_measures_fp <- file.path("data-raw/", file_name)

raw_dat <- readr::read_csv(
  surv_ctrl_measures_fp,
  na = c("", "NA", "-"),
  col_types = cols(
    Year = col_double(),
    Semester = col_character(),
    Region = col_character(),
    Country = col_character(),
    Disease = col_character(),
    `Animal Category` = col_character(),
    Species = col_character(),
    `Control measure` = col_character()
  )
) |>
  janitor::clean_names() |>
  mutate(
    year_semester = paste0(year, "_S", if_else(str_detect(semester, "Jul-Dec"), 2, 1))
  ) |>
  filter(
    .by = c(country, disease, animal_category, species, control_measure),
    year_semester == max(year_semester)
  ) |>
  mutate(
    year = NULL,
    year_semester = NULL,
    region = NULL
  ) |>
  rename(
    source_date = semester
  ) |>
  filter(!is.na(control_measure), !is.na(disease), !is.na(species), !is.na(animal_category))

# raw_dat |>
#   count(year_semester) |>
#   mutate(pct = round(n / sum(n) *100, 2)) |>
#   View()

# If the data is missing then there is no measure in place currently,
# therefore the risk is high.
#   1 is for no measure (no measure),
#   0 is for existing measure (low risk)

pivot_dat <- raw_dat |>
  mutate(flag = 0) |>
  pivot_wider(
    names_from = control_measure,
    values_from = flag,
    values_fill = 1 # all existing values are 0 and if they aren't its 1
  ) |>
  janitor::clean_names() |>
  mutate(
    iso3 = countries::country_name(
      country,
      to = "ISO3", verbose = TRUE
    ),
    .before = 1
  ) |>
  mutate(
    # https://en.wikipedia.org/wiki/ISO_3166-2:ES
    iso3 = if_else(country == "Melilla", "ES-ML", iso3),
    iso3 = if_else(country == "Ceuta", "ES-CE", iso3)
  )

iso3_na <- filter(pivot_dat, is.na(iso3))

pivot_dat <- filter(pivot_dat, !is.na(iso3))

pivot_dat |>
  count(iso3, country, disease, animal_category, species) |>
  filter(n > 1)

PKcols <- c("iso3", "country", "disease", "animal_category", "species")
check_pk(pivot_dat, PKcols)

# emission_risk_cols_fr <-c(
#   PKcols,
#   "notification_de_maladies",
#   "surveillance_ciblee",
#   "surveillance_de_routine",
#   "depistage",                  # OU SUIVI
#   "precautions_aux_frontieres",
#   "abattage_sanitaire",
#   "mise_a_mort_selective_et_elimination",
#   "restriction_des_deplacements",
#   "vaccination_officielle"
# )


# Weights ------------------------
# Weights is a named vector, all names of each element correspond
# with a column in the emissions risk table.

emission_risk_weights <- list(
  "disease_notification" = 0.25,
  "targeted_surveillance" = 0.5,
  "general_surveillance" = 0.5,
  "screening" = 0.75,
  "precautions_at_the_borders" = 1,
  "slaughter" = 0.5,
  "selective_killing_and_disposal" = 0.5,
  "zoning" = 0.75,
  "official_vaccination" = 0.25
)

emission_risk_cols <- c(
  PKcols,
  names(emission_risk_weights)
)

emission_risk_factors_sans_outbreak <- pivot_dat |>
  select(all_of(emission_risk_cols))


# Outbreaks --------------------------------------------------

outbreak_fp <- "data-raw/wahis_outbreaks_2022_2024.xlsx"

outbreaks <- read_excel(outbreak_fp) |>
  select(epi_event_id,
    iso3 = iso_code, country,
    Species, is_wild, disease = disease_eng,
    last_outbreak_end_date = Outbreak_end_date
  ) |>
  janitor::clean_names() |>
  mutate(
    animal_category = if_else(
      is_wild, "Wild", "Domestic"
    ),
    .after = is_wild
  ) |>
  select(-is_wild) |>
  mutate(
    last_outbreak_end_date = as.Date(last_outbreak_end_date)
  ) |>
  # Get most recent outbreaks
  filter(
    .by = c(iso3, species, animal_category, disease),
    last_outbreak_end_date == max(last_outbreak_end_date)
  ) |>
  # If multiple most recent, pick one
  filter(
    .by = c(iso3, species, animal_category, disease),
    row_number() == 1L
  ) |>
  select(all_of(PKcols), last_outbreak_end_date)


emission_risk_factor_defaults <- emission_risk_factors_sans_outbreak |>
  left_join(
    outbreaks,
    by = PKcols
  ) |>
  mutate(
    data_source = "WAHIS"
  ) |>
  mutate(
    # Initialise animal_mobility which has no defaults
    # animal_mobility = factor(NA, levels = c('None', "Legal", "Illegal")),
    commerce_illegal = 0L,
    commerce_legal = 0L,
    .after = last_outbreak_end_date
  ) |>
  select(all_of(emission_risk_cols), last_outbreak_end_date, commerce_illegal, commerce_legal, data_source)

# Final outputs ---------------------------------

wahis_emission_risk_factors <- emission_risk_factor_defaults |>
  mutate(
    across(
      where(is.numeric),
      as.integer
    )
  ) |>
  validate_dataset(
    table_name = "emission_risk_factors"
  ) |>
  validate_dataset_cli_msg()


epistatus_source_info <- list(
  data_source = data_source,
  data_wahis_update = NA_character_,
  data_app_update = Sys.Date(),
  file_name = basename(outbreak_fp)
)

emission_risk_source_info <- list(
  data_source = data_source,
  date_wahis_update = unique(raw_dat$source_date),
  data_app_update = Sys.Date(),
  file_name = basename(surv_ctrl_measures_fp)
)
