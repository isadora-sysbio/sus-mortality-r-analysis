# ============================================================
# FIOCRUZ — Module 2, Lesson 1, Activity 3
#
# Goal:
# Compare dispersion between two cholesterol measurement methods using:
#   - var()
#   - sd()
#   - coefficient of variation
#   - group_by()
#
# This implementation uses synthetic educational data.
# ============================================================

required <- c("dplyr", "readr", "ggplot2", "tibble")

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
  library(ggplot2)
  library(tibble)
})

# ------------------------------------------------------------
# STEP 1 — CREATE TWO METHODS WITH SIMILAR CENTERS
#             BUT DIFFERENT DISPERSION
# ------------------------------------------------------------

cholesterol <- tibble(
  method = rep(c("Method A", "Method B"), each = 8),
  cholesterol_mg_dl = c(
    176, 188, 194, 201, 207, 213, 224, 237,   # wider spread
    196, 198, 199, 201, 202, 203, 205, 207    # tighter spread
  )
)

cat("\n============================================================\n")
cat("STEP 1 — DATA\n")
cat("============================================================\n")
print(cholesterol)

cat("\nQuestion:\n")
cat("If the two methods have similar means, are they equally dispersed?\n")

# ------------------------------------------------------------
# STEP 2 — WHY SIMPLE DEVIATIONS DO NOT WORK
# ------------------------------------------------------------

method_a <- cholesterol |>
  filter(method == "Method A")

mean_a <- mean(method_a$cholesterol_mg_dl)

deviation_check <- method_a |>
  mutate(
    deviation_from_mean = cholesterol_mg_dl - mean_a
  )

cat("\n============================================================\n")
cat("STEP 2 — DEVIATIONS FROM THE MEAN\n")
cat("============================================================\n")
print(deviation_check)

cat("\nSum of deviations from the mean:\n")
cat(round(sum(deviation_check$deviation_from_mean), 10), "\n")

cat("\nWhy is it ~0?\n")
cat("Positive and negative deviations cancel one another.\n")
cat("That is why variance uses SQUARED deviations.\n")

# ------------------------------------------------------------
# STEP 3 — GROUPED DISPERSION SUMMARY
# ------------------------------------------------------------

dispersion_summary <- cholesterol |>
  group_by(method) |>
  summarise(
    n = n(),
    mean_mg_dl = mean(cholesterol_mg_dl),
    variance = var(cholesterol_mg_dl),
    sd_mg_dl = sd(cholesterol_mg_dl),
    cv_percent = 100 * sd(cholesterol_mg_dl) / mean(cholesterol_mg_dl),
    iqr_mg_dl = IQR(cholesterol_mg_dl),
    .groups = "drop"
  ) |>
  mutate(
    mean_mg_dl = round(mean_mg_dl, 2),
    variance = round(variance, 2),
    sd_mg_dl = round(sd_mg_dl, 2),
    cv_percent = round(cv_percent, 2),
    iqr_mg_dl = round(iqr_mg_dl, 2)
  )

cat("\n============================================================\n")
cat("STEP 3 — DISPERSION SUMMARY\n")
cat("============================================================\n")
print(dispersion_summary)

cat("\nInterpretation guide:\n")
cat("- Variance is in squared units: (mg/dL)^2\n")
cat("- Standard deviation returns to mg/dL\n")
cat("- CV is unitless and expressed here as a percentage\n")
cat("- Lower SD/CV means values are more concentrated around the mean\n")

# ------------------------------------------------------------
# STEP 4 — COMPARE RELATIVE DISPERSION
# ------------------------------------------------------------

most_precise <- dispersion_summary |>
  arrange(cv_percent) |>
  slice(1)

cat("\n============================================================\n")
cat("STEP 4 — WHICH METHOD IS MORE CONCENTRATED?\n")
cat("============================================================\n")
cat(
  most_precise$method,
  "has the lower coefficient of variation:",
  most_precise$cv_percent,
  "%\n"
)

cat(
  "So, relative to its mean,",
  most_precise$method,
  "shows less dispersion in this synthetic example.\n"
)

# ------------------------------------------------------------
# STEP 5 — SAVE TABLES
# ------------------------------------------------------------

write_csv(
  cholesterol,
  "practice/manual_attempts/module2_lesson1/activity03_dispersion_measures/outputs/synthetic_cholesterol_methods.csv"
)

write_csv(
  dispersion_summary,
  "practice/manual_attempts/module2_lesson1/activity03_dispersion_measures/outputs/dispersion_summary.csv"
)

write_csv(
  deviation_check,
  "practice/manual_attempts/module2_lesson1/activity03_dispersion_measures/outputs/deviation_check_method_a.csv"
)

# ------------------------------------------------------------
# STEP 6 — FIGURE
# ------------------------------------------------------------

p <- ggplot(
  cholesterol,
  aes(x = method, y = cholesterol_mg_dl)
) +
  geom_boxplot(width = 0.45, outlier.shape = NA) +
  geom_jitter(width = 0.08, size = 2.8, alpha = 0.8) +
  labs(
    title = "Similar centers can hide very different dispersion",
    subtitle = "Synthetic comparison of two cholesterol measurement methods",
    x = NULL,
    y = "Cholesterol (mg/dL)",
    caption = "Synthetic educational data."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson1/activity03_dispersion_measures/outputs/cholesterol_dispersion_comparison.png",
  p,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 7 — VALIDATION
# ------------------------------------------------------------

stopifnot(nrow(dispersion_summary) == 2)
stopifnot(all(dispersion_summary$variance > 0))
stopifnot(all(dispersion_summary$sd_mg_dl > 0))
stopifnot(all(dispersion_summary$cv_percent > 0))

cv_a <- dispersion_summary$cv_percent[
  dispersion_summary$method == "Method A"
]

cv_b <- dispersion_summary$cv_percent[
  dispersion_summary$method == "Method B"
]

stopifnot(cv_b < cv_a)

cat("\n============================================================\n")
cat("✅ ACTIVITY 3 PASSED\n")
cat("============================================================\n")
cat("Functions practiced: var(), sd(), group_by(), summarise()\n")
cat("Relative dispersion: coefficient of variation\n")
cat("Method B correctly identified as the less dispersed method.\n")
