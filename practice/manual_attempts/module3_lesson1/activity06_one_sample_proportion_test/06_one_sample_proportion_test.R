# ============================================================
# FIOCRUZ — Module 3, Lesson 1, Activity 6
#
# Question:
# Does hypertension prevalence in a sample of 200 adults differ
# from a reference prevalence of 25%?
#
# Official course data:
#   n = 200 adults
#   x = 60 hypertensive adults
#   observed proportion = 60 / 200 = 0.30
#   reference proportion = 0.25
#
# H0: p = 0.25
# H1: p != 0.25
#
# Official R function:
#   prop.test(x = 60, n = 200, p = 0.25)
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
# STEP 1 — COURSE DATA
# ------------------------------------------------------------

x <- 60
n <- 200
reference_p <- 0.25
alpha <- 0.05

sample_p <- x / n

cat("\n============================================================\n")
cat("STEP 1 — DATA + RESEARCH QUESTION\n")
cat("============================================================\n")
cat("Adults in sample:", n, "\n")
cat("Adults with hypertension:", x, "\n")
cat("Observed prevalence:", round(100 * sample_p, 1), "%\n")
cat("Reference prevalence:", round(100 * reference_p, 1), "%\n")

cat("\nQuestion:\n")
cat("Does the population prevalence differ from 25%?\n")

cat("\nHypotheses:\n")
cat("H0: p = 0.25\n")
cat("H1: p != 0.25\n")

# ------------------------------------------------------------
# STEP 2 — RUN THE OFFICIAL prop.test()
# ------------------------------------------------------------
#
# R's prop.test() performs an approximate chi-squared test for
# proportions. With one proportion, it tests that proportion
# against the specified reference value.
#
# By default, R applies Yates' continuity correction when it is
# applicable.

prop_result <- prop.test(
  x = x,
  n = n,
  p = reference_p,
  alternative = "two.sided",
  conf.level = 0.95,
  correct = TRUE
)

cat("\n============================================================\n")
cat("STEP 2 — prop.test() OUTPUT\n")
cat("============================================================\n")
print(prop_result)

prop_summary <- tibble(
  sample_size = n,
  hypertensive = x,
  observed_proportion = unname(prop_result$estimate),
  reference_proportion = reference_p,
  absolute_difference = unname(prop_result$estimate) - reference_p,
  chi_squared = unname(prop_result$statistic),
  df = unname(prop_result$parameter),
  p_value = prop_result$p.value,
  ci_lower = prop_result$conf.int[1],
  ci_upper = prop_result$conf.int[2],
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
      "Evidence that hypertension prevalence differs from 25%",
      "Insufficient evidence that hypertension prevalence differs from 25%"
    )
  )

cat("\n============================================================\n")
cat("STEP 3 — PLAIN-LANGUAGE RESULT\n")
cat("============================================================\n")
print(
  prop_summary |>
    mutate(
      across(
        c(
          observed_proportion,
          reference_proportion,
          absolute_difference,
          chi_squared,
          p_value,
          ci_lower,
          ci_upper
        ),
        ~ round(.x, 4)
      )
    )
)

cat("\nObserved prevalence:", round(100 * sample_p, 1), "%\n")
cat("Absolute difference from reference:", round(100 * (sample_p - reference_p), 1), "percentage points\n")
cat("p-value:", round(prop_result$p.value, 4), "\n")
cat(
  "95% CI for prevalence:",
  paste0(
    "[",
    round(100 * prop_result$conf.int[1], 1),
    "%, ",
    round(100 * prop_result$conf.int[2], 1),
    "%]"
  ),
  "\n"
)

if (prop_result$p.value < alpha) {
  cat("\nConclusion: reject H0.\n")
  cat("The sample provides evidence that prevalence differs from 25%.\n")
} else {
  cat("\nConclusion: DO NOT reject H0.\n")
  cat("The sample does not provide sufficient evidence that prevalence\n")
  cat("differs from 25%.\n")
  cat("\nImportant: this does NOT prove that the true prevalence is exactly 25%.\n")
}

# ------------------------------------------------------------
# STEP 4 — CONFIDENCE-INTERVAL CONNECTION
# ------------------------------------------------------------

reference_inside_ci <- (
  prop_result$conf.int[1] <= reference_p &&
  prop_result$conf.int[2] >= reference_p
)

ci_logic <- tibble(
  reference_proportion = reference_p,
  ci_lower = prop_result$conf.int[1],
  ci_upper = prop_result$conf.int[2],
  reference_inside_95_ci = reference_inside_ci,
  p_value = prop_result$p.value,
  reject_at_0_05 = prop_result$p.value < alpha
)

cat("\n============================================================\n")
cat("STEP 4 — CI CONNECTION\n")
cat("============================================================\n")
print(
  ci_logic |>
    mutate(
      across(
        c(
          reference_proportion,
          ci_lower,
          ci_upper,
          p_value
        ),
        ~ round(.x, 4)
      )
    )
)

cat("\nFor this two-sided 5% test:\n")
cat("- reference outside the compatible 95% interval -> reject H0\n")
cat("- reference inside the interval -> do not reject H0\n")

# ------------------------------------------------------------
# STEP 5 — VISUALIZE ESTIMATE + 95% CI
# ------------------------------------------------------------

plot_data <- tibble(
  estimate = sample_p,
  lower = prop_result$conf.int[1],
  upper = prop_result$conf.int[2]
)

p_ci <- ggplot(
  plot_data,
  aes(x = "Hypertension prevalence", y = estimate)
) +
  geom_point(size = 3.2) +
  geom_errorbar(
    aes(
      ymin = lower,
      ymax = upper
    ),
    width = 0.12,
    linewidth = 0.8
  ) +
  geom_hline(
    yintercept = reference_p,
    linetype = "dashed",
    linewidth = 0.8
  ) +
  annotate(
    "text",
    x = 1.12,
    y = reference_p + 0.01,
    label = "H0 reference = 25%",
    hjust = 0,
    size = 3.5
  ) +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(0.15, 0.40)
  ) +
  labs(
    title = "Estimated hypertension prevalence",
    subtitle = paste0(
      "Observed = ",
      round(100 * sample_p, 1),
      "%; 95% CI shown"
    ),
    x = NULL,
    y = "Prevalence",
    caption = "Dashed line = 25% reference prevalence."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity06_one_sample_proportion_test/outputs/prevalence_ci_vs_reference.png",
  p_ci,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 6 — CONTINUITY CORRECTION EXTENSION
# ------------------------------------------------------------
#
# The official command uses R's default correct = TRUE.
# We compare it with correct = FALSE so the student can see
# that this implementation detail changes the p-value slightly.

prop_no_correction <- prop.test(
  x = x,
  n = n,
  p = reference_p,
  alternative = "two.sided",
  conf.level = 0.95,
  correct = FALSE
)

correction_comparison <- tibble(
  method = c(
    "prop.test() with continuity correction",
    "prop.test() without continuity correction"
  ),
  correction = c(TRUE, FALSE),
  chi_squared = c(
    unname(prop_result$statistic),
    unname(prop_no_correction$statistic)
  ),
  p_value = c(
    prop_result$p.value,
    prop_no_correction$p.value
  )
)

cat("\n============================================================\n")
cat("STEP 6 — CONTINUITY CORRECTION EXTENSION\n")
cat("============================================================\n")
print(
  correction_comparison |>
    mutate(
      across(
        c(chi_squared, p_value),
        ~ round(.x, 4)
      )
    )
)

cat("\nThe official course command uses R's default correction.\n")
cat("The correction makes the approximation slightly more conservative here.\n")

# ------------------------------------------------------------
# STEP 7 — EXACT BINOMIAL TEST EXTENSION
# ------------------------------------------------------------
#
# binom.test() gives an exact binomial test and an exact
# confidence interval. This is an extension, not a replacement
# for the course's prop.test() activity.

exact_result <- binom.test(
  x = x,
  n = n,
  p = reference_p,
  alternative = "two.sided",
  conf.level = 0.95
)

exact_summary <- tibble(
  method = "Exact binomial test",
  observed_proportion = x / n,
  reference_proportion = reference_p,
  p_value = exact_result$p.value,
  ci_lower = exact_result$conf.int[1],
  ci_upper = exact_result$conf.int[2]
)

cat("\n============================================================\n")
cat("STEP 7 — EXACT BINOMIAL EXTENSION\n")
cat("============================================================\n")
print(
  exact_summary |>
    mutate(
      across(
        where(is.numeric),
        ~ round(.x, 4)
      )
    )
)

cat("\nMain point:\n")
cat("Approximate and exact procedures are related but not identical.\n")
cat("The official Fiocruz exercise is prop.test(); binom.test() is included\n")
cat("only as an analytical extension.\n")

# ------------------------------------------------------------
# STEP 8 — EFFECT SIZE / PRACTICAL MAGNITUDE
# ------------------------------------------------------------

magnitude <- tibble(
  observed_prevalence_percent = 100 * sample_p,
  reference_prevalence_percent = 100 * reference_p,
  absolute_difference_percentage_points =
    100 * (sample_p - reference_p),
  prevalence_ratio =
    sample_p / reference_p
)

cat("\n============================================================\n")
cat("STEP 8 — MAGNITUDE CONTEXT\n")
cat("============================================================\n")
print(
  magnitude |>
    mutate(across(where(is.numeric), ~ round(.x, 3)))
)

cat("\nA p-value is not the magnitude of the prevalence difference.\n")
cat("Here the sample is 5 percentage points above the reference,\n")
cat("which is a separate descriptive fact from statistical significance.\n")

# ------------------------------------------------------------
# STEP 9 — SAVE OUTPUTS
# ------------------------------------------------------------

write_csv(
  prop_summary,
  "practice/manual_attempts/module3_lesson1/activity06_one_sample_proportion_test/outputs/proportion_test_summary.csv"
)

write_csv(
  ci_logic,
  "practice/manual_attempts/module3_lesson1/activity06_one_sample_proportion_test/outputs/ci_hypothesis_connection.csv"
)

write_csv(
  correction_comparison,
  "practice/manual_attempts/module3_lesson1/activity06_one_sample_proportion_test/outputs/continuity_correction_comparison.csv"
)

write_csv(
  exact_summary,
  "practice/manual_attempts/module3_lesson1/activity06_one_sample_proportion_test/outputs/exact_binomial_extension.csv"
)

write_csv(
  magnitude,
  "practice/manual_attempts/module3_lesson1/activity06_one_sample_proportion_test/outputs/prevalence_magnitude.csv"
)

# ------------------------------------------------------------
# STEP 10 — VALIDATION
# ------------------------------------------------------------

stopifnot(x == 60)
stopifnot(n == 200)
stopifnot(abs(sample_p - 0.30) < 1e-12)

stopifnot(
  prop_result$p.value >= 0,
  prop_result$p.value <= 1
)

# Official example should be non-significant at alpha = 0.05.
stopifnot(prop_result$p.value > 0.05)
stopifnot(reference_inside_ci)

# Exact extension should lead to the same reject/do-not-reject
# decision at alpha = 0.05.
stopifnot(exact_result$p.value > 0.05)

stopifnot(file.exists(
  "practice/manual_attempts/module3_lesson1/activity06_one_sample_proportion_test/outputs/prevalence_ci_vs_reference.png"
))

cat("\n============================================================\n")
cat("✅ M3 LESSON 1 · ACTIVITY 6 PASSED\n")
cat("============================================================\n")
cat("Observed prevalence:", round(100 * sample_p, 1), "%\n")
cat("Reference prevalence:", round(100 * reference_p, 1), "%\n")
cat("prop.test p-value:", round(prop_result$p.value, 4), "\n")
cat("\n")
cat("Decision: do not reject H0 at alpha = 0.05.\n")
cat("Interpretation: insufficient evidence that prevalence differs from 25%.\n")
cat("\n")
cat("You practiced:\n")
cat("  • sample proportions\n")
cat("  • H0: p = p0\n")
cat("  • prop.test()\n")
cat("  • chi-squared statistic\n")
cat("  • p-value interpretation\n")
cat("  • CI connection\n")
cat("  • continuity correction\n")
cat("  • exact binomial test as an extension\n")
