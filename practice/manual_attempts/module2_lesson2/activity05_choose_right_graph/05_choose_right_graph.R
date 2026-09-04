# ============================================================
# FIOCRUZ — Module 2, Lesson 2, Activity 5
#
# Goal:
# Match graph type to data structure and analytical objective.
#
# Official lesson examples:
#   1. pie chart vs horizontal bars for group proportions
#   2. line graph for weekly influenza time series
#
# Main lesson:
#   choose the graph based on the question, not aesthetics.
# ============================================================

required <- c("dplyr", "readr", "ggplot2", "forcats", "tibble")

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
  library(forcats)
  library(tibble)
})

# ------------------------------------------------------------
# STEP 1 — PIE CHART VS HORIZONTAL BARS
# ------------------------------------------------------------

group_data <- tibble(
  group = c("A", "B", "C"),
  percent = c(45, 35, 20)
)

cat("\n============================================================\n")
cat("STEP 1 — GROUP PROPORTIONS\n")
cat("============================================================\n")
print(group_data)

cat("\nQuestion:\n")
cat("Which group is largest, and how easy is it to compare magnitudes?\n")

# Pie chart: included because the course explicitly compares it.
p_pie <- ggplot(
  group_data,
  aes(x = "", y = percent, fill = group)
) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  geom_text(
    aes(label = paste0(percent, "%")),
    position = position_stack(vjust = 0.5),
    size = 4
  ) +
  labs(
    title = "Pie-chart version",
    subtitle = "Percent labels help, but angle/area comparison is harder",
    fill = "Group",
    caption = "Educational group proportions following the Fiocruz Activity 5 example."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold")
  )

ggsave(
  "practice/manual_attempts/module2_lesson2/activity05_choose_right_graph/outputs/group_proportions_pie.png",
  p_pie,
  width = 6.5,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

# Horizontal bars: easier direct length comparison.
p_bar <- group_data |>
  mutate(
    group = fct_reorder(group, percent)
  ) |>
  ggplot(
    aes(x = group, y = percent)
  ) +
  geom_col(width = 0.65) +
  geom_text(
    aes(label = paste0(percent, "%")),
    hjust = -0.2,
    size = 4
  ) +
  coord_flip() +
  scale_y_continuous(
    limits = c(0, 55),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title = "Horizontal-bar alternative",
    subtitle = "A common baseline makes magnitude comparison easier",
    x = NULL,
    y = "Percent (%)",
    caption = "Educational group proportions following the Fiocruz Activity 5 example."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson2/activity05_choose_right_graph/outputs/group_proportions_horizontal_bar.png",
  p_bar,
  width = 7.5,
  height = 5,
  dpi = 300,
  bg = "white"
)

cat("\nPIE VS BAR LESSON:\n")
cat("- Pie: humans compare angles/areas imperfectly.\n")
cat("- Horizontal bars: values share a common baseline.\n")
cat("- If a pie is used, explicit values/percentages improve readability.\n")

# ------------------------------------------------------------
# STEP 2 — TIME SERIES -> LINE GRAPH
# ------------------------------------------------------------

set.seed(42)

influenza <- tibble(
  epidemiological_week = 1:52,
  year = 2023,
  cases = round(
    50 +
      30 * sin((epidemiological_week - 10) * 2 * pi / 52) +
      rnorm(52, 0, 10)
  )
) |>
  mutate(
    cases = pmax(cases, 5)
  )

cat("\n============================================================\n")
cat("STEP 2 — WEEKLY INFLUENZA SERIES\n")
cat("============================================================\n")
print(influenza, n = 12)
cat("... 40 additional weeks omitted from console display.\n")

# Summarize peak and trough for interpretation.
peak_week <- influenza |>
  slice_max(cases, n = 1, with_ties = FALSE)

lowest_week <- influenza |>
  slice_min(cases, n = 1, with_ties = FALSE)

cat("\nPeak week:\n")
print(peak_week)

cat("\nLowest week:\n")
print(lowest_week)

p_line <- ggplot(
  influenza,
  aes(x = epidemiological_week, y = cases)
) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.6) +
  annotate(
    "text",
    x = peak_week$epidemiological_week,
    y = peak_week$cases + 7,
    label = paste0("Peak: week ", peak_week$epidemiological_week),
    size = 3.5
  ) +
  scale_x_continuous(
    breaks = seq(4, 52, by = 4)
  ) +
  scale_y_continuous(
    limits = c(0, NA),
    expand = expansion(mult = c(0, 0.08))
  ) +
  labs(
    title = "Weekly influenza cases — 2023",
    subtitle = "A line graph preserves temporal order and makes the trend visible",
    x = "Epidemiological week",
    y = "Number of cases",
    caption = "Synthetic educational series generated with a fixed random seed."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson2/activity05_choose_right_graph/outputs/influenza_weekly_line.png",
  p_line,
  width = 9,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

cat("\nTIME-SERIES LESSON:\n")
cat("- x-axis preserves chronological order.\n")
cat("- connecting observations helps reveal trend and seasonality.\n")
cat("- a line plot is often preferable to unordered bars for repeated time points.\n")

# ------------------------------------------------------------
# STEP 3 — GRAPH-SELECTION TABLE
# ------------------------------------------------------------

graph_selection <- tibble(
  analytical_goal = c(
    "Compare category magnitudes",
    "Show category composition",
    "Show change over ordered time",
    "Show one numeric distribution",
    "Compare a numeric distribution across groups",
    "Show relationship between two numeric variables"
  ),
  typical_graph = c(
    "Bar chart",
    "Pie chart only when composition is simple and labels are explicit",
    "Line chart",
    "Histogram",
    "Boxplot",
    "Scatter plot"
  ),
  main_visual_encoding = c(
    "Length",
    "Angle / area",
    "Position + connected temporal path",
    "Count/density across numeric bins",
    "Median, quartiles and spread",
    "Position on x and y"
  )
)

cat("\n============================================================\n")
cat("STEP 3 — GRAPH-SELECTION GUIDE\n")
cat("============================================================\n")
print(graph_selection)

# ------------------------------------------------------------
# STEP 4 — IMPORTANT NUANCE ABOUT ZERO
# ------------------------------------------------------------

zero_baseline_note <- tibble(
  graph_type = c("Bar chart", "Line chart"),
  zero_baseline_guidance = c(
    "Usually essential because bar length itself encodes magnitude",
    "Context-dependent; the Fiocruz example includes zero, but line charts do not universally require a zero baseline"
  )
)

cat("\n============================================================\n")
cat("STEP 4 — ZERO-BASELINE NUANCE\n")
cat("============================================================\n")
print(zero_baseline_note)

# ------------------------------------------------------------
# STEP 5 — SAVE TABLES
# ------------------------------------------------------------

write_csv(
  group_data,
  "practice/manual_attempts/module2_lesson2/activity05_choose_right_graph/outputs/group_proportions.csv"
)

write_csv(
  influenza,
  "practice/manual_attempts/module2_lesson2/activity05_choose_right_graph/outputs/influenza_weekly_series.csv"
)

write_csv(
  graph_selection,
  "practice/manual_attempts/module2_lesson2/activity05_choose_right_graph/outputs/graph_selection_guide.csv"
)

write_csv(
  zero_baseline_note,
  "practice/manual_attempts/module2_lesson2/activity05_choose_right_graph/outputs/zero_baseline_note.csv"
)

# ------------------------------------------------------------
# STEP 6 — VALIDATION
# ------------------------------------------------------------

stopifnot(sum(group_data$percent) == 100)
stopifnot(nrow(influenza) == 52)
stopifnot(all(influenza$cases >= 5))

required_figures <- c(
  "practice/manual_attempts/module2_lesson2/activity05_choose_right_graph/outputs/group_proportions_pie.png",
  "practice/manual_attempts/module2_lesson2/activity05_choose_right_graph/outputs/group_proportions_horizontal_bar.png",
  "practice/manual_attempts/module2_lesson2/activity05_choose_right_graph/outputs/influenza_weekly_line.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n============================================================\n")
cat("✅ M2 LESSON 2 · ACTIVITY 5 PASSED\n")
cat("============================================================\n")
cat("You practiced:\n")
cat("  • pie vs horizontal-bar comparison\n")
cat("  • line graph for ordered time\n")
cat("  • matching graph type to analytical goal\n")
cat("  • understanding visual encodings\n")
cat("  • zero-baseline nuance by graph type\n")
