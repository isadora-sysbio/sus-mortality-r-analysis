# ============================================================
# FIOCRUZ — Module 2, Lesson 2, Activity 3
#
# Goal:
# Reproduce the lesson's IPCA example and understand how axis
# choices can exaggerate or distort differences in a bar chart.
#
# Official activity data:
#   2009–2013 IPCA values from the Fiocruz activity script.
#
# Main lesson:
#   for ordinary bar charts, bar length encodes magnitude, so
#   the quantitative axis should begin at zero.
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
# STEP 1 — COURSE DATA
# ------------------------------------------------------------

ipca <- tibble(
  year = 2009:2013,
  ipca_percent = c(4.31, 5.92, 6.50, 5.84, 5.91)
)

cat("\n============================================================\n")
cat("STEP 1 — IPCA DATA\n")
cat("============================================================\n")
print(ipca)

cat("\nRange of values:\n")
cat(
  round(min(ipca$ipca_percent), 2),
  "to",
  round(max(ipca$ipca_percent), 2),
  "%\n"
)

# ------------------------------------------------------------
# STEP 2 — A MISLEADING VERSION FOR COMPARISON
# ------------------------------------------------------------
# This is an educational extension.
# We deliberately truncate the y-axis near the data.
# That makes modest differences look much larger.

p_misleading <- ggplot(
  ipca,
  aes(x = factor(year), y = ipca_percent)
) +
  geom_col(width = 0.68) +
  coord_cartesian(ylim = c(4.0, 6.8)) +
  labs(
    title = "Misleading version: truncated bar-chart axis",
    subtitle = "Starting near 4% visually exaggerates differences",
    x = "Year",
    y = "IPCA (%)",
    caption = "Educational reconstruction of a misleading design choice."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson2/activity03_graphical_integrity_ipca/outputs/ipca_misleading_truncated_axis.png",
  p_misleading,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

cat("\n============================================================\n")
cat("STEP 2 — MISLEADING VERSION\n")
cat("============================================================\n")
cat("The y-axis begins near 4%, not zero.\n")
cat("Because bar LENGTH encodes magnitude, the visual ratio is distorted.\n")

# ------------------------------------------------------------
# STEP 3 — THE COURSE'S CORRECT PRINCIPLE
# ------------------------------------------------------------

p_correct <- ggplot(
  ipca,
  aes(x = factor(year), y = ipca_percent)
) +
  geom_col(width = 0.68) +
  geom_hline(
    yintercept = 4.5,
    linetype = "dashed",
    linewidth = 0.7
  ) +
  annotate(
    "text",
    x = 5,
    y = 4.75,
    label = "Reference: 4.5%",
    hjust = 1,
    size = 3.5
  ) +
  scale_y_continuous(
    limits = c(0, NA),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    title = "IPCA in Brazil, 2009–2013",
    subtitle = "Zero baseline preserves proportional bar lengths",
    x = "Year",
    y = "IPCA (%)",
    caption = "Values follow the Campus Virtual Fiocruz Activity 3 example."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(
  "practice/manual_attempts/module2_lesson2/activity03_graphical_integrity_ipca/outputs/ipca_correct_zero_baseline.png",
  p_correct,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

cat("\n============================================================\n")
cat("STEP 3 — CORRECT VERSION\n")
cat("============================================================\n")
cat("The y-axis starts at zero.\n")
cat("Now bar lengths are proportional to the actual IPCA values.\n")

# ------------------------------------------------------------
# STEP 4 — QUANTIFY REAL DIFFERENCES
# ------------------------------------------------------------

comparison <- ipca |>
  mutate(
    absolute_change_from_previous = ipca_percent - lag(ipca_percent),
    relative_change_percent = 100 *
      (ipca_percent - lag(ipca_percent)) / lag(ipca_percent)
  ) |>
  mutate(
    absolute_change_from_previous =
      round(absolute_change_from_previous, 2),
    relative_change_percent =
      round(relative_change_percent, 1)
  )

cat("\n============================================================\n")
cat("STEP 4 — NUMERICAL CONTEXT\n")
cat("============================================================\n")
print(comparison)

cat("\nWhy calculate this?\n")
cat("A figure should not substitute visual drama for quantitative context.\n")

# ------------------------------------------------------------
# STEP 5 — GRAPHICAL-INTEGRITY CHECKLIST
# ------------------------------------------------------------

integrity_checklist <- tibble(
  principle = c(
    "Bar baseline",
    "Bar height",
    "Axis units",
    "Title/context",
    "Reference line",
    "Color"
  ),
  good_practice = c(
    "Start quantitative bar axis at zero",
    "Make bar height proportional to the value",
    "Label the y-axis with %",
    "State measure, place and period clearly",
    "Use only when it adds interpretable context",
    "Avoid decorative color when it carries no information"
  )
)

cat("\n============================================================\n")
cat("STEP 5 — GRAPHICAL-INTEGRITY CHECKLIST\n")
cat("============================================================\n")
print(integrity_checklist)

# ------------------------------------------------------------
# STEP 6 — SAVE TABLES
# ------------------------------------------------------------

write_csv(
  ipca,
  "practice/manual_attempts/module2_lesson2/activity03_graphical_integrity_ipca/outputs/ipca_values.csv"
)

write_csv(
  comparison,
  "practice/manual_attempts/module2_lesson2/activity03_graphical_integrity_ipca/outputs/ipca_change_table.csv"
)

write_csv(
  integrity_checklist,
  "practice/manual_attempts/module2_lesson2/activity03_graphical_integrity_ipca/outputs/graphical_integrity_checklist.csv"
)

# ------------------------------------------------------------
# STEP 7 — VALIDATION
# ------------------------------------------------------------

stopifnot(nrow(ipca) == 5)
stopifnot(identical(ipca$year, 2009:2013))
stopifnot(all(ipca$ipca_percent > 0))

required_figures <- c(
  "practice/manual_attempts/module2_lesson2/activity03_graphical_integrity_ipca/outputs/ipca_misleading_truncated_axis.png",
  "practice/manual_attempts/module2_lesson2/activity03_graphical_integrity_ipca/outputs/ipca_correct_zero_baseline.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n============================================================\n")
cat("✅ M2 LESSON 2 · ACTIVITY 3 PASSED\n")
cat("============================================================\n")
cat("You created:\n")
cat("  • one deliberately misleading bar chart\n")
cat("  • one corrected zero-baseline bar chart\n")
cat("  • a numerical change table\n")
cat("  • a graphical-integrity checklist\n")
cat("\n")
cat("Core lesson:\n")
cat("  bar charts encode magnitude through length, so a truncated\n")
cat("  quantitative axis can strongly distort perception.\n")
