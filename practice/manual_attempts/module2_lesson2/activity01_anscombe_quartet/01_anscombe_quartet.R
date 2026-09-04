# ============================================================
# FIOCRUZ — Module 2, Lesson 2, Activity 1
#
# Anscombe's Quartet
#
# Goal:
#   calculate nearly identical summary statistics for four
#   datasets and then visualize why the datasets are NOT
#   analytically equivalent.
#
# Main lesson:
#   numerical summaries alone can hide structure, nonlinearity
#   and influential observations.
#
# Dataset:
#   base R's built-in `anscombe`.
# ============================================================

required <- c("dplyr", "readr", "ggplot2", "tidyr", "tibble")

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
  library(tidyr)
  library(tibble)
})

# ------------------------------------------------------------
# STEP 1 — INSPECT THE BUILT-IN DATA
# ------------------------------------------------------------

cat("\n============================================================\n")
cat("STEP 1 — ANSCOMBE DATA\n")
cat("============================================================\n")
print(anscombe)

cat("\nThere are four x/y pairs:\n")
cat("  x1 + y1\n")
cat("  x2 + y2\n")
cat("  x3 + y3\n")
cat("  x4 + y4\n")
cat("\nBefore plotting, we will summarize each pair numerically.\n")

# ------------------------------------------------------------
# STEP 2 — CALCULATE SUMMARY STATISTICS
# ------------------------------------------------------------

summarize_pair <- function(x, y, label) {
  tibble(
    dataset = label,
    mean_x = mean(x),
    mean_y = mean(y),
    variance_x = var(x),
    variance_y = var(y),
    correlation = cor(x, y, method = "pearson")
  )
}

summary_table <- bind_rows(
  summarize_pair(anscombe$x1, anscombe$y1, "I"),
  summarize_pair(anscombe$x2, anscombe$y2, "II"),
  summarize_pair(anscombe$x3, anscombe$y3, "III"),
  summarize_pair(anscombe$x4, anscombe$y4, "IV")
) |>
  mutate(
    across(
      where(is.numeric),
      ~ round(.x, 3)
    )
  )

cat("\n============================================================\n")
cat("STEP 2 — SUMMARY STATISTICS\n")
cat("============================================================\n")
print(summary_table)

cat("\nNotice how similar the summaries are.\n")
cat("If we stopped here, we might think the four datasets behave similarly.\n")

# ------------------------------------------------------------
# STEP 3 — PUT ALL FOUR SETS INTO ONE LONG TABLE
# ------------------------------------------------------------

long_data <- bind_rows(
  tibble(dataset = "I",   x = anscombe$x1, y = anscombe$y1),
  tibble(dataset = "II",  x = anscombe$x2, y = anscombe$y2),
  tibble(dataset = "III", x = anscombe$x3, y = anscombe$y3),
  tibble(dataset = "IV",  x = anscombe$x4, y = anscombe$y4)
)

cat("\n============================================================\n")
cat("STEP 3 — LONG-FORM DATA\n")
cat("============================================================\n")
print(long_data)

# ------------------------------------------------------------
# STEP 4 — VISUALIZE EACH DATASET
# ------------------------------------------------------------

p <- ggplot(
  long_data,
  aes(x = x, y = y)
) +
  geom_point(size = 2.8) +
  geom_smooth(
    method = "lm",
    se = FALSE,
    linewidth = 0.7
  ) +
  facet_wrap(~ dataset, ncol = 2) +
  coord_cartesian(
    xlim = c(3, 20),
    ylim = c(3, 13)
  ) +
  labs(
    title = "Anscombe's Quartet",
    subtitle = "Nearly identical summary statistics can hide very different data structures",
    x = "x",
    y = "y",
    caption = "Dataset: R built-in anscombe."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson2/activity01_anscombe_quartet/outputs/anscombe_quartet.png",
  p,
  width = 8.5,
  height = 7,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 5 — DESCRIBE WHAT THE PLOTS REVEAL
# ------------------------------------------------------------

interpretation <- tibble(
  dataset = c("I", "II", "III", "IV"),
  visual_pattern = c(
    "Approximately linear relationship",
    "Clear curved / nonlinear relationship",
    "Mostly linear pattern with an influential outlier",
    "Most x values are identical, with one influential point"
  ),
  lesson = c(
    "A linear summary is reasonably compatible with the shape",
    "Pearson correlation alone misses nonlinearity",
    "One observation strongly affects the fitted relationship",
    "A single point can create an apparently strong linear summary"
  )
)

cat("\n============================================================\n")
cat("STEP 5 — WHAT THE GRAPH REVEALS\n")
cat("============================================================\n")
print(interpretation)

cat("\nCore lesson:\n")
cat("The correlation coefficient does not tell you the complete geometry\n")
cat("of the data. Visualization must accompany numerical summaries.\n")

# ------------------------------------------------------------
# STEP 6 — SAVE OUTPUTS
# ------------------------------------------------------------

write_csv(
  summary_table,
  "practice/manual_attempts/module2_lesson2/activity01_anscombe_quartet/outputs/anscombe_summary_statistics.csv"
)

write_csv(
  long_data,
  "practice/manual_attempts/module2_lesson2/activity01_anscombe_quartet/outputs/anscombe_long_data.csv"
)

write_csv(
  interpretation,
  "practice/manual_attempts/module2_lesson2/activity01_anscombe_quartet/outputs/anscombe_visual_interpretation.csv"
)

# ------------------------------------------------------------
# STEP 7 — VALIDATION
# ------------------------------------------------------------

stopifnot(nrow(summary_table) == 4)
stopifnot(nrow(long_data) == 44)
stopifnot(file.exists(
  "practice/manual_attempts/module2_lesson2/activity01_anscombe_quartet/outputs/anscombe_quartet.png"
))

# Values in the classic quartet should be extremely close.
stopifnot(diff(range(summary_table$mean_x)) <= 0.001)
stopifnot(diff(range(summary_table$mean_y)) <= 0.01)
raw_correlations <- c(
  cor(anscombe$x1, anscombe$y1),
  cor(anscombe$x2, anscombe$y2),
  cor(anscombe$x3, anscombe$y3),
  cor(anscombe$x4, anscombe$y4)
)

stopifnot(diff(range(raw_correlations)) <= 0.001)

cat("\n============================================================\n")
cat("✅ ACTIVITY 1 — MODULE 2 LESSON 2 — PASSED\n")
cat("============================================================\n")
cat("You practiced:\n")
cat("  • mean()\n")
cat("  • var()\n")
cat("  • cor()\n")
cat("  • facet_wrap()\n")
cat("  • scatter plots\n")
cat("  • why visualization must accompany summary statistics\n")
