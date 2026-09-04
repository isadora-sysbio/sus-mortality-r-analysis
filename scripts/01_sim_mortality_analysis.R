# ==============================================================================
# Mortality Data Analysis in R
# Brazilian Unified Health System (SUS)
#
# Developed as an independent analytical exercise while completing
# the Campus Virtual Fiocruz course:
# "Introdução à Análise de Dados para Pesquisa no SUS"
#
# Data source:
# Sistema de Informações sobre Mortalidade (SIM)
#
# Usage:
#
# Rscript scripts/01_sim_mortality_analysis.R \
#   /path/to/sim_salvador_2023_processado.csv \
#   results/tables
#
# Original educational materials and raw data are not redistributed here.
# ==============================================================================


required_packages <- c(
  "dplyr",
  "readr",
  "lubridate"
)

missing_packages <- required_packages[
  !vapply(
    required_packages,
    requireNamespace,
    FUN.VALUE = logical(1),
    quietly = TRUE
  )
]

if (length(missing_packages) > 0) {
  stop(
    paste0(
      "Missing required R packages: ",
      paste(missing_packages, collapse = ", "),
      "\nInstall them before running this analysis."
    )
  )
}

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(lubridate)
})


# ------------------------------------------------------------------------------
# Command-line arguments
# ------------------------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
  stop(
    paste(
      "Usage:",
      "Rscript scripts/01_sim_mortality_analysis.R",
      "/path/to/dataset.csv",
      "[output_directory]"
    )
  )
}

input_file <- args[[1]]

output_dir <- if (length(args) >= 2) {
  args[[2]]
} else {
  "results/tables"
}

if (!file.exists(input_file)) {
  stop("Input dataset not found: ", input_file)
}

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# ------------------------------------------------------------------------------
# Import
# ------------------------------------------------------------------------------

sim <- read_csv(
  input_file,
  show_col_types = FALSE
)

required_columns <- c(
  "DTOBITO_dt",
  "idade_anos",
  "sexo_p"
)

missing_columns <- setdiff(
  required_columns,
  names(sim)
)

if (length(missing_columns) > 0) {
  stop(
    paste0(
      "Dataset is missing required columns: ",
      paste(missing_columns, collapse = ", ")
    )
  )
}


# ------------------------------------------------------------------------------
# Data preparation
# ------------------------------------------------------------------------------

sim <- sim %>%
  mutate(

    DTOBITO_dt = as.Date(DTOBITO_dt),

    faixa_etaria = case_when(
      idade_anos >= 0  & idade_anos <= 12 ~ "Child",
      idade_anos >= 13 & idade_anos <= 17 ~ "Adolescent",
      idade_anos >= 18 & idade_anos <= 59 ~ "Adult",
      idade_anos >= 60 ~ "Older adult",
      TRUE ~ NA_character_
    ),

    mes = month(DTOBITO_dt),

    trimestre = case_when(
      mes %in% 1:3   ~ "Q1",
      mes %in% 4:6   ~ "Q2",
      mes %in% 7:9   ~ "Q3",
      mes %in% 10:12 ~ "Q4",
      TRUE ~ NA_character_
    )

  )


# ------------------------------------------------------------------------------
# Analysis 1 — Mortality by age group
# ------------------------------------------------------------------------------

mortality_by_age_group <- sim %>%
  filter(!is.na(faixa_etaria)) %>%
  count(
    faixa_etaria,
    name = "deaths",
    sort = TRUE
  )

write_csv(
  mortality_by_age_group,
  file.path(
    output_dir,
    "mortality_by_age_group.csv"
  )
)


# ------------------------------------------------------------------------------
# Analysis 2 — Quarterly mortality by sex
# ------------------------------------------------------------------------------

quarterly_mortality_by_sex <- sim %>%
  group_by(
    trimestre,
    sexo_p
  ) %>%
  summarise(
    deaths = n(),
    mean_age = round(
      mean(
        idade_anos,
        na.rm = TRUE
      ),
      2
    ),
    .groups = "drop"
  ) %>%
  arrange(
    trimestre,
    desc(deaths)
  )

write_csv(
  quarterly_mortality_by_sex,
  file.path(
    output_dir,
    "quarterly_mortality_by_sex.csv"
  )
)


# ------------------------------------------------------------------------------
# Analysis 3 — Monthly mortality
# ------------------------------------------------------------------------------

monthly_mortality <- sim %>%
  count(
    mes,
    name = "deaths",
    sort = TRUE
  )

write_csv(
  monthly_mortality,
  file.path(
    output_dir,
    "monthly_mortality.csv"
  )
)


# ------------------------------------------------------------------------------
# Analysis 4 — Mortality distribution by sex
# ------------------------------------------------------------------------------

mortality_by_sex <- sim %>%
  filter(
    sexo_p %in% c(
      "Masculino",
      "Feminino"
    )
  ) %>%
  count(
    sexo_p,
    name = "deaths"
  ) %>%
  mutate(
    percentage = round(
      deaths / sum(deaths) * 100,
      2
    )
  )

write_csv(
  mortality_by_sex,
  file.path(
    output_dir,
    "mortality_by_sex.csv"
  )
)


# ------------------------------------------------------------------------------
# Console summary
# ------------------------------------------------------------------------------

cat("\nMortality by age group\n")
print(mortality_by_age_group)

cat("\nQuarterly mortality by sex\n")
print(quarterly_mortality_by_sex)

cat("\nMonthly mortality\n")
print(monthly_mortality)

cat("\nMortality by sex\n")
print(mortality_by_sex)

cat(
  "\nAnalysis completed successfully.\n",
  "Results written to: ",
  normalizePath(output_dir),
  "\n",
  sep = ""
)
