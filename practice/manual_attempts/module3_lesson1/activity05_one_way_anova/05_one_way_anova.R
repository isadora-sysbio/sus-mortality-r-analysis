# ============================================================
# FIOCRUZ — Module 3, Lesson 1, Activity 5
#
# Question:
# Does mean systolic blood pressure differ among three
# age groups?
#
# Official course design:
#   Young: 20 people, mean 115, SD 10
#   Adult: 20 people, mean 125, SD 12
#   Older: 20 people, mean 135, SD 15
#   seed = 123
#
# H0: mu_young = mu_adult = mu_older
# H1: at least one population mean differs
#
# If ANOVA is significant, TukeyHSD() is used to identify
# which pairs differ while adjusting for multiple comparisons.
# ============================================================

required <- c("dplyr", "readr", "ggplot2", "tibble", "broom")

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
  library(broom)
})

set.seed(123)
alpha <- 0.05

# ------------------------------------------------------------
# STEP 1 — REPRODUCE THE COURSE DATA GENERATION
# ------------------------------------------------------------

bp_data <- tibble(
  age_group = factor(
    rep(
      c("Young", "Adult", "Older"),
      each = 20
    ),
    levels = c("Young", "Adult", "Older")
  ),
  systolic_bp = c(
    rnorm(20, mean = 115, sd = 10),
    rnorm(20, mean = 125, sd = 12),
    rnorm(20, mean = 135, sd = 15)
  )
)

cat("\n============================================================\n")
cat("STEP 1 — SIMULATED BLOOD-PRESSURE DATA\n")
cat("============================================================\n")
print(bp_data, n = 12)
cat("... additional rows omitted from console display.\n")

cat("\nResearch question:\n")
cat("Does mean systolic blood pressure differ across age groups?\n")

cat("\nHypotheses:\n")
cat("H0: mu_Young = mu_Adult = mu_Older\n")
cat("H1: at least one population mean differs\n")

# ------------------------------------------------------------
# STEP 2 — GROUP DESCRIPTIVE STATISTICS
# ------------------------------------------------------------

group_summary <- bp_data |>
  group_by(age_group) |>
  summarise(
    n = n(),
    mean_mmHg = mean(systolic_bp),
    median_mmHg = median(systolic_bp),
    sd_mmHg = sd(systolic_bp),
    se_mmHg = sd_mmHg / sqrt(n),
    .groups = "drop"
  )

cat("\n============================================================\n")
cat("STEP 2 — GROUP SUMMARIES\n")
cat("============================================================\n")
print(
  group_summary |>
    mutate(across(where(is.numeric), ~ round(.x, 3)))
)

# ------------------------------------------------------------
# STEP 3 — VISUALIZE BEFORE TESTING
# ------------------------------------------------------------

p_groups <- ggplot(
  bp_data,
  aes(
    x = age_group,
    y = systolic_bp
  )
) +
  geom_boxplot(
    width = 0.5,
    outlier.shape = NA
  ) +
  geom_jitter(
    width = 0.08,
    alpha = 0.55,
    size = 2
  ) +
  stat_summary(
    fun = mean,
    geom = "point",
    shape = 23,
    size = 3.5,
    fill = "white"
  ) +
  labs(
    title = "Systolic blood pressure by age group",
    subtitle = "Individual values, boxplots and group means",
    x = "Age group",
    y = "Systolic blood pressure (mmHg)",
    caption = "Synthetic data generated from the Campus Virtual Fiocruz Activity 5 design."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/bp_by_age_group.png",
  p_groups,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 4 — FIT ONE-WAY ANOVA
# ------------------------------------------------------------

anova_model <- aov(
  systolic_bp ~ age_group,
  data = bp_data
)

cat("\n============================================================\n")
cat("STEP 4 — ONE-WAY ANOVA\n")
cat("============================================================\n")
print(summary(anova_model))

anova_table <- broom::tidy(anova_model)

anova_p <- anova_table$p.value[
  anova_table$term == "age_group"
]

anova_f <- anova_table$statistic[
  anova_table$term == "age_group"
]

cat("\nHow to read the ANOVA table:\n")
cat("- Df      = degrees of freedom\n")
cat("- Sum Sq  = sums of squares\n")
cat("- Mean Sq = sums of squares / df\n")
cat("- F       = between-group signal relative to within-group noise\n")
cat("- p-value = evidence against H0 under the ANOVA model\n")

if (anova_p < alpha) {
  cat("\nDecision: REJECT H0 at alpha = 0.05.\n")
  cat("At least one population mean differs.\n")
} else {
  cat("\nDecision: DO NOT reject H0 at alpha = 0.05.\n")
  cat("There is insufficient evidence that the group means differ.\n")
}

cat("\nImportant:\n")
cat("A significant ANOVA does NOT by itself tell us WHICH groups differ.\n")

# ------------------------------------------------------------
# STEP 5 — TUKEY HSD POST-HOC COMPARISONS
# ------------------------------------------------------------

tukey <- TukeyHSD(
  anova_model,
  "age_group",
  conf.level = 0.95
)

cat("\n============================================================\n")
cat("STEP 5 — TUKEY MULTIPLE COMPARISONS\n")
cat("============================================================\n")
print(tukey)

tukey_table <- as.data.frame(
  tukey$age_group
) |>
  rownames_to_column("comparison") |>
  as_tibble() |>
  rename(
    mean_difference = diff,
    ci_lower = lwr,
    ci_upper = upr,
    adjusted_p_value = `p adj`
  ) |>
  mutate(
    significant_0_05 = adjusted_p_value < alpha
  )

cat("\nTukey interpretation table:\n")
print(
  tukey_table |>
    mutate(
      across(
        c(
          mean_difference,
          ci_lower,
          ci_upper,
          adjusted_p_value
        ),
        ~ round(.x, 4)
      )
    )
)

cat("\nTukey logic:\n")
cat("- adjusted p < 0.05 -> that pair differs significantly\n")
cat("- the adjusted CI excluding 0 tells the same story\n")

# ------------------------------------------------------------
# STEP 6 — WHY NOT RUN THREE UNADJUSTED t TESTS?
# ------------------------------------------------------------

n_groups <- nlevels(bp_data$age_group)
n_pairwise <- choose(n_groups, 2)

familywise_error_if_independent <- 1 - (1 - alpha)^n_pairwise

multiplicity_note <- tibble(
  number_of_groups = n_groups,
  pairwise_comparisons = n_pairwise,
  per_test_alpha = alpha,
  illustrative_familywise_error =
    familywise_error_if_independent
)

cat("\n============================================================\n")
cat("STEP 6 — MULTIPLE-TESTING IDEA\n")
cat("============================================================\n")
print(
  multiplicity_note |>
    mutate(
      illustrative_familywise_error =
        round(100 * illustrative_familywise_error, 1)
    )
)

cat("\nRunning many unadjusted tests inflates the chance of at least\n")
cat("one false-positive result. Tukey controls the familywise error\n")
cat("for the set of pairwise comparisons.\n")

# ------------------------------------------------------------
# STEP 7 — EFFECT SIZE: ETA-SQUARED
# ------------------------------------------------------------

ss_between <- anova_table$sumsq[
  anova_table$term == "age_group"
]

ss_total <- sum(
  anova_table$sumsq,
  na.rm = TRUE
)

eta_squared <- ss_between / ss_total

effect_size <- tibble(
  effect = "Eta squared",
  estimate = eta_squared,
  interpretation = case_when(
    eta_squared < 0.01 ~ "Very small",
    eta_squared < 0.06 ~ "Small",
    eta_squared < 0.14 ~ "Moderate",
    TRUE ~ "Large"
  )
)

cat("\n============================================================\n")
cat("STEP 7 — EFFECT SIZE EXTENSION\n")
cat("============================================================\n")
print(
  effect_size |>
    mutate(estimate = round(estimate, 4))
)

cat("\nEta-squared describes the fraction of observed outcome variance\n")
cat("associated with age-group membership in this ANOVA model.\n")

# ------------------------------------------------------------
# STEP 8 — ASSUMPTION / DIAGNOSTIC CHECKS
# ------------------------------------------------------------
#
# These are exploratory diagnostics, not mechanical gates.
#
# ANOVA relies on:
#   - independent observations
#   - approximately Normal residual behavior
#   - reasonably similar within-group variances
#
# We use a residual Q-Q plot and a residual-vs-fitted plot.

diagnostics <- augment(anova_model)

p_qq <- ggplot(
  diagnostics,
  aes(sample = .std.resid)
) +
  stat_qq() +
  stat_qq_line() +
  labs(
    title = "ANOVA residual Q-Q plot",
    subtitle = "Exploratory check of residual Normality",
    x = "Theoretical Normal quantiles",
    y = "Standardized residual quantiles",
    caption = "Diagnostic plot; not used as an automatic pass/fail gate."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/anova_residual_qq.png",
  p_qq,
  width = 7,
  height = 5,
  dpi = 300,
  bg = "white"
)

p_resid <- ggplot(
  diagnostics,
  aes(
    x = .fitted,
    y = .resid
  )
) +
  geom_point(alpha = 0.7) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  labs(
    title = "ANOVA residuals versus fitted values",
    subtitle = "Exploratory check for changing residual spread or structure",
    x = "Fitted systolic BP (mmHg)",
    y = "Residual (mmHg)",
    caption = "Diagnostic plot; interpret alongside study design."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/anova_residuals_vs_fitted.png",
  p_resid,
  width = 7.5,
  height = 5,
  dpi = 300,
  bg = "white"
)

variance_summary <- bp_data |>
  group_by(age_group) |>
  summarise(
    variance = var(systolic_bp),
    sd = sd(systolic_bp),
    .groups = "drop"
  )

cat("\n============================================================\n")
cat("STEP 8 — WITHIN-GROUP SPREAD\n")
cat("============================================================\n")
print(
  variance_summary |>
    mutate(across(where(is.numeric), ~ round(.x, 3)))
)

cat("\nDo not reduce assumptions to a single checkbox.\n")
cat("Study design + residual diagnostics + group spread all matter.\n")

# ------------------------------------------------------------
# STEP 9 — VISUALIZE TUKEY DIFFERENCES
# ------------------------------------------------------------

p_tukey <- ggplot(
  tukey_table,
  aes(
    x = reorder(
      comparison,
      mean_difference
    ),
    y = mean_difference,
    ymin = ci_lower,
    ymax = ci_upper
  )
) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  geom_pointrange() +
  coord_flip() +
  labs(
    title = "Tukey-adjusted pairwise mean differences",
    subtitle = "Intervals excluding zero indicate significant pairwise differences",
    x = NULL,
    y = "Mean systolic BP difference (mmHg)",
    caption = "Post-hoc comparisons after one-way ANOVA."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/tukey_pairwise_differences.png",
  p_tukey,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 10 — SAVE TABLES
# ------------------------------------------------------------

write_csv(
  bp_data,
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/blood_pressure_by_age_group.csv"
)

write_csv(
  group_summary,
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/group_summary.csv"
)

write_csv(
  anova_table,
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/anova_table.csv"
)

write_csv(
  tukey_table,
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/tukey_pairwise_comparisons.csv"
)

write_csv(
  effect_size,
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/eta_squared.csv"
)

write_csv(
  variance_summary,
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/group_variance_summary.csv"
)

write_csv(
  multiplicity_note,
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/multiple_testing_note.csv"
)

# ------------------------------------------------------------
# STEP 11 — VALIDATION
# ------------------------------------------------------------

stopifnot(nrow(bp_data) == 60)
stopifnot(nlevels(bp_data$age_group) == 3)
stopifnot(all(group_summary$n == 20))
stopifnot(n_pairwise == 3)

stopifnot(
  is.finite(anova_f),
  anova_p >= 0,
  anova_p <= 1
)

# With the official seed/design, the omnibus ANOVA should be significant.
stopifnot(anova_p < 0.05)

# At least one Tukey pair should be significant.
stopifnot(any(tukey_table$significant_0_05))

# Significant Tukey rows should have CIs excluding zero.
sig_rows <- tukey_table |>
  filter(significant_0_05)

stopifnot(
  all(
    sig_rows$ci_lower > 0 |
      sig_rows$ci_upper < 0
  )
)

stopifnot(
  eta_squared >= 0,
  eta_squared <= 1
)

required_figures <- c(
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/bp_by_age_group.png",
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/anova_residual_qq.png",
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/anova_residuals_vs_fitted.png",
  "practice/manual_attempts/module3_lesson1/activity05_one_way_anova/outputs/tukey_pairwise_differences.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n============================================================\n")
cat("✅ M3 LESSON 1 · ACTIVITY 5 PASSED\n")
cat("============================================================\n")
cat("Omnibus ANOVA p-value:", format(anova_p, digits = 4), "\n")
cat("Significant Tukey pairs:", sum(tukey_table$significant_0_05), "\n")
cat("Eta-squared:", round(eta_squared, 3), "\n")
cat("\n")
cat("You demonstrated:\n")
cat("  • comparison of 3+ means\n")
cat("  • one-way aov()\n")
cat("  • F statistic and omnibus p-value\n")
cat("  • TukeyHSD() post-hoc comparisons\n")
cat("  • multiplicity / familywise error logic\n")
cat("  • effect size with eta-squared\n")
cat("  • residual diagnostics\n")
