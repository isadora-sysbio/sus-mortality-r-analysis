# ============================================================
# FIOCRUZ — Module 2, Lesson 1, Activity 5
#
# Goal:
# Build three common exploratory plots with ggplot2:
#   1. bar chart
#   2. boxplot
#   3. histogram
#
# The official lesson asks learners to construct these plots
# to visualize distributions and compare groups.
#
# This implementation uses original synthetic health data.
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
# STEP 1 — SYNTHETIC HEALTH DATA
# ------------------------------------------------------------

patients <- tibble(
  patient_id = 1:30,
  sex = rep(c("Female", "Male"), each = 15),
  age = c(
    24, 28, 32, 35, 36, 39, 42, 44, 47, 49, 53, 57, 61, 65, 69,
    23, 27, 31, 34, 38, 41, 43, 46, 50, 52, 55, 59, 63, 67, 71
  ),
  systolic_bp = c(
    108, 112, 116, 118, 119, 121, 123, 124, 126, 129, 131, 134, 136, 140, 144,
    110, 113, 117, 120, 122, 125, 127, 128, 130, 133, 135, 138, 141, 145, 149
  ),
  smoking_status = c(
    "Never", "Never", "Former", "Never", "Current",
    "Never", "Former", "Never", "Current", "Never",
    "Former", "Never", "Current", "Former", "Never",
    "Never", "Current", "Never", "Former", "Never",
    "Current", "Never", "Former", "Never", "Current",
    "Never", "Former", "Current", "Never", "Former"
  )
)

cat("\n============================================================\n")
cat("STEP 1 — DATA\n")
cat("============================================================\n")
print(patients)

cat("\nWe now have:\n")
cat("  categorical variable: smoking_status\n")
cat("  numeric variable: systolic_bp\n")
cat("  grouping variable: sex\n")

# ------------------------------------------------------------
# STEP 2 — BAR CHART
# ------------------------------------------------------------

cat("\n============================================================\n")
cat("STEP 2 — BAR CHART\n")
cat("============================================================\n")
cat("Question: How frequent is each smoking-status category?\n")

smoking_summary <- patients |>
  count(smoking_status, name = "n") |>
  mutate(
    percent = round(100 * n / sum(n), 1)
  )

print(smoking_summary)

p_bar <- ggplot(
  smoking_summary,
  aes(x = smoking_status, y = percent)
) +
  geom_col(width = 0.65) +
  geom_text(
    aes(label = paste0(percent, "%")),
    vjust = -0.4,
    size = 4
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.16))
  ) +
  labs(
    title = "Smoking status in the synthetic cohort",
    subtitle = "Bar charts are appropriate for categorical frequencies",
    x = "Smoking status",
    y = "Percent of patients",
    caption = "Synthetic educational data."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson1/activity05_graphical_methods/outputs/bar_smoking_status.png",
  p_bar,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

cat("\nBAR CHART LESSON:\n")
cat("- x-axis: categories\n")
cat("- bar height: frequency or percentage\n")
cat("- this graph answers 'how many/how frequent?'\n")

# ------------------------------------------------------------
# STEP 3 — BOXPLOT
# ------------------------------------------------------------

cat("\n============================================================\n")
cat("STEP 3 — BOXPLOT\n")
cat("============================================================\n")
cat("Question: How does systolic blood pressure vary by sex?\n")

bp_by_sex <- patients |>
  group_by(sex) |>
  summarise(
    n = n(),
    median_sbp = median(systolic_bp),
    q1 = quantile(systolic_bp, 0.25),
    q3 = quantile(systolic_bp, 0.75),
    iqr = IQR(systolic_bp),
    .groups = "drop"
  )

print(bp_by_sex)

p_box <- ggplot(
  patients,
  aes(x = sex, y = systolic_bp)
) +
  geom_boxplot(width = 0.5, outlier.shape = NA) +
  geom_jitter(width = 0.08, alpha = 0.65, size = 2.3) +
  labs(
    title = "Systolic blood pressure by sex",
    subtitle = "Boxplots summarize median, quartiles and spread between groups",
    x = NULL,
    y = "Systolic blood pressure (mmHg)",
    caption = "Synthetic educational data."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson1/activity05_graphical_methods/outputs/boxplot_sbp_by_sex.png",
  p_box,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

cat("\nBOXPLOT LESSON:\n")
cat("- center line: median\n")
cat("- box: Q1 to Q3\n")
cat("- box height: IQR\n")
cat("- useful for comparing distributions between groups\n")

# ------------------------------------------------------------
# STEP 4 — HISTOGRAM
# ------------------------------------------------------------

cat("\n============================================================\n")
cat("STEP 4 — HISTOGRAM\n")
cat("============================================================\n")
cat("Question: What is the shape of the systolic-BP distribution?\n")

bp_summary <- patients |>
  summarise(
    n = n(),
    mean_sbp = round(mean(systolic_bp), 1),
    median_sbp = median(systolic_bp),
    sd_sbp = round(sd(systolic_bp), 1),
    min_sbp = min(systolic_bp),
    max_sbp = max(systolic_bp)
  )

print(bp_summary)

p_hist <- ggplot(
  patients,
  aes(x = systolic_bp)
) +
  geom_histogram(
    bins = 8,
    boundary = 0
  ) +
  geom_vline(
    xintercept = bp_summary$mean_sbp,
    linetype = "dashed",
    linewidth = 0.8
  ) +
  labs(
    title = "Distribution of systolic blood pressure",
    subtitle = paste0(
      "Histogram with mean reference line (",
      bp_summary$mean_sbp,
      " mmHg)"
    ),
    x = "Systolic blood pressure (mmHg)",
    y = "Number of patients",
    caption = "Synthetic educational data."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson1/activity05_graphical_methods/outputs/histogram_sbp.png",
  p_hist,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

cat("\nHISTOGRAM LESSON:\n")
cat("- x-axis: intervals of a numeric variable\n")
cat("- bar height: number of observations in each interval\n")
cat("- useful for shape, spread, skewness and possible multimodality\n")

# ------------------------------------------------------------
# STEP 5 — CHOOSE THE GRAPH FROM THE QUESTION
# ------------------------------------------------------------

graph_guide <- tibble(
  research_question = c(
    "How frequent is each category?",
    "How does a numeric variable differ between groups?",
    "What is the shape of one numeric distribution?"
  ),
  variable_structure = c(
    "One categorical variable",
    "One numeric + one categorical grouping variable",
    "One numeric variable"
  ),
  recommended_graph = c(
    "Bar chart",
    "Boxplot",
    "Histogram"
  )
)

cat("\n============================================================\n")
cat("STEP 5 — GRAPH SELECTION GUIDE\n")
cat("============================================================\n")
print(graph_guide)

# ------------------------------------------------------------
# STEP 6 — SAVE TABLES
# ------------------------------------------------------------

write_csv(
  patients,
  "practice/manual_attempts/module2_lesson1/activity05_graphical_methods/outputs/synthetic_health_data.csv"
)

write_csv(
  smoking_summary,
  "practice/manual_attempts/module2_lesson1/activity05_graphical_methods/outputs/smoking_status_summary.csv"
)

write_csv(
  bp_by_sex,
  "practice/manual_attempts/module2_lesson1/activity05_graphical_methods/outputs/bp_by_sex_summary.csv"
)

write_csv(
  bp_summary,
  "practice/manual_attempts/module2_lesson1/activity05_graphical_methods/outputs/bp_distribution_summary.csv"
)

write_csv(
  graph_guide,
  "practice/manual_attempts/module2_lesson1/activity05_graphical_methods/outputs/graph_selection_guide.csv"
)

# ------------------------------------------------------------
# STEP 7 — VALIDATION
# ------------------------------------------------------------

stopifnot(sum(smoking_summary$n) == nrow(patients))
stopifnot(nrow(bp_by_sex) == 2)
stopifnot(bp_summary$n == nrow(patients))

required_figures <- c(
  "practice/manual_attempts/module2_lesson1/activity05_graphical_methods/outputs/bar_smoking_status.png",
  "practice/manual_attempts/module2_lesson1/activity05_graphical_methods/outputs/boxplot_sbp_by_sex.png",
  "practice/manual_attempts/module2_lesson1/activity05_graphical_methods/outputs/histogram_sbp.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n============================================================\n")
cat("✅ ACTIVITY 5 PASSED\n")
cat("============================================================\n")
cat("Graphs created:\n")
cat("  1. Bar chart — categorical frequency\n")
cat("  2. Boxplot — numeric distribution by group\n")
cat("  3. Histogram — shape of a numeric distribution\n")
cat("\n")
cat("Main lesson: choose the graph from the variable type + question.\n")
