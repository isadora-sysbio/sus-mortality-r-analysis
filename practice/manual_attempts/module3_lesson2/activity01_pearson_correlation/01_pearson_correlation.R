# ============================================================
# FIOCRUZ — Module 3, Lesson 2, Activity 1
#
# Official activity:
#   calculate the correlation between systolic blood pressure
#   and age, interpret strength/direction, and visualize the
#   relationship with a scatter plot.
#
# Official data-generation recipe:
#   set.seed(42)
#   n = 30
#   age ~ Uniform(25, 75)
#   SBP = 100 + 0.8*age + Normal(0, 10)
#   sex generated randomly
#
# Main lesson:
#   Pearson's r describes the strength and direction of a
#   LINEAR association. Correlation does not imply causation.
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

set.seed(42)
alpha <- 0.05
n <- 30

# ------------------------------------------------------------
# STEP 1 — REPRODUCE THE OFFICIAL COURSE DATA
# ------------------------------------------------------------

bp_age <- tibble(
  age = round(runif(n, min = 25, max = 75)),
  systolic_bp = round(
    100 + 0.8 * age + rnorm(n, 0, 10)
  ),
  sex = if_else(
    runif(n) >= 0.5,
    "Female",
    "Male"
  )
)

cat("\n============================================================\n")
cat("STEP 1 — SIMULATED PATIENT DATA\n")
cat("============================================================\n")
print(bp_age, n = 30)

cat("\nData-generation model used by the course:\n")
cat("  SBP = 100 + 0.8 × age + random noise\n")
cat("\nThis creates a real positive association in the synthetic data.\n")

# ------------------------------------------------------------
# STEP 2 — DESCRIPTIVE CONTEXT
# ------------------------------------------------------------

descriptive <- bp_age |>
  summarise(
    n = n(),
    mean_age = mean(age),
    sd_age = sd(age),
    mean_sbp = mean(systolic_bp),
    sd_sbp = sd(systolic_bp),
    min_age = min(age),
    max_age = max(age),
    min_sbp = min(systolic_bp),
    max_sbp = max(systolic_bp)
  )

cat("\n============================================================\n")
cat("STEP 2 — DESCRIPTIVE CONTEXT\n")
cat("============================================================\n")
print(
  descriptive |>
    mutate(across(where(is.numeric), ~ round(.x, 2)))
)

# ------------------------------------------------------------
# STEP 3 — PEARSON CORRELATION TEST
# ------------------------------------------------------------

pearson <- cor.test(
  bp_age$systolic_bp,
  bp_age$age,
  method = "pearson",
  alternative = "two.sided",
  conf.level = 0.95
)

cat("\n============================================================\n")
cat("STEP 3 — PEARSON cor.test()\n")
cat("============================================================\n")
print(pearson)

r <- unname(pearson$estimate)
abs_r <- abs(r)

direction <- case_when(
  r > 0 ~ "Positive",
  r < 0 ~ "Negative",
  TRUE ~ "No linear direction"
)

strength <- case_when(
  abs_r < 0.3 ~ "Weak",
  abs_r < 0.7 ~ "Moderate",
  TRUE ~ "Strong"
)

significance <- if_else(
  pearson$p.value < alpha,
  "Statistically significant",
  "Not statistically significant"
)

pearson_summary <- tibble(
  n = n,
  pearson_r = r,
  direction = direction,
  strength = strength,
  t_statistic = unname(pearson$statistic),
  df = unname(pearson$parameter),
  p_value = pearson$p.value,
  ci_lower = pearson$conf.int[1],
  ci_upper = pearson$conf.int[2],
  significance = significance
)

cat("\n============================================================\n")
cat("STEP 4 — INTERPRETATION\n")
cat("============================================================\n")
print(
  pearson_summary |>
    mutate(
      across(
        c(
          pearson_r,
          t_statistic,
          p_value,
          ci_lower,
          ci_upper
        ),
        ~ round(.x, 4)
      )
    )
)

cat("\nInterpretation:\n")
cat(
  "r =",
  round(r, 3),
  "->",
  tolower(strength),
  tolower(direction),
  "linear correlation.\n"
)

if (pearson$p.value < alpha) {
  cat("p <", alpha, "-> reject H0: rho = 0.\n")
  cat("There is evidence of a non-zero linear correlation.\n")
} else {
  cat("p >=", alpha, "-> do not reject H0: rho = 0.\n")
  cat("There is insufficient evidence of a linear correlation.\n")
}

cat("\nIMPORTANT:\n")
cat("Correlation describes association, not causation.\n")
cat("A high r does not prove that age itself causes the observed SBP change.\n")

# ------------------------------------------------------------
# STEP 5 — SCATTER PLOT
# ------------------------------------------------------------

p_scatter <- ggplot(
  bp_age,
  aes(
    x = age,
    y = systolic_bp
  )
) +
  geom_point(
    size = 3,
    alpha = 0.75
  ) +
  labs(
    title = "Age and systolic blood pressure",
    subtitle = paste0(
      "Pearson r = ",
      round(r, 2),
      " (",
      tolower(strength),
      " ",
      tolower(direction),
      " correlation)"
    ),
    x = "Age (years)",
    y = "Systolic blood pressure (mmHg)",
    caption = "Synthetic data generated with the Campus Virtual Fiocruz Activity 1 recipe."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/age_sbp_scatter.png",
  p_scatter,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 6 — ENRICHED VISUALIZATION WITH LINEAR TREND
# ------------------------------------------------------------
#
# The course asks for a scatter plot. This second figure is a
# portfolio extension: the regression line helps visualize the
# linear direction, while the raw points remain visible.

p_trend <- ggplot(
  bp_age,
  aes(
    x = age,
    y = systolic_bp
  )
) +
  geom_point(
    aes(shape = sex),
    size = 2.8,
    alpha = 0.75
  ) +
  geom_smooth(
    method = "lm",
    formula = y ~ x,
    se = TRUE,
    linewidth = 0.8
  ) +
  labs(
    title = "Linear trend between age and systolic blood pressure",
    subtitle = paste0(
      "Pearson r = ",
      round(r, 2),
      "; p = ",
      format.pval(pearson$p.value, digits = 2)
    ),
    x = "Age (years)",
    y = "Systolic blood pressure (mmHg)",
    shape = "Sex",
    caption = "Trend line is descriptive of the linear association; it does not establish causality."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

ggsave(
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/age_sbp_linear_trend.png",
  p_trend,
  width = 8.5,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 7 — PEARSON VS SPEARMAN EXTENSION
# ------------------------------------------------------------
#
# The lesson notes that Spearman correlation can be useful when
# Pearson's assumptions are not appropriate. We compute both so
# their roles are visible without replacing the official task.

spearman <- cor.test(
  bp_age$systolic_bp,
  bp_age$age,
  method = "spearman",
  alternative = "two.sided",
  exact = FALSE
)

method_comparison <- tibble(
  method = c("Pearson", "Spearman"),
  coefficient = c(
    unname(pearson$estimate),
    unname(spearman$estimate)
  ),
  p_value = c(
    pearson$p.value,
    spearman$p.value
  ),
  primary_question = c(
    "Linear association",
    "Monotonic rank association"
  )
)

cat("\n============================================================\n")
cat("STEP 7 — PEARSON VS SPEARMAN EXTENSION\n")
cat("============================================================\n")
print(
  method_comparison |>
    mutate(
      across(
        c(coefficient, p_value),
        ~ round(.x, 4)
      )
    )
)

cat("\nPearson is the official activity here because the simulated\n")
cat("relationship is designed to be approximately linear.\n")

# ------------------------------------------------------------
# STEP 8 — ASSUMPTION / SHAPE CHECKS
# ------------------------------------------------------------

p_qq_age <- ggplot(
  bp_age,
  aes(sample = age)
) +
  stat_qq() +
  stat_qq_line() +
  labs(
    title = "Q-Q plot: age",
    subtitle = "Exploratory distribution check",
    x = "Theoretical Normal quantiles",
    y = "Observed age quantiles",
    caption = "Diagnostic aid; interpret together with the scatter plot."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/qq_age.png",
  p_qq_age,
  width = 6.5,
  height = 5,
  dpi = 300,
  bg = "white"
)

p_qq_sbp <- ggplot(
  bp_age,
  aes(sample = systolic_bp)
) +
  stat_qq() +
  stat_qq_line() +
  labs(
    title = "Q-Q plot: systolic blood pressure",
    subtitle = "Exploratory distribution check",
    x = "Theoretical Normal quantiles",
    y = "Observed SBP quantiles (mmHg)",
    caption = "Diagnostic aid; linearity should still be judged from the scatter plot."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/qq_sbp.png",
  p_qq_sbp,
  width = 6.5,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 9 — SAVE OUTPUTS
# ------------------------------------------------------------

write_csv(
  bp_age,
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/simulated_bp_age_data.csv"
)

write_csv(
  descriptive,
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/descriptive_summary.csv"
)

write_csv(
  pearson_summary,
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/pearson_correlation_summary.csv"
)

write_csv(
  method_comparison,
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/pearson_vs_spearman.csv"
)

# ------------------------------------------------------------
# STEP 10 — VALIDATION
# ------------------------------------------------------------

stopifnot(nrow(bp_age) == 30)
stopifnot(all(bp_age$age >= 25))
stopifnot(all(bp_age$age <= 75))

stopifnot(
  is.finite(r),
  r >= -1,
  r <= 1
)

# The official seed and simulation recipe deliberately create a
# positive age-SBP association. We validate the intended signal
# without hard-coding an exact floating-point coefficient.
stopifnot(r > 0.3)
stopifnot(pearson$p.value < 0.05)

required_figures <- c(
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/age_sbp_scatter.png",
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/age_sbp_linear_trend.png",
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/qq_age.png",
  "practice/manual_attempts/module3_lesson2/activity01_pearson_correlation/outputs/qq_sbp.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n============================================================\n")
cat("✅ M3 LESSON 2 · ACTIVITY 1 PASSED\n")
cat("============================================================\n")
cat("Pearson r:", round(r, 3), "\n")
cat("Direction:", direction, "\n")
cat("Strength:", strength, "\n")
cat("p-value:", format.pval(pearson$p.value, digits = 3), "\n")
cat("\n")
cat("You practiced:\n")
cat("  • scatter plots for two numeric variables\n")
cat("  • cor()\n")
cat("  • cor.test()\n")
cat("  • Pearson r\n")
cat("  • strength + direction interpretation\n")
cat("  • H0: rho = 0\n")
cat("  • confidence interval for correlation\n")
cat("  • correlation ≠ causation\n")
cat("  • Pearson vs Spearman distinction\n")
