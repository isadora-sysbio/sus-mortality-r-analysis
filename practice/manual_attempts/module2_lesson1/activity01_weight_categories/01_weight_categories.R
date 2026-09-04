# ============================================================
# FIOCRUZ — Module 2, Lesson 1, Activity 1
# Practice goal:
#   1. create a small dataset with a continuous variable (weight)
#   2. transform weight into ordered categories
#   3. summarize and visualize the new categorical variable
#
# This is an original portfolio-safe practice dataset.
# ============================================================

required <- c("dplyr", "readr", "ggplot2", "tibble")

missing <- required[
  !vapply(required, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)
]

if (length(missing) > 0) {
  stop(
    "Missing R packages: ",
    paste(missing, collapse = ", "),
    "\nInstall them once with install.packages(...), then rerun."
  )
}

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(tibble)
})

# STEP 1 — CREATE THE DATASET
# peso_kg is quantitative continuous because it can include decimals.

patients <- tibble(
  patient_id = 1:15,
  peso_kg = c(
    48.2, 52.7, 58.9, 60.0, 63.4,
    67.8, 71.2, 74.5, 78.9, 79.9,
    80.0, 83.6, 88.1, 92.4, 101.3
  )
)

cat("\nSTEP 1 — Original continuous variable\n")
print(patients)

# STEP 2 — RECODE WITH mutate() + case_when()

patients_categorized <- patients |>
  mutate(
    weight_category = case_when(
      peso_kg < 60 ~ "< 60 kg",
      peso_kg < 80 ~ "60–79.9 kg",
      TRUE ~ "≥ 80 kg"
    ),
    weight_category = factor(
      weight_category,
      levels = c("< 60 kg", "60–79.9 kg", "≥ 80 kg"),
      ordered = TRUE
    )
  )

cat("\nSTEP 2 — Continuous weight transformed into an ordinal variable\n")
print(patients_categorized)

# STEP 3 — CHECK THE RESULT

category_summary <- patients_categorized |>
  count(weight_category, name = "n") |>
  mutate(
    percent = round(100 * n / sum(n), 1)
  )

cat("\nSTEP 3 — Category summary\n")
print(category_summary)

# STEP 4 — SAVE OUTPUTS

write_csv(
  patients_categorized,
  "practice/manual_attempts/module2_lesson1/activity01_weight_categories/outputs/weights_categorized.csv"
)

write_csv(
  category_summary,
  "practice/manual_attempts/module2_lesson1/activity01_weight_categories/outputs/category_summary.csv"
)

# STEP 5 — MAKE A SIMPLE PORTFOLIO FIGURE

p <- ggplot(
  category_summary,
  aes(x = weight_category, y = n)
) +
  geom_col(width = 0.65) +
  geom_text(
    aes(label = paste0(n, " (", percent, "%)")),
    vjust = -0.4,
    size = 4
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.16))
  ) +
  labs(
    title = "Weight recoded from a continuous to an ordinal variable",
    subtitle = "Didactic categories created with dplyr::mutate() and case_when()",
    x = "Ordered weight category",
    y = "Number of observations",
    caption = "Synthetic practice data; categories are educational, not clinical cutoffs."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson1/activity01_weight_categories/outputs/weight_category_distribution.png",
  p,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# STEP 6 — AUTOMATED CHECKS

stopifnot(nrow(patients) == nrow(patients_categorized))
stopifnot(!any(is.na(patients_categorized$weight_category)))
stopifnot(is.ordered(patients_categorized$weight_category))
stopifnot(sum(category_summary$n) == nrow(patients))

cat("\n============================================================\n")
cat("✅ ACTIVITY 1 PASSED\n")
cat("Continuous variable: peso_kg\n")
cat("New ordinal variable: weight_category\n")
cat("Rows preserved:", nrow(patients_categorized), "\n")
cat("============================================================\n")
