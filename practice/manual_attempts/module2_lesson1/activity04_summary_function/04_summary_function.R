# ============================================================
# FIOCRUZ — Module 2, Lesson 1, Activity 4
#
# Goal:
# Create a reusable function that calculates a complete
# descriptive-statistics summary for a numeric variable.
#
# Main new idea:
#   function(dados, variavel) { ... }
#
# The {{ variavel }} syntax lets dplyr receive an unquoted
# column name inside our own function.
# ============================================================

required <- c("dplyr", "readr", "tibble")

missing <- required[
  !vapply(required, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)
]

if (length(missing) > 0) {
  stop(
    "Missing R packages: ",
    paste(missing, collapse = ", "),
    "\nInstall them once, then rerun."
  )
}

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tibble)
})

# ------------------------------------------------------------
# STEP 1 — CREATE A SMALL SYNTHETIC DATASET
# ------------------------------------------------------------

newborns <- tibble(
  newborn_id = 1:20,
  birth_weight_g = c(
    2410, 2585, 2710, 2830, 2945,
    3010, 3095, 3160, 3220, 3260,
    3295, 3340, 3390, 3445, 3510,
    3575, 3630, 3715, 3820, 3985
  ),
  length_cm = c(
    45.8, 46.2, 46.9, 47.4, 47.8,
    48.1, 48.5, 48.8, 49.0, 49.2,
    49.4, 49.7, 50.0, 50.3, 50.7,
    51.0, 51.2, 51.5, 52.0, 52.4
  )
)

cat("\n============================================================\n")
cat("STEP 1 — DATA\n")
cat("============================================================\n")
print(newborns)

# ------------------------------------------------------------
# STEP 2 — WHY WRITE A FUNCTION?
# ------------------------------------------------------------

cat("\n============================================================\n")
cat("STEP 2 — WHY A FUNCTION?\n")
cat("============================================================\n")
cat("Without a function, we repeat the same summarise() code\n")
cat("for every numeric variable.\n")
cat("\n")
cat("A function lets us define the recipe ONCE and reuse it.\n")

# ------------------------------------------------------------
# STEP 3 — CREATE THE FUNCTION
# ------------------------------------------------------------

summary_stats <- function(data, variable) {

  data |>
    summarise(
      n = sum(!is.na({{ variable }})),
      mean = mean({{ variable }}, na.rm = TRUE),
      median = median({{ variable }}, na.rm = TRUE),
      sd = sd({{ variable }}, na.rm = TRUE),
      cv_percent = 100 * sd({{ variable }}, na.rm = TRUE) /
        mean({{ variable }}, na.rm = TRUE),
      minimum = min({{ variable }}, na.rm = TRUE),
      q1 = quantile({{ variable }}, 0.25, na.rm = TRUE),
      q3 = quantile({{ variable }}, 0.75, na.rm = TRUE),
      maximum = max({{ variable }}, na.rm = TRUE),
      iqr = q3 - q1
    ) |>
    mutate(
      across(
        where(is.numeric),
        ~ round(.x, 2)
      )
    )
}

cat("\n============================================================\n")
cat("STEP 3 — FUNCTION CREATED\n")
cat("============================================================\n")
cat("Function name: summary_stats(data, variable)\n")
cat("\n")
cat("Important syntax:\n")
cat("  {{ variable }}\n")
cat("\n")
cat("This lets us call:\n")
cat("  summary_stats(newborns, birth_weight_g)\n")
cat("instead of passing the column as a quoted string.\n")

# ------------------------------------------------------------
# STEP 4 — APPLY TO BIRTH WEIGHT
# ------------------------------------------------------------

weight_summary <- summary_stats(
  newborns,
  birth_weight_g
)

cat("\n============================================================\n")
cat("STEP 4 — BIRTH-WEIGHT SUMMARY\n")
cat("============================================================\n")
print(weight_summary)

# ------------------------------------------------------------
# STEP 5 — REUSE THE SAME FUNCTION ON ANOTHER VARIABLE
# ------------------------------------------------------------

length_summary <- summary_stats(
  newborns,
  length_cm
)

cat("\n============================================================\n")
cat("STEP 5 — SAME FUNCTION, DIFFERENT VARIABLE\n")
cat("============================================================\n")
print(length_summary)

cat("\nMain lesson:\n")
cat("The statistical recipe did not change.\n")
cat("Only the variable supplied to the function changed.\n")

# ------------------------------------------------------------
# STEP 6 — MAKE A LONG COMPARISON TABLE
# ------------------------------------------------------------

comparison <- bind_rows(
  weight_summary |>
    mutate(variable = "Birth weight (g)", .before = 1),
  length_summary |>
    mutate(variable = "Length (cm)", .before = 1)
)

cat("\n============================================================\n")
cat("STEP 6 — COMPARISON\n")
cat("============================================================\n")
print(comparison)

# ------------------------------------------------------------
# STEP 7 — SAVE OUTPUTS
# ------------------------------------------------------------

write_csv(
  newborns,
  "practice/manual_attempts/module2_lesson1/activity04_summary_function/outputs/synthetic_newborn_measurements.csv"
)

write_csv(
  weight_summary,
  "practice/manual_attempts/module2_lesson1/activity04_summary_function/outputs/birth_weight_summary.csv"
)

write_csv(
  length_summary,
  "practice/manual_attempts/module2_lesson1/activity04_summary_function/outputs/length_summary.csv"
)

write_csv(
  comparison,
  "practice/manual_attempts/module2_lesson1/activity04_summary_function/outputs/summary_function_comparison.csv"
)

# ------------------------------------------------------------
# STEP 8 — VALIDATION
# ------------------------------------------------------------

required_columns <- c(
  "n",
  "mean",
  "median",
  "sd",
  "cv_percent",
  "minimum",
  "q1",
  "q3",
  "maximum",
  "iqr"
)

stopifnot(
  all(required_columns %in% names(weight_summary))
)

stopifnot(
  all(required_columns %in% names(length_summary))
)

stopifnot(weight_summary$n == 20)
stopifnot(length_summary$n == 20)

stopifnot(
  abs(
    weight_summary$iqr -
      (weight_summary$q3 - weight_summary$q1)
  ) < 0.01
)

stopifnot(
  abs(
    length_summary$iqr -
      (length_summary$q3 - length_summary$q1)
  ) < 0.01
)

cat("\n============================================================\n")
cat("✅ ACTIVITY 4 PASSED\n")
cat("============================================================\n")
cat("You created and reused a custom R function.\n")
cat("Statistics included:\n")
cat("  n, mean, median, SD, CV, min, Q1, Q3, max, IQR\n")
cat("\n")
cat("The same function worked for TWO variables.\n")
