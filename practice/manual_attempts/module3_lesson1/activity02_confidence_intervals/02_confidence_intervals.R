# ============================================================
# FIOCRUZ — Module 3, Lesson 1, Activity 2
#
# Goal:
# Construct 95% confidence intervals for 500 repeated samples
# and observe how often they contain the true population mean.
#
# This follows the course's introductory case of a Normal
# population with KNOWN population variance, using:
#
#   xbar ± z_(alpha/2) * sigma / sqrt(n)
#
# The course emphasizes the repeated-sampling interpretation:
# across many repeated samples, about 95% of 95% CIs should
# contain the true population mean.
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

set.seed(20260904)

# ------------------------------------------------------------
# STEP 1 — DEFINE THE POPULATION + CONFIDENCE LEVEL
# ------------------------------------------------------------
#
# We use a Normal population to match the course's introductory
# derivation for a mean with known population variance.
#
# mu = 26 and sigma = 4 are chosen to keep the BMI-style scale
# used in the lesson while making the simulation fully synthetic.

population_mean <- 26
population_sd <- 4
sample_size <- 100
repetitions <- 500
confidence_level <- 0.95

alpha <- 1 - confidence_level

z_critical <- qnorm(
  1 - alpha / 2
)

theoretical_se <- population_sd / sqrt(sample_size)

cat("\n============================================================\n")
cat("STEP 1 — SETUP\n")
cat("============================================================\n")
cat("True population mean (mu):", population_mean, "\n")
cat("Known population SD (sigma):", population_sd, "\n")
cat("Sample size per repetition (n):", sample_size, "\n")
cat("Repeated samples:", repetitions, "\n")
cat("Confidence level:", 100 * confidence_level, "%\n")
cat("z critical:", round(z_critical, 4), "\n")
cat("Theoretical SE:", round(theoretical_se, 4), "\n")

cat("\nCourse connection:\n")
cat("For a 95% CI, qnorm(0.975) gives approximately 1.96.\n")

# ------------------------------------------------------------
# STEP 2 — GENERATE 500 INDEPENDENT SAMPLES
# ------------------------------------------------------------

draws <- matrix(
  rnorm(
    n = repetitions * sample_size,
    mean = population_mean,
    sd = population_sd
  ),
  nrow = repetitions,
  ncol = sample_size
)

sample_means <- rowMeans(draws)

cat("\n============================================================\n")
cat("STEP 2 — 500 SAMPLE MEANS\n")
cat("============================================================\n")
cat("Mean of the 500 sample means:", round(mean(sample_means), 3), "\n")
cat("SD of the 500 sample means:", round(sd(sample_means), 3), "\n")
cat("Theoretical SE:", round(theoretical_se, 3), "\n")

# ------------------------------------------------------------
# STEP 3 — CONSTRUCT 95% CONFIDENCE INTERVALS
# ------------------------------------------------------------

margin_of_error <- z_critical * theoretical_se

intervals <- tibble(
  repetition = seq_len(repetitions),
  sample_mean = sample_means,
  lower = sample_mean - margin_of_error,
  upper = sample_mean + margin_of_error
) |>
  mutate(
    contains_true_mean =
      lower <= population_mean &
      upper >= population_mean,
    status = if_else(
      contains_true_mean,
      "Contains true mean",
      "Misses true mean"
    )
  )

cat("\n============================================================\n")
cat("STEP 3 — FIRST 10 CONFIDENCE INTERVALS\n")
cat("============================================================\n")
print(
  intervals |>
    slice_head(n = 10)
)

cat("\nFormula used:\n")
cat("  xbar ± z * sigma/sqrt(n)\n")
cat("\nMargin of error:", round(margin_of_error, 3), "\n")
cat("CI width:", round(2 * margin_of_error, 3), "\n")

# ------------------------------------------------------------
# STEP 4 — COVERAGE
# ------------------------------------------------------------

coverage_count <- sum(intervals$contains_true_mean)
miss_count <- repetitions - coverage_count
coverage_percent <- 100 * mean(intervals$contains_true_mean)

coverage_summary <- tibble(
  repetitions = repetitions,
  confidence_level_percent = 100 * confidence_level,
  intervals_containing_mu = coverage_count,
  intervals_missing_mu = miss_count,
  observed_coverage_percent = round(coverage_percent, 1),
  true_mu = population_mean,
  z_critical = round(z_critical, 4),
  theoretical_se = round(theoretical_se, 4),
  margin_of_error = round(margin_of_error, 4)
)

cat("\n============================================================\n")
cat("STEP 4 — COVERAGE RESULT\n")
cat("============================================================\n")
print(coverage_summary)

cat("\nInterpretation:\n")
cat(
  coverage_count,
  "of",
  repetitions,
  "intervals contained the true mean.\n"
)
cat(
  "Observed coverage:",
  round(coverage_percent, 1),
  "%\n"
)

cat("\nIMPORTANT INTERPRETATION:\n")
cat("A 95% confidence procedure does NOT mean there is a 95%\n")
cat("probability that the already-calculated fixed interval contains mu.\n")
cat("It means that, under repeated sampling, about 95% of intervals\n")
cat("constructed by this procedure contain the true parameter.\n")

# ------------------------------------------------------------
# STEP 5 — VISUALIZE ALL 500 INTERVALS
# ------------------------------------------------------------

p_all <- ggplot(
  intervals,
  aes(
    x = repetition,
    ymin = lower,
    ymax = upper,
    color = status
  )
) +
  geom_linerange(alpha = 0.7) +
  geom_hline(
    yintercept = population_mean,
    linetype = "dashed",
    linewidth = 0.8
  ) +
  labs(
    title = "Coverage of 500 simulated 95% confidence intervals",
    subtitle = paste0(
      round(coverage_percent, 1),
      "% contained the true population mean (mu = ",
      population_mean,
      ")"
    ),
    x = "Repeated sample",
    y = "95% confidence interval for the population mean",
    color = "Interval result",
    caption = "Synthetic Normal-population simulation with known sigma; fixed random seed."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity02_confidence_intervals/outputs/coverage_500_intervals.png",
  p_all,
  width = 11,
  height = 6,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 6 — ZOOM TO FIRST 100, LIKE THE COURSE ILLUSTRATION
# ------------------------------------------------------------

first_100 <- intervals |>
  slice_head(n = 100)

p_100 <- ggplot(
  first_100,
  aes(
    x = repetition,
    ymin = lower,
    ymax = upper,
    color = status
  )
) +
  geom_linerange(linewidth = 0.65) +
  geom_point(
    aes(y = sample_mean),
    size = 1.1
  ) +
  geom_hline(
    yintercept = population_mean,
    linetype = "dashed",
    linewidth = 0.8
  ) +
  labs(
    title = "First 100 simulated confidence intervals",
    subtitle = "Intervals crossing the horizontal line contain the true mean",
    x = "Repeated sample",
    y = "95% confidence interval",
    color = "Interval result",
    caption = "Synthetic Normal-population simulation with known sigma."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity02_confidence_intervals/outputs/coverage_first_100_intervals.png",
  p_100,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 7 — SAMPLE-MEAN DISTRIBUTION
# ------------------------------------------------------------

p_means <- ggplot(
  intervals,
  aes(x = sample_mean)
) +
  geom_histogram(bins = 30) +
  geom_vline(
    xintercept = population_mean,
    linetype = "dashed",
    linewidth = 0.8
  ) +
  labs(
    title = "Sampling distribution of the mean",
    subtitle = "500 sample means from repeated samples of n = 100",
    x = "Sample mean",
    y = "Number of repeated samples",
    caption = "Dashed line = true population mean."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity02_confidence_intervals/outputs/sampling_distribution_means.png",
  p_means,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 8 — SAVE TABLES
# ------------------------------------------------------------

write_csv(
  intervals,
  "practice/manual_attempts/module3_lesson1/activity02_confidence_intervals/outputs/confidence_intervals_500.csv"
)

write_csv(
  coverage_summary,
  "practice/manual_attempts/module3_lesson1/activity02_confidence_intervals/outputs/coverage_summary.csv"
)

# ------------------------------------------------------------
# STEP 9 — VALIDATION
# ------------------------------------------------------------

stopifnot(nrow(intervals) == 500)
stopifnot(all(intervals$lower < intervals$upper))

stopifnot(
  abs(
    z_critical - 1.959964
  ) < 0.001
)

# With 500 repeated 95% intervals, observed coverage fluctuates.
# This broad range catches a broken simulation without demanding
# that random coverage be exactly 95%.
observed_coverage <- mean(intervals$contains_true_mean)

stopifnot(
  observed_coverage > 0.90,
  observed_coverage < 0.99
)

stopifnot(
  abs(
    sd(sample_means) - theoretical_se
  ) / theoretical_se < 0.20
)

stopifnot(coverage_count > 0)
stopifnot(miss_count > 0)

required_figures <- c(
  "practice/manual_attempts/module3_lesson1/activity02_confidence_intervals/outputs/coverage_500_intervals.png",
  "practice/manual_attempts/module3_lesson1/activity02_confidence_intervals/outputs/coverage_first_100_intervals.png",
  "practice/manual_attempts/module3_lesson1/activity02_confidence_intervals/outputs/sampling_distribution_means.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n============================================================\n")
cat("✅ M3 LESSON 1 · ACTIVITY 2 PASSED\n")
cat("============================================================\n")
cat("500 confidence intervals constructed.\n")
cat("Observed 95% CI coverage:", round(100 * observed_coverage, 1), "%\n")
cat("\nYou demonstrated:\n")
cat("  • qnorm() and z = 1.96\n")
cat("  • standard error of a mean\n")
cat("  • margin of error\n")
cat("  • repeated-sampling confidence-interval coverage\n")
cat("  • correct interpretation of a 95% confidence procedure\n")
