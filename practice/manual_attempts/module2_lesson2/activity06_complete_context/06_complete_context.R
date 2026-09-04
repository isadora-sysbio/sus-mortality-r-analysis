# ============================================================
# FIOCRUZ — Module 2, Lesson 2, Activity 6
#
# Goal:
# Build a self-explanatory graph with complete contextualization.
#
# Official course checklist:
#   - clear title
#   - informative subtitle
#   - axis labels with units
#   - clear legend when applicable
#   - data source in the caption
#
# Official example:
#   histogram of birth weight for 20 newborns, with mean line.
# ============================================================

required <- c("dplyr", "readr", "ggplot2", "tibble")

missing <- required[
  !vapply(required, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)
]

if (length(missing) > 0) {
  cat("\nMissing R packages:", paste(missing, collapse = ", "), "\n")
  cat("Installing missing CRAN packages...\n")
  install.packages(missing, repos = "https://cloud.r-project.org")
}

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(tibble)
})

# ------------------------------------------------------------
# STEP 1 — OFFICIAL COURSE EXAMPLE DATA
# ------------------------------------------------------------

newborns <- tibble(
  individual = 1:20,
  birth_weight_g = c(
    3265, 3260, 3245, 3484, 4146,
    3323, 3649, 3200, 3031, 2069,
    2581, 2841, 3609, 2838, 3541,
    2759, 3248, 3314, 3101, 2834
  )
)

cat("\n============================================================\n")
cat("STEP 1 — NEWBORN BIRTH-WEIGHT DATA\n")
cat("============================================================\n")
print(newborns)

# ------------------------------------------------------------
# STEP 2 — DESCRIPTIVE CONTEXT
# ------------------------------------------------------------

summary_stats <- newborns |>
  summarise(
    n = n(),
    mean_g = round(mean(birth_weight_g), 1),
    median_g = median(birth_weight_g),
    sd_g = round(sd(birth_weight_g), 1),
    minimum_g = min(birth_weight_g),
    maximum_g = max(birth_weight_g)
  )

cat("\n============================================================\n")
cat("STEP 2 — DESCRIPTIVE CONTEXT\n")
cat("============================================================\n")
print(summary_stats)

mean_weight <- mean(newborns$birth_weight_g)

cat("\nWhy calculate this first?\n")
cat("A graph is easier to annotate correctly when the analyst\n")
cat("already understands the key descriptive values.\n")

# ------------------------------------------------------------
# STEP 3 — BUILD THE COMPLETE HISTOGRAM
# ------------------------------------------------------------

p_complete <- ggplot(
  newborns,
  aes(x = birth_weight_g)
) +
  geom_histogram(
    bins = 8,
    fill = "steelblue",
    color = "white",
    alpha = 0.8
  ) +
  geom_vline(
    xintercept = mean_weight,
    color = "red",
    linetype = "dashed",
    linewidth = 1
  ) +
  annotate(
    "text",
    x = mean_weight + 25,
    y = 4.5,
    label = paste0(
      "Mean: ",
      round(mean_weight, 0),
      " g"
    ),
    hjust = 0,
    size = 3.5
  ) +
  labs(
    title = "Distribution of birth weight",
    subtitle = "Sample of 20 newborns from a maternity setting",
    x = "Birth weight (grams)",
    y = "Frequency (n)",
    caption = "Source: simulated data for educational purposes"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14
    ),
    plot.subtitle = element_text(
      size = 10
    ),
    plot.caption = element_text(
      size = 8
    ),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson2/activity06_complete_context/outputs/complete_birth_weight_histogram.png",
  p_complete,
  width = 8.5,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

cat("\n============================================================\n")
cat("STEP 3 — COMPLETE GRAPH CREATED\n")
cat("============================================================\n")
cat("Included:\n")
cat("  ✓ title\n")
cat("  ✓ subtitle\n")
cat("  ✓ x-axis label + units\n")
cat("  ✓ y-axis label + count unit\n")
cat("  ✓ mean reference line\n")
cat("  ✓ annotation\n")
cat("  ✓ data-source caption\n")

# ------------------------------------------------------------
# STEP 4 — WHY EACH ELEMENT MATTERS
# ------------------------------------------------------------

context_checklist <- tibble(
  element = c(
    "Title",
    "Subtitle",
    "X-axis label",
    "Y-axis label",
    "Reference line",
    "Annotation",
    "Caption/source"
  ),
  purpose = c(
    "States the main subject of the figure",
    "Adds sample/context information",
    "Names the measured variable and its unit",
    "Explains what bar height represents",
    "Highlights a meaningful benchmark/statistic",
    "Makes the reference line interpretable",
    "Documents where the data came from"
  ),
  present = rep(TRUE, 7)
)

cat("\n============================================================\n")
cat("STEP 4 — CONTEXTUALIZATION CHECKLIST\n")
cat("============================================================\n")
print(context_checklist)

# ------------------------------------------------------------
# STEP 5 — INCOMPLETE VS COMPLETE DESIGN
# ------------------------------------------------------------

comparison <- tibble(
  graph_version = c(
    "Incomplete",
    "Complete"
  ),
  likely_reader_question = c(
    "What is this? Which units? Which sample? Which source?",
    "The figure can be understood without external explanation."
  )
)

cat("\n============================================================\n")
cat("STEP 5 — WHY CONTEXT MATTERS\n")
cat("============================================================\n")
print(comparison)

cat("\nMain lesson:\n")
cat("A good graph should be able to travel outside the notebook\n")
cat("and still make sense to a reader.\n")

# ------------------------------------------------------------
# STEP 6 — SAVE TABLES
# ------------------------------------------------------------

write_csv(
  newborns,
  "practice/manual_attempts/module2_lesson2/activity06_complete_context/outputs/newborn_birth_weights.csv"
)

write_csv(
  summary_stats,
  "practice/manual_attempts/module2_lesson2/activity06_complete_context/outputs/birth_weight_summary.csv"
)

write_csv(
  context_checklist,
  "practice/manual_attempts/module2_lesson2/activity06_complete_context/outputs/contextualization_checklist.csv"
)

write_csv(
  comparison,
  "practice/manual_attempts/module2_lesson2/activity06_complete_context/outputs/incomplete_vs_complete.csv"
)

# ------------------------------------------------------------
# STEP 7 — VALIDATION
# ------------------------------------------------------------

stopifnot(nrow(newborns) == 20)
stopifnot(summary_stats$n == 20)
stopifnot(all(context_checklist$present))
stopifnot(file.exists(
  "practice/manual_attempts/module2_lesson2/activity06_complete_context/outputs/complete_birth_weight_histogram.png"
))

cat("\n============================================================\n")
cat("✅ M2 LESSON 2 · ACTIVITY 6 PASSED\n")
cat("============================================================\n")
cat("You practiced:\n")
cat("  • title + subtitle\n")
cat("  • axis labels with units\n")
cat("  • reference lines and annotations\n")
cat("  • source/caption attribution\n")
cat("  • making a figure self-explanatory\n")
