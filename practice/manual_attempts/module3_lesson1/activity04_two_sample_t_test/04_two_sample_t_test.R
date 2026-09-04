# ============================================================
# FIOCRUZ — Module 3, Lesson 1, Activity 4
#
# Question:
# Do mean cholesterol measurements differ between two
# independent measurement methods?
#
# Official course data:
#   AutoAnalyzer:   177, 193, 195, 209, 226
#   Microenzimatic: 192, 197, 200, 202, 209
#
# H0: mu_AutoAnalyzer = mu_Microenzimatic
# H1: mu_AutoAnalyzer != mu_Microenzimatic
#
# R's t.test(y ~ group) defaults to Welch's two-sample t test,
# which does NOT assume equal variances.
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

alpha <- 0.05

# ------------------------------------------------------------
# STEP 1 — OFFICIAL COURSE DATA
# ------------------------------------------------------------

cholesterol <- tibble(
  method = rep(
    c("AutoAnalyzer", "Microenzimatic"),
    each = 5
  ),
  value = c(
    177, 193, 195, 209, 226,
    192, 197, 200, 202, 209
  )
)

cat("\n============================================================\n")
cat("STEP 1 — DATA + RESEARCH QUESTION\n")
cat("============================================================\n")
print(cholesterol)

cat("\nQuestion:\n")
cat("Do the two independent methods have different mean cholesterol values?\n")

cat("\nHypotheses:\n")
cat("H0: mu_AutoAnalyzer = mu_Microenzimatic\n")
cat("H1: mu_AutoAnalyzer != mu_Microenzimatic\n")

# ------------------------------------------------------------
# STEP 2 — GROUP DESCRIPTIVES
# ------------------------------------------------------------

group_summary <- cholesterol |>
  group_by(method) |>
  summarise(
    n = n(),
    mean = mean(value),
    median = median(value),
    sd = sd(value),
    se = sd / sqrt(n),
    minimum = min(value),
    maximum = max(value),
    .groups = "drop"
  )

cat("\n============================================================\n")
cat("STEP 2 — GROUP DESCRIPTIVE STATISTICS\n")
cat("============================================================\n")
print(
  group_summary |>
    mutate(across(where(is.numeric), ~ round(.x, 3)))
)

mean_auto <- group_summary$mean[
  group_summary$method == "AutoAnalyzer"
]

mean_micro <- group_summary$mean[
  group_summary$method == "Microenzimatic"
]

observed_difference <- mean_auto - mean_micro

cat("\nObserved mean difference (AutoAnalyzer - Microenzimatic):\n")
cat(round(observed_difference, 2), "\n")

# ------------------------------------------------------------
# STEP 3 — VISUALIZE BEFORE TESTING
# ------------------------------------------------------------

p_groups <- ggplot(
  cholesterol,
  aes(x = method, y = value)
) +
  geom_boxplot(
    width = 0.45,
    outlier.shape = NA
  ) +
  geom_jitter(
    width = 0.07,
    size = 2.8,
    alpha = 0.8
  ) +
  stat_summary(
    fun = mean,
    geom = "point",
    shape = 23,
    size = 3.5,
    fill = "white"
  ) +
  labs(
    title = "Cholesterol measurements by method",
    subtitle = "Points = individual values; diamond = group mean",
    x = NULL,
    y = "Cholesterol value",
    caption = "Campus Virtual Fiocruz Activity 4 data."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity04_two_sample_t_test/outputs/cholesterol_by_method.png",
  p_groups,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 4 — WELCH TWO-SAMPLE t TEST
# ------------------------------------------------------------
#
# This is exactly the default behavior of:
# t.test(value ~ method, data = cholesterol)

welch_test <- t.test(
  value ~ method,
  data = cholesterol,
  alternative = "two.sided",
  var.equal = FALSE,
  conf.level = 0.95
)

cat("\n============================================================\n")
cat("STEP 4 — WELCH TWO-SAMPLE t TEST\n")
cat("============================================================\n")
print(welch_test)

welch_summary <- tibble(
  mean_autoanalyzer = mean_auto,
  mean_microenzimatic = mean_micro,
  difference_auto_minus_micro = observed_difference,
  t_statistic = unname(welch_test$statistic),
  df = unname(welch_test$parameter),
  p_value = welch_test$p.value,
  ci_lower = welch_test$conf.int[1],
  ci_upper = welch_test$conf.int[2],
  alpha = alpha
) |>
  mutate(
    decision = if_else(
      p_value < alpha,
      "Reject H0",
      "Do not reject H0"
    ),
    interpretation = if_else(
      p_value < alpha,
      "Evidence of a difference between mean cholesterol measurements",
      "Insufficient evidence of a difference between mean cholesterol measurements"
    )
  )

cat("\n============================================================\n")
cat("STEP 5 — PLAIN-LANGUAGE RESULT\n")
cat("============================================================\n")
print(
  welch_summary |>
    mutate(
      across(
        where(is.numeric),
        ~ round(.x, 4)
      )
    )
)

cat("\nDecision rule:\n")
cat("If p < 0.05 -> reject H0.\n")
cat("If p >= 0.05 -> do not reject H0.\n")

if (welch_summary$p_value < alpha) {
  cat("\nConclusion: reject H0.\n")
  cat("There is evidence that the two methods have different means.\n")
} else {
  cat("\nConclusion: DO NOT reject H0.\n")
  cat("There is insufficient evidence that the two methods have different means.\n")
}

cat("\nImportant:\n")
cat("A non-significant result does not prove the methods are identical.\n")
cat("It means this sample does not provide strong enough evidence of a mean difference.\n")

# ------------------------------------------------------------
# STEP 6 — WHY WELCH?
# ------------------------------------------------------------

variance_table <- cholesterol |>
  group_by(method) |>
  summarise(
    variance = var(value),
    sd = sd(value),
    .groups = "drop"
  )

cat("\n============================================================\n")
cat("STEP 6 — VARIANCE COMPARISON\n")
cat("============================================================\n")
print(
  variance_table |>
    mutate(across(where(is.numeric), ~ round(.x, 3)))
)

cat("\nR's default two-sample t.test() uses Welch's method.\n")
cat("Welch's test allows the two groups to have unequal variances.\n")
cat("That is generally a safer default than assuming equal variances automatically.\n")

# ------------------------------------------------------------
# STEP 7 — EQUAL-VARIANCE VERSION AS A LEARNING EXTENSION
# ------------------------------------------------------------

student_test <- t.test(
  value ~ method,
  data = cholesterol,
  alternative = "two.sided",
  var.equal = TRUE,
  conf.level = 0.95
)

comparison_tests <- tibble(
  method = c(
    "Welch t test (default)",
    "Pooled-variance Student t test"
  ),
  assumes_equal_variance = c(FALSE, TRUE),
  t_statistic = c(
    unname(welch_test$statistic),
    unname(student_test$statistic)
  ),
  df = c(
    unname(welch_test$parameter),
    unname(student_test$parameter)
  ),
  p_value = c(
    welch_test$p.value,
    student_test$p.value
  )
)

cat("\n============================================================\n")
cat("STEP 7 — WELCH VS EQUAL-VARIANCE VERSION\n")
cat("============================================================\n")
print(
  comparison_tests |>
    mutate(
      across(
        c(t_statistic, df, p_value),
        ~ round(.x, 4)
      )
    )
)

# ------------------------------------------------------------
# STEP 8 — CONFIDENCE-INTERVAL CONNECTION
# ------------------------------------------------------------

zero_inside_ci <- (
  welch_summary$ci_lower <= 0 &&
  welch_summary$ci_upper >= 0
)

ci_logic <- tibble(
  estimated_mean_difference = observed_difference,
  ci_lower = welch_summary$ci_lower,
  ci_upper = welch_summary$ci_upper,
  zero_inside_95_ci = zero_inside_ci,
  p_value = welch_summary$p_value,
  reject_at_0_05 = welch_summary$p_value < alpha
)

cat("\n============================================================\n")
cat("STEP 8 — CI CONNECTION\n")
cat("============================================================\n")
print(
  ci_logic |>
    mutate(
      across(
        where(is.numeric),
        ~ round(.x, 4)
      )
    )
)

cat("\nFor a two-sided alpha = 0.05 comparison:\n")
cat("- if 0 is outside the 95% CI for the mean difference -> reject H0\n")
cat("- if 0 is inside the 95% CI -> do not reject H0\n")

# ------------------------------------------------------------
# STEP 9 — EFFECT SIZE EXTENSION
# ------------------------------------------------------------
#
# Cohen's d using pooled SD is included only as a magnitude
# description. It is separate from the Welch hypothesis test.

auto_values <- cholesterol$value[
  cholesterol$method == "AutoAnalyzer"
]

micro_values <- cholesterol$value[
  cholesterol$method == "Microenzimatic"
]

n1 <- length(auto_values)
n2 <- length(micro_values)
s1 <- sd(auto_values)
s2 <- sd(micro_values)

pooled_sd <- sqrt(
  (
    (n1 - 1) * s1^2 +
      (n2 - 1) * s2^2
  ) /
    (n1 + n2 - 2)
)

cohens_d <- observed_difference / pooled_sd

effect_size <- tibble(
  mean_difference = observed_difference,
  pooled_sd = pooled_sd,
  cohens_d = cohens_d
)

cat("\n============================================================\n")
cat("STEP 9 — EFFECT SIZE EXTENSION\n")
cat("============================================================\n")
print(
  effect_size |>
    mutate(across(where(is.numeric), ~ round(.x, 4)))
)

cat("\nWhy add effect size?\n")
cat("p-values address evidence; effect size addresses magnitude.\n")

# ------------------------------------------------------------
# STEP 10 — SAVE OUTPUTS
# ------------------------------------------------------------

write_csv(
  cholesterol,
  "practice/manual_attempts/module3_lesson1/activity04_two_sample_t_test/outputs/cholesterol_measurements.csv"
)

write_csv(
  group_summary,
  "practice/manual_attempts/module3_lesson1/activity04_two_sample_t_test/outputs/group_summary.csv"
)

write_csv(
  welch_summary,
  "practice/manual_attempts/module3_lesson1/activity04_two_sample_t_test/outputs/welch_t_test_summary.csv"
)

write_csv(
  comparison_tests,
  "practice/manual_attempts/module3_lesson1/activity04_two_sample_t_test/outputs/welch_vs_equal_variance.csv"
)

write_csv(
  ci_logic,
  "practice/manual_attempts/module3_lesson1/activity04_two_sample_t_test/outputs/ci_hypothesis_connection.csv"
)

write_csv(
  effect_size,
  "practice/manual_attempts/module3_lesson1/activity04_two_sample_t_test/outputs/effect_size.csv"
)

# ------------------------------------------------------------
# STEP 11 — VALIDATION
# ------------------------------------------------------------

stopifnot(nrow(cholesterol) == 10)
stopifnot(n_distinct(cholesterol$method) == 2)
stopifnot(all(group_summary$n == 5))

stopifnot(
  abs(
    welch_test$p.value -
      t.test(value ~ method, data = cholesterol)$p.value
  ) < 1e-12
)

stopifnot(welch_test$p.value >= 0 && welch_test$p.value <= 1)

# Official data should produce a non-significant comparison.
stopifnot(welch_test$p.value > 0.05)
stopifnot(zero_inside_ci)

stopifnot(file.exists(
  "practice/manual_attempts/module3_lesson1/activity04_two_sample_t_test/outputs/cholesterol_by_method.png"
))

cat("\n============================================================\n")
cat("✅ M3 LESSON 1 · ACTIVITY 4 PASSED\n")
cat("============================================================\n")
cat("You practiced:\n")
cat("  • independent two-group comparison\n")
cat("  • H0: mu1 = mu2\n")
cat("  • Welch two-sample t test\n")
cat("  • group means and standard deviations\n")
cat("  • p-value interpretation\n")
cat("  • CI for a mean difference\n")
cat("  • Welch vs equal-variance distinction\n")
cat("  • effect size as a separate concept\n")
