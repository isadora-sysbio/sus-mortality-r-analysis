# ============================================================
# FIOCRUZ — Module 2, Lesson 2, Activity 4
#
# Goal:
#   1. use color to distinguish meaningful groups;
#   2. use a sequential color scale for magnitude;
#   3. avoid decorative/random color;
#   4. think about accessibility.
#
# The activity follows the official course structure:
#   - cardiovascular events after dengue
#   - sequential color for average fuel consumption
#
# The dengue values are the simplified values used in the
# official Fiocruz activity script.
# ============================================================

required <- c("dplyr", "readr", "ggplot2", "forcats", "stringr", "tibble")

missing <- required[
  !vapply(required, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)
]

if (length(missing) > 0) {
  cat("\nMissing R packages:", paste(missing, collapse = ", "), "\n")
  cat("Installing missing CRAN packages...\n")

  install.packages(
    missing,
    repos = "https://cloud.r-project.org"
  )
}

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(forcats)
  library(stringr)
  library(tibble)
})

# ------------------------------------------------------------
# STEP 1 — DENGUE DATA: COLOR AS A GROUPING VARIABLE
# ------------------------------------------------------------

dengue_events <- tibble(
  outcome = rep(
    c(
      "Hemorrhagic stroke",
      "Ischemic stroke",
      "Acute myocardial infarction",
      "Heart failure"
    ),
    2
  ),
  period = rep(c("Days 1–7", "Days 8–14"), each = 4),
  irr = c(
    10.90, 15.56, 13.53, 27.24,
    4.33, 3.17, 1.16, 2.45
  )
)

cat("\n============================================================\n")
cat("STEP 1 — DENGUE EVENT DATA\n")
cat("============================================================\n")
print(dengue_events)

cat("\nInterpretation rule:\n")
cat("IRR = 1 means no increase relative to the reference period.\n")
cat("IRR > 1 means a higher incidence rate than the reference.\n")

# ------------------------------------------------------------
# STEP 2 — PURPOSEFUL COLOR: DIFFERENT PERIODS
# ------------------------------------------------------------
# Color now carries meaning: it distinguishes the two
# post-infection periods.
#
# We use a high-contrast two-color palette and ALSO retain
# text/legend labels, so color is not the only source of meaning.

dengue_plot_data <- dengue_events |>
  mutate(
    outcome = fct_reorder(
      outcome,
      irr,
      .fun = max,
      .desc = TRUE
    )
  )

p_dengue <- ggplot(
  dengue_plot_data,
  aes(
    x = outcome,
    y = irr,
    color = period,
    shape = period
  )
) +
  geom_point(
    position = position_dodge(width = 0.45),
    size = 3.4
  ) +
  geom_hline(
    yintercept = 1,
    linetype = "dashed",
    linewidth = 0.65
  ) +
  scale_color_manual(
    values = c(
      "Days 1–7" = "#C44E52",
      "Days 8–14" = "#4C72B0"
    ),
    name = "Period after infection"
  ) +
  scale_shape_manual(
    values = c(
      "Days 1–7" = 16,
      "Days 8–14" = 17
    ),
    name = "Period after infection"
  ) +
  labs(
    title = "Incidence rate ratios after dengue infection",
    subtitle = "Color and shape distinguish the two post-infection periods",
    x = NULL,
    y = "Incidence Rate Ratio (IRR)",
    caption = "Simplified educational values from the Campus Virtual Fiocruz activity."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 15, hjust = 1),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson2/activity04_purposeful_color/outputs/dengue_purposeful_color.png",
  p_dengue,
  width = 9,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

cat("\n============================================================\n")
cat("STEP 2 — WHY THIS COLOR HAS A PURPOSE\n")
cat("============================================================\n")
cat("Red/blue are not decorative here.\n")
cat("They encode different time periods after infection.\n")
cat("\n")
cat("We also use different point SHAPES.\n")
cat("That means the grouping is still understandable if color\n")
cat("perception is reduced or the figure is printed in grayscale.\n")

# ------------------------------------------------------------
# STEP 3 — WHAT DECORATIVE COLOR WOULD LOOK LIKE
# ------------------------------------------------------------
# All outcomes below would get arbitrary different colors even
# though those colors add no new variable or analytical meaning.

decorative_example <- tibble(
  design_choice = c(
    "One arbitrary color per bar/category",
    "One purposeful color per meaningful group"
  ),
  result = c(
    "Adds visual complexity without new information",
    "Encodes a real variable or analytical distinction"
  )
)

cat("\n============================================================\n")
cat("STEP 3 — DECORATIVE VS PURPOSEFUL COLOR\n")
cat("============================================================\n")
print(decorative_example)

# ------------------------------------------------------------
# STEP 4 — SEQUENTIAL COLOR FOR MAGNITUDE
# ------------------------------------------------------------
# This follows the official activity's mtcars example.
# A sequential scale is appropriate because mpg_mean is numeric:
# darker/lighter shades represent lower/higher magnitude.

manufacturer_consumption <- mtcars |>
  rownames_to_column("model") |>
  mutate(
    manufacturer = word(model, 1)
  ) |>
  group_by(manufacturer) |>
  summarise(
    mpg_mean = mean(mpg),
    .groups = "drop"
  ) |>
  arrange(mpg_mean) |>
  slice_head(n = 10)

cat("\n============================================================\n")
cat("STEP 4 — SEQUENTIAL COLOR DATA\n")
cat("============================================================\n")
print(manufacturer_consumption)

p_consumption <- manufacturer_consumption |>
  mutate(
    manufacturer = fct_reorder(
      manufacturer,
      mpg_mean
    )
  ) |>
  ggplot(
    aes(
      x = manufacturer,
      y = mpg_mean,
      fill = mpg_mean
    )
  ) +
  geom_col() +
  scale_fill_gradient(
    low = "#DCEAF7",
    high = "#24527A",
    name = "Mean mpg"
  ) +
  coord_flip() +
  labs(
    title = "Average fuel consumption by manufacturer",
    subtitle = "Sequential color represents the magnitude of the same numeric variable",
    x = NULL,
    y = "Miles per gallon (mean)",
    caption = "Dataset: R built-in mtcars."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson2/activity04_purposeful_color/outputs/sequential_color_mpg.png",
  p_consumption,
  width = 8.5,
  height = 6,
  dpi = 300,
  bg = "white"
)

cat("\nSEQUENTIAL-COLOR LESSON:\n")
cat("- categorical difference -> discrete palette\n")
cat("- ordered numeric magnitude -> sequential gradient\n")
cat("- color should encode something, not merely decorate\n")

# ------------------------------------------------------------
# STEP 5 — ACCESSIBILITY CHECKLIST
# ------------------------------------------------------------

accessibility_checklist <- tibble(
  question = c(
    "Does color encode a real variable?",
    "Can the figure still be interpreted without perfect color vision?",
    "Are text labels / legends present?",
    "Could red-green alone create ambiguity?",
    "Is the palette appropriate to data type?",
    "Is contrast sufficient?"
  ),
  good_practice = c(
    "Use color only when it carries meaning",
    "Add shape, position, labels, or other redundant encoding when useful",
    "Never rely on unexplained color alone",
    "Avoid red-green-only distinctions",
    "Discrete for categories; sequential for ordered magnitude",
    "Check readability on light/dark and printed backgrounds"
  )
)

cat("\n============================================================\n")
cat("STEP 5 — ACCESSIBILITY CHECKLIST\n")
cat("============================================================\n")
print(accessibility_checklist)

# ------------------------------------------------------------
# STEP 6 — SAVE TABLES
# ------------------------------------------------------------

write_csv(
  dengue_events,
  "practice/manual_attempts/module2_lesson2/activity04_purposeful_color/outputs/dengue_events.csv"
)

write_csv(
  manufacturer_consumption,
  "practice/manual_attempts/module2_lesson2/activity04_purposeful_color/outputs/manufacturer_mpg.csv"
)

write_csv(
  decorative_example,
  "practice/manual_attempts/module2_lesson2/activity04_purposeful_color/outputs/decorative_vs_purposeful_color.csv"
)

write_csv(
  accessibility_checklist,
  "practice/manual_attempts/module2_lesson2/activity04_purposeful_color/outputs/color_accessibility_checklist.csv"
)

# ------------------------------------------------------------
# STEP 7 — VALIDATION
# ------------------------------------------------------------

stopifnot(nrow(dengue_events) == 8)
stopifnot(n_distinct(dengue_events$period) == 2)
stopifnot(all(dengue_events$irr > 0))

stopifnot(nrow(manufacturer_consumption) <= 10)
stopifnot(all(manufacturer_consumption$mpg_mean > 0))

required_figures <- c(
  "practice/manual_attempts/module2_lesson2/activity04_purposeful_color/outputs/dengue_purposeful_color.png",
  "practice/manual_attempts/module2_lesson2/activity04_purposeful_color/outputs/sequential_color_mpg.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n============================================================\n")
cat("✅ M2 LESSON 2 · ACTIVITY 4 PASSED\n")
cat("============================================================\n")
cat("You practiced:\n")
cat("  • color as a meaningful categorical encoding\n")
cat("  • redundant encoding with color + shape\n")
cat("  • sequential gradients for numeric magnitude\n")
cat("  • avoiding decorative color\n")
cat("  • accessibility-aware visualization choices\n")
