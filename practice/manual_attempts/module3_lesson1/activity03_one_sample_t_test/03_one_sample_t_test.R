# ============================================================
# FIOCRUZ — Module 3, Lesson 1, Activity 3
#
# Question:
# Does the mean birth weight in this maternity sample differ
# from a reference value of 3200 g?
#
# H0: mu = 3200 g
# H1: mu != 3200 g
#
# Official course example:
# 20 newborn birth weights + t.test(peso_rn, mu = 3200)
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
# STEP 1 — DATA
# ------------------------------------------------------------

birth_weight_g <- c(
  3265, 3260, 3245, 3484, 4146,
  3323, 3649, 3200, 3031, 2069,
  2581, 2841, 3609, 2838, 3541,
  2759, 3248, 3314, 3101, 2834
)

newborns <- tibble(
  newborn_id = seq_along(birth_weight_g),
  birth_weight_g = birth_weight_g
)

reference_mean <- 3200
alpha <- 0.05

cat("\n============================================================\n")
cat("STEP 1 — DATA + RESEARCH QUESTION\n")
cat("============================================================\n")
print(newborns)

cat("\nQuestion:\n")
cat("Does this sample provide evidence that the population mean\n")
cat("birth weight differs from", reference_mean, "g?\n")

cat("\nHypotheses:\n")
cat("H0: mu =", reference_mean, "g\n")
cat("H1: mu !=", reference_mean, "g\n")

# ------------------------------------------------------------
# STEP 2 — DESCRIPTIVE STATISTICS
# ------------------------------------------------------------

descriptive <- newborns |>
  summarise(
    n = n(),
    mean_g = mean(birth_weight_g),
    median_g = median(birth_weight_g),
    sd_g = sd(birth_weight_g),
    se_g = sd_g / sqrt(n),
    minimum_g = min(birth_weight_g),
    maximum_g = max(birth_weight_g)
  )

cat("\n============================================================\n")
cat("STEP 2 — DESCRIPTIVE STATISTICS\n")
cat("============================================================\n")
print(
  descriptive |>
    mutate(across(where(is.numeric), ~ round(.x, 2)))
)

cat("\nObserved difference from reference:\n")
cat(
  round(descriptive$mean_g - reference_mean, 1),
  "g\n"
)

# ------------------------------------------------------------
# STEP 3 — CALCULATE t MANUALLY
# ------------------------------------------------------------
#
# t = (xbar - mu0) / (s / sqrt(n))

manual_t <- (
  descriptive$mean_g - reference_mean
) / descriptive$se_g

degrees_freedom <- descriptive$n - 1

cat("\n============================================================\n")
cat("STEP 3 — MANUAL t STATISTIC\n")
cat("============================================================\n")
cat("Formula:\n")
cat("t = (sample mean - reference mean) / standard error\n")
cat("\n")
cat("t =", round(manual_t, 4), "\n")
cat("df =", degrees_freedom, "\n")

cat("\nInterpretation:\n")
cat("The sign tells us the sample mean is below or above the reference.\n")
cat("The magnitude tells us how many standard errors separate them.\n")

# ------------------------------------------------------------
# STEP 4 — RUN R'S ONE-SAMPLE t TEST
# ------------------------------------------------------------

test <- t.test(
  birth_weight_g,
  mu = reference_mean,
  alternative = "two.sided",
  conf.level = 0.95
)

cat("\n============================================================\n")
cat("STEP 4 — t.test() OUTPUT\n")
cat("============================================================\n")
print(test)

test_summary <- tibble(
  n = descriptive$n,
  sample_mean_g = unname(test$estimate),
  reference_mean_g = reference_mean,
  mean_difference_g = unname(test$estimate) - reference_mean,
  t_statistic = unname(test$statistic),
  df = unname(test$parameter),
  p_value = test$p.value,
  ci_lower_g = test$conf.int[1],
  ci_upper_g = test$conf.int[2],
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
      "Evidence that the population mean differs from 3200 g",
      "Insufficient evidence that the population mean differs from 3200 g"
    )
  )

cat("\n============================================================\n")
cat("STEP 5 — PLAIN-LANGUAGE RESULT\n")
cat("============================================================\n")
print(
  test_summary |>
    mutate(
      across(
        c(
          sample_mean_g,
          mean_difference_g,
          t_statistic,
          p_value,
          ci_lower_g,
          ci_upper_g
        ),
        ~ round(.x, 4)
      )
    )
)

cat("\nDecision rule:\n")
cat("If p < 0.05 -> reject H0.\n")
cat("If p >= 0.05 -> do not reject H0.\n")

cat("\nFor these data:\n")
cat("Sample mean:", round(test_summary$sample_mean_g, 1), "g\n")
cat("t =", round(test_summary$t_statistic, 3), "\n")
cat("df =", test_summary$df, "\n")
cat("p =", round(test_summary$p_value, 4), "\n")
cat(
  "95% CI:",
  paste0(
    "[",
    round(test_summary$ci_lower_g, 1),
    ", ",
    round(test_summary$ci_upper_g, 1),
    "] g"
  ),
  "\n"
)

if (test_summary$p_value < alpha) {
  cat("\nConclusion: reject H0.\n")
  cat("The sample provides evidence of a mean different from 3200 g.\n")
} else {
  cat("\nConclusion: DO NOT reject H0.\n")
  cat("The sample does not provide sufficient evidence that the mean\n")
  cat("differs from 3200 g.\n")
  cat("\nImportant: this does NOT prove that mu equals 3200 g.\n")
}

# ------------------------------------------------------------
# STEP 6 — CONNECT p VALUE AND CONFIDENCE INTERVAL
# ------------------------------------------------------------

reference_inside_ci <- (
  test_summary$ci_lower_g <= reference_mean &&
  test_summary$ci_upper_g >= reference_mean
)

ci_logic <- tibble(
  reference_mean_g = reference_mean,
  ci_lower_g = test_summary$ci_lower_g,
  ci_upper_g = test_summary$ci_upper_g,
  reference_inside_95_ci = reference_inside_ci,
  p_value = test_summary$p_value,
  reject_at_0_05 = test_summary$p_value < alpha
)

cat("\n============================================================\n")
cat("STEP 6 — CI AND HYPOTHESIS TEST TELL THE SAME STORY\n")
cat("============================================================\n")
print(
  ci_logic |>
    mutate(
      across(
        c(ci_lower_g, ci_upper_g, p_value),
        ~ round(.x, 4)
      )
    )
)

cat("\nFor a two-sided test at alpha = 0.05:\n")
cat("- if the null value is OUTSIDE the 95% CI -> reject H0\n")
cat("- if the null value is INSIDE the 95% CI -> do not reject H0\n")

# ------------------------------------------------------------
# STEP 7 — SIMPLE ASSUMPTION / DATA-SHAPE CHECK
# ------------------------------------------------------------
#
# For a one-sample t test, observations should be independent
# and the mean should not be dominated by severe pathologies in
# a small sample. A Q-Q plot is an exploratory check, not a
# mechanical pass/fail gate.

qq_plot <- ggplot(
  newborns,
  aes(sample = birth_weight_g)
) +
  stat_qq() +
  stat_qq_line() +
  labs(
    title = "Q-Q plot of newborn birth weights",
    subtitle = "Exploratory check of distributional shape for a small sample",
    x = "Theoretical Normal quantiles",
    y = "Observed birth weight quantiles (g)",
    caption = "Course example data."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity03_one_sample_t_test/outputs/qq_birth_weight.png",
  qq_plot,
  width = 7,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 8 — VISUALIZE MEAN + 95% CI AGAINST REFERENCE
# ------------------------------------------------------------

ci_plot_data <- tibble(
  estimate = test_summary$sample_mean_g,
  lower = test_summary$ci_lower_g,
  upper = test_summary$ci_upper_g
)

p_ci <- ggplot(
  ci_plot_data,
  aes(x = "Birth weight", y = estimate)
) +
  geom_point(size = 3) +
  geom_errorbar(
    aes(ymin = lower, ymax = upper),
    width = 0.15,
    linewidth = 0.8
  ) +
  geom_hline(
    yintercept = reference_mean,
    linetype = "dashed",
    linewidth = 0.8
  ) +
  annotate(
    "text",
    x = 1.18,
    y = reference_mean + 35,
    label = "H0 reference = 3200 g",
    hjust = 0,
    size = 3.5
  ) +
  labs(
    title = "Sample mean and 95% confidence interval",
    subtitle = paste0(
      "One-sample t test: p = ",
      format(round(test_summary$p_value, 3), nsmall = 3)
    ),
    x = NULL,
    y = "Birth weight (g)",
    caption = "Point = sample mean; error bar = 95% CI; dashed line = null reference."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity03_one_sample_t_test/outputs/mean_ci_vs_reference.png",
  p_ci,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 9 — EFFECT SIZE EXTENSION
# ------------------------------------------------------------
#
# Cohen's d for a one-sample comparison:
# d = (xbar - mu0) / s
#
# This describes the observed standardized difference. It is not
# part of the p-value decision rule, but adds magnitude context.

cohens_d <- (
  descriptive$mean_g - reference_mean
) / descriptive$sd_g

effect_size <- tibble(
  mean_difference_g = descriptive$mean_g - reference_mean,
  sample_sd_g = descriptive$sd_g,
  cohens_d = cohens_d
)

cat("\n============================================================\n")
cat("STEP 9 — EFFECT SIZE EXTENSION\n")
cat("============================================================\n")
print(
  effect_size |>
    mutate(across(where(is.numeric), ~ round(.x, 4)))
)

cat("\nWhy include effect size?\n")
cat("Statistical significance and magnitude are different questions.\n")

# ------------------------------------------------------------
# STEP 10 — SAVE OUTPUTS
# ------------------------------------------------------------

write_csv(
  newborns,
  "practice/manual_attempts/module3_lesson1/activity03_one_sample_t_test/outputs/newborn_birth_weights.csv"
)

write_csv(
  test_summary,
  "practice/manual_attempts/module3_lesson1/activity03_one_sample_t_test/outputs/one_sample_t_test_summary.csv"
)

write_csv(
  ci_logic,
  "practice/manual_attempts/module3_lesson1/activity03_one_sample_t_test/outputs/ci_hypothesis_test_connection.csv"
)

write_csv(
  effect_size,
  "practice/manual_attempts/module3_lesson1/activity03_one_sample_t_test/outputs/effect_size.csv"
)

# ------------------------------------------------------------
# STEP 11 — VALIDATION
# ------------------------------------------------------------

stopifnot(length(birth_weight_g) == 20)
stopifnot(degrees_freedom == 19)

stopifnot(
  abs(
    manual_t - unname(test$statistic)
  ) < 1e-10
)

stopifnot(test$p.value >= 0 && test$p.value <= 1)

# This dataset should reproduce the official example's
# non-significant two-sided result.
stopifnot(test$p.value > 0.05)
stopifnot(reference_inside_ci)

required_figures <- c(
  "practice/manual_attempts/module3_lesson1/activity03_one_sample_t_test/outputs/qq_birth_weight.png",
  "practice/manual_attempts/module3_lesson1/activity03_one_sample_t_test/outputs/mean_ci_vs_reference.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n============================================================\n")
cat("✅ M3 LESSON 1 · ACTIVITY 3 PASSED\n")
cat("============================================================\n")
cat("Observed result:\n")
cat("  mean =", round(test_summary$sample_mean_g, 1), "g\n")
cat("  t =", round(test_summary$t_statistic, 3), "\n")
cat("  df =", test_summary$df, "\n")
cat("  p =", round(test_summary$p_value, 4), "\n")
cat("\n")
cat("Decision: do not reject H0 at alpha = 0.05.\n")
cat("Interpretation: insufficient evidence that the population\n")
cat("mean differs from 3200 g.\n")
