# ============================================================
# FIOCRUZ — Module 2, Lesson 2, Activity 2
#
# Datasaurus Dozen
#
# Goal:
#   calculate summary statistics for datasets that look very
#   different but were deliberately constructed to have nearly
#   identical means, standard deviations and correlations.
#
# Main lesson:
#   "same statistics" does not mean "same data geometry".
#
# Source package:
#   datasauRus (CRAN)
# ============================================================

required <- c("dplyr", "readr", "ggplot2", "tibble", "datasauRus")

missing <- required[
  !vapply(required, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)
]

if (length(missing) > 0) {
  cat("\nMissing R packages:", paste(missing, collapse = ", "), "\n")
  cat("Installing missing CRAN packages into your R user library...\n")

  install.packages(
    missing,
    repos = "https://cloud.r-project.org"
  )
}

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(tibble)
  library(datasauRus)
})

# ------------------------------------------------------------
# STEP 1 — LOAD THE DATA
# ------------------------------------------------------------

data("datasaurus_dozen", package = "datasauRus")

d <- datasaurus_dozen

cat("\n============================================================\n")
cat("STEP 1 — DATASAURUS DOZEN\n")
cat("============================================================\n")
cat("Rows:", nrow(d), "\n")
cat("Distinct datasets:", n_distinct(d$dataset), "\n")
cat("\nDataset names:\n")
print(sort(unique(d$dataset)))

cat("\nNote:\n")
cat("The package contains the original 'dino' dataset plus\n")
cat("12 companion shapes — 13 named datasets in total.\n")

# ------------------------------------------------------------
# STEP 2 — CALCULATE THE SAME SUMMARY FOR EVERY SHAPE
# ------------------------------------------------------------

summary_table <- d |>
  group_by(dataset) |>
  summarise(
    n = n(),
    mean_x = mean(x),
    mean_y = mean(y),
    sd_x = sd(x),
    sd_y = sd(y),
    variance_x = var(x),
    variance_y = var(y),
    correlation = cor(x, y, method = "pearson"),
    .groups = "drop"
  )

summary_display <- summary_table |>
  mutate(
    across(
      c(
        mean_x, mean_y,
        sd_x, sd_y,
        variance_x, variance_y,
        correlation
      ),
      ~ round(.x, 3)
    )
  )

cat("\n============================================================\n")
cat("STEP 2 — SUMMARY STATISTICS\n")
cat("============================================================\n")
print(summary_display, n = Inf)

cat("\nWhat should you notice?\n")
cat("The means, SDs and Pearson correlations are almost the same\n")
cat("across datasets even though their shapes are very different.\n")

# ------------------------------------------------------------
# STEP 3 — QUANTIFY HOW SIMILAR THE SUMMARIES ARE
# ------------------------------------------------------------

similarity_check <- tibble(
  statistic = c(
    "mean_x",
    "mean_y",
    "sd_x",
    "sd_y",
    "correlation"
  ),
  minimum = c(
    min(summary_table$mean_x),
    min(summary_table$mean_y),
    min(summary_table$sd_x),
    min(summary_table$sd_y),
    min(summary_table$correlation)
  ),
  maximum = c(
    max(summary_table$mean_x),
    max(summary_table$mean_y),
    max(summary_table$sd_x),
    max(summary_table$sd_y),
    max(summary_table$correlation)
  )
) |>
  mutate(
    range = maximum - minimum,
    across(
      c(minimum, maximum, range),
      ~ round(.x, 4)
    )
  )

cat("\n============================================================\n")
cat("STEP 3 — HOW CLOSE ARE THE NUMBERS?\n")
cat("============================================================\n")
print(similarity_check)

cat("\nA tiny range across datasets means the numerical summaries\n")
cat("are intentionally very similar.\n")

# ------------------------------------------------------------
# STEP 4 — PLOT EVERY DATASET
# ------------------------------------------------------------

p_all <- ggplot(
  d,
  aes(x = x, y = y)
) +
  geom_point(size = 1.1, alpha = 0.82) +
  facet_wrap(~ dataset, ncol = 4) +
  coord_equal(
    xlim = c(0, 100),
    ylim = c(0, 100)
  ) +
  labs(
    title = "Datasaurus Dozen",
    subtitle = "Very similar summary statistics can produce radically different shapes",
    x = "x",
    y = "y",
    caption = "Dataset: datasauRus package (Datasaurus Dozen)."
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold")
  )

ggsave(
  "practice/manual_attempts/module2_lesson2/activity02_datasaurus/outputs/datasaurus_all_shapes.png",
  p_all,
  width = 12,
  height = 10,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 5 — FOCUS ON THE DINOSAUR
# ------------------------------------------------------------

dino <- d |>
  filter(dataset == "dino")

dino_summary <- summary_table |>
  filter(dataset == "dino")

cat("\n============================================================\n")
cat("STEP 5 — THE DINOSAUR\n")
cat("============================================================\n")
print(dino_summary)

p_dino <- ggplot(
  dino,
  aes(x = x, y = y)
) +
  geom_point(size = 2.2) +
  coord_equal(
    xlim = c(0, 100),
    ylim = c(0, 100)
  ) +
  labs(
    title = "Yes, the points draw a dinosaur",
    subtitle = paste0(
      "Yet Pearson r ≈ ",
      round(dino_summary$correlation, 3)
    ),
    x = "x",
    y = "y",
    caption = "Dataset: datasauRus package."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson2/activity02_datasaurus/outputs/datasaurus_dino.png",
  p_dino,
  width = 7,
  height = 7,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 6 — WRITE THE ANALYTICAL LESSON
# ------------------------------------------------------------

interpretation <- tibble(
  concept = c(
    "Mean",
    "Standard deviation",
    "Pearson correlation",
    "Visualization"
  ),
  interpretation = c(
    "Describes center but not spatial geometry",
    "Describes spread but not the arrangement of points",
    "Summarizes linear association, not arbitrary shape",
    "Reveals structure, clusters, curves and influential observations"
  )
)

cat("\n============================================================\n")
cat("STEP 6 — INTERPRETATION\n")
cat("============================================================\n")
print(interpretation)

cat("\nMain lesson:\n")
cat("A statistical summary compresses information.\n")
cat("Compression is useful — but it necessarily throws information away.\n")
cat("That is why EDA combines numbers AND graphics.\n")

# ------------------------------------------------------------
# STEP 7 — SAVE TABLES
# ------------------------------------------------------------

write_csv(
  summary_display,
  "practice/manual_attempts/module2_lesson2/activity02_datasaurus/outputs/datasaurus_summary_statistics.csv"
)

write_csv(
  similarity_check,
  "practice/manual_attempts/module2_lesson2/activity02_datasaurus/outputs/datasaurus_similarity_ranges.csv"
)

write_csv(
  interpretation,
  "practice/manual_attempts/module2_lesson2/activity02_datasaurus/outputs/datasaurus_interpretation.csv"
)

# ------------------------------------------------------------
# STEP 8 — VALIDATION
# ------------------------------------------------------------

stopifnot(n_distinct(d$dataset) >= 13)
stopifnot(nrow(summary_table) == n_distinct(d$dataset))

# Use the unrounded calculations for validation.
# These tolerances are intentionally generous enough to avoid
# brittle floating-point tests while still confirming the
# defining property of the dataset collection.
stopifnot(diff(range(summary_table$mean_x)) < 0.2)
stopifnot(diff(range(summary_table$mean_y)) < 0.2)
stopifnot(diff(range(summary_table$sd_x)) < 0.2)
stopifnot(diff(range(summary_table$sd_y)) < 0.2)
stopifnot(diff(range(summary_table$correlation)) < 0.01)

required_figures <- c(
  "practice/manual_attempts/module2_lesson2/activity02_datasaurus/outputs/datasaurus_all_shapes.png",
  "practice/manual_attempts/module2_lesson2/activity02_datasaurus/outputs/datasaurus_dino.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n============================================================\n")
cat("✅ M2 LESSON 2 · ACTIVITY 2 PASSED\n")
cat("============================================================\n")
cat("Datasets compared:", n_distinct(d$dataset), "\n")
cat("Summary statistics: nearly identical\n")
cat("Visual structures: radically different\n")
cat("\n")
cat("Core lesson:\n")
cat("  NEVER interpret summary statistics without looking at the data.\n")
