# ============================================================
# FIOCRUZ — Module 2, Lesson 1, Activity 2
#
# Goal:
#   calculate mean, median and quantiles for newborn weights
#   and understand how an extreme value affects them.
#
# Portfolio-safe implementation:
#   synthetic educational newborn-weight data.
# ============================================================

required <- c("dplyr", "readr", "ggplot2", "tibble")

missing <- required[
  !vapply(required, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)
]

if (length(missing) > 0) {
  stop(
    "Missing R packages: ",
    paste(missing, collapse = ", "),
    "\nInstall them once and rerun."
  )
}

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(tibble)
})

# ------------------------------------------------------------
# STEP 1 — CREATE SYNTHETIC NEWBORN-WEIGHT DATA
# ------------------------------------------------------------

newborns <- tibble(
  newborn_id = 1:20,
  birth_weight_g = c(
    2410, 2585, 2710, 2830, 2945,
    3010, 3095, 3160, 3220, 3260,
    3295, 3340, 3390, 3445, 3510,
    3575, 3630, 3715, 3820, 3985
  )
)

cat("\n============================================================\n")
cat("STEP 1 — DATA\n")
cat("============================================================\n")
print(newborns)

cat("\nQuestion to keep in mind:\n")
cat("Where is the 'center' of these 20 birth weights?\n")

# ------------------------------------------------------------
# STEP 2 — MEAN
# ------------------------------------------------------------

mean_weight <- mean(newborns$birth_weight_g)

cat("\n============================================================\n")
cat("STEP 2 — MEAN\n")
cat("============================================================\n")
cat("Formula idea: add all values and divide by n.\n")
cat("R command: mean(newborns$birth_weight_g)\n")
cat("Mean birth weight:", round(mean_weight, 1), "g\n")

# ------------------------------------------------------------
# STEP 3 — MEDIAN
# ------------------------------------------------------------

median_weight <- median(newborns$birth_weight_g)

cat("\n============================================================\n")
cat("STEP 3 — MEDIAN\n")
cat("============================================================\n")
cat("With 20 observations, the median lies halfway between\n")
cat("the 10th and 11th ordered observations.\n")
cat("10th value:", newborns$birth_weight_g[10], "g\n")
cat("11th value:", newborns$birth_weight_g[11], "g\n")
cat("Median birth weight:", median_weight, "g\n")

# ------------------------------------------------------------
# STEP 4 — QUANTILES
# ------------------------------------------------------------

quantile_probs <- c(0.10, 0.25, 0.50, 0.75, 0.90)

qs <- quantile(
  newborns$birth_weight_g,
  probs = quantile_probs,
  na.rm = TRUE
)

quantile_table <- tibble(
  quantile = c("P10", "Q1 / P25", "Median / P50", "Q3 / P75", "P90"),
  probability = quantile_probs,
  birth_weight_g = as.numeric(qs)
)

cat("\n============================================================\n")
cat("STEP 4 — QUANTILES\n")
cat("============================================================\n")
print(quantile_table)

cat("\nInterpretation example:\n")
cat("P90 is a value at or below which roughly 90% of observations lie.\n")

# ------------------------------------------------------------
# STEP 5 — OUTLIER SENSITIVITY
# ------------------------------------------------------------
# Create a copy in which the first value is replaced by an
# implausibly low value to illustrate sensitivity.

newborns_with_extreme <- newborns
newborns_with_extreme$birth_weight_g[1] <- 650

comparison <- tibble(
  dataset = c("Original", "With extreme value"),
  mean_g = c(
    mean(newborns$birth_weight_g),
    mean(newborns_with_extreme$birth_weight_g)
  ),
  median_g = c(
    median(newborns$birth_weight_g),
    median(newborns_with_extreme$birth_weight_g)
  )
) |>
  mutate(
    mean_g = round(mean_g, 1),
    median_g = round(median_g, 1)
  )

cat("\n============================================================\n")
cat("STEP 5 — WHAT DOES AN EXTREME VALUE DO?\n")
cat("============================================================\n")
print(comparison)

cat("\nMain lesson:\n")
cat("- The mean uses the magnitude of every observation.\n")
cat("- The median depends mainly on position after sorting.\n")
cat("- Therefore the mean is usually more sensitive to extreme values.\n")

# ------------------------------------------------------------
# STEP 6 — SAVE TABLES
# ------------------------------------------------------------

summary_table <- tibble(
  n = nrow(newborns),
  mean_g = round(mean_weight, 1),
  median_g = median_weight,
  p10_g = as.numeric(qs[1]),
  q1_g = as.numeric(qs[2]),
  q2_g = as.numeric(qs[3]),
  q3_g = as.numeric(qs[4]),
  p90_g = as.numeric(qs[5])
)

write_csv(
  newborns,
  "practice/manual_attempts/module2_lesson1/activity02_location_measures/outputs/synthetic_newborn_weights.csv"
)

write_csv(
  summary_table,
  "practice/manual_attempts/module2_lesson1/activity02_location_measures/outputs/location_summary.csv"
)

write_csv(
  quantile_table,
  "practice/manual_attempts/module2_lesson1/activity02_location_measures/outputs/quantiles.csv"
)

write_csv(
  comparison,
  "practice/manual_attempts/module2_lesson1/activity02_location_measures/outputs/outlier_sensitivity.csv"
)

# ------------------------------------------------------------
# STEP 7 — FIGURE
# ------------------------------------------------------------

plot_data <- newborns |>
  mutate(order = row_number())

p <- ggplot(plot_data, aes(x = birth_weight_g, y = 1)) +
  geom_jitter(
    height = 0.05,
    width = 0,
    size = 2.8,
    alpha = 0.8
  ) +
  geom_vline(
    xintercept = mean_weight,
    linetype = "dashed",
    linewidth = 0.8
  ) +
  geom_vline(
    xintercept = median_weight,
    linewidth = 0.8
  ) +
  annotate(
    "text",
    x = mean_weight,
    y = 1.17,
    label = paste0("Mean = ", round(mean_weight, 1), " g"),
    angle = 90,
    hjust = 0
  ) +
  annotate(
    "text",
    x = median_weight,
    y = 0.78,
    label = paste0("Median = ", median_weight, " g"),
    angle = 90,
    hjust = 1
  ) +
  labs(
    title = "Location of synthetic newborn birth weights",
    subtitle = "Mean, median and the distribution of individual observations",
    x = "Birth weight (g)",
    y = NULL,
    caption = "Synthetic educational data."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold")
  )

ggsave(
  "practice/manual_attempts/module2_lesson1/activity02_location_measures/outputs/location_measures.png",
  p,
  width = 9,
  height = 4.8,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 8 — VALIDATION
# ------------------------------------------------------------

stopifnot(nrow(newborns) == 20)
stopifnot(!any(is.na(newborns$birth_weight_g)))
stopifnot(median_weight == mean(c(
  newborns$birth_weight_g[10],
  newborns$birth_weight_g[11]
)))
stopifnot(comparison$mean_g[2] < comparison$mean_g[1])
stopifnot(comparison$median_g[2] == comparison$median_g[1])

cat("\n============================================================\n")
cat("✅ ACTIVITY 2 PASSED\n")
cat("============================================================\n")
cat("Mean:", round(mean_weight, 1), "g\n")
cat("Median:", median_weight, "g\n")
cat("Quantiles calculated: P10, Q1, Q2, Q3, P90\n")
cat("Extreme-value sensitivity demonstrated successfully.\n")
