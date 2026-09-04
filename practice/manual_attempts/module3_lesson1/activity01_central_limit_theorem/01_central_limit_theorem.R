# ============================================================
# FIOCRUZ — Module 3, Lesson 1, Activity 1
#
# Goal:
# Simulate the Central Limit Theorem using 500 repeated samples.
#
# We deliberately start from a RIGHT-SKEWED population
# (Exponential distribution), not a Normal population.
#
# We then compare sampling distributions of the mean for:
#   n = 5
#   n = 30
#   n = 100
#
# Main ideas:
#   1. sample means center around the population mean
#   2. their distribution becomes more Normal-looking as n grows
#   3. their spread shrinks approximately as sigma / sqrt(n)
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
# STEP 1 — DEFINE A SKEWED POPULATION
# ------------------------------------------------------------
#
# Exponential(rate = 1/26):
# theoretical mean = 26
# theoretical SD   = 26
#
# This is intentionally NOT Normal.

population_mean <- 26
population_sd <- 26
rate <- 1 / population_mean

population_preview <- rexp(
  n = 100000,
  rate = rate
)

cat("\n============================================================\n")
cat("STEP 1 — ORIGINAL POPULATION\n")
cat("============================================================\n")
cat("Distribution: Exponential (strongly right-skewed)\n")
cat("Theoretical mean:", population_mean, "\n")
cat("Theoretical SD:", population_sd, "\n")
cat("Simulated preview mean:", round(mean(population_preview), 2), "\n")
cat("Simulated preview SD:", round(sd(population_preview), 2), "\n")

# ------------------------------------------------------------
# STEP 2 — ONE SAMPLE IS NOT THE SAMPLING DISTRIBUTION
# ------------------------------------------------------------

one_sample <- rexp(
  n = 30,
  rate = rate
)

cat("\n============================================================\n")
cat("STEP 2 — ONE SAMPLE OF n = 30\n")
cat("============================================================\n")
cat("One sample mean:", round(mean(one_sample), 2), "\n")
cat("\n")
cat("Important:\n")
cat("The Central Limit Theorem is about the DISTRIBUTION OF SAMPLE MEANS\n")
cat("across repeated samples — not about one individual sample becoming Normal.\n")

# ------------------------------------------------------------
# STEP 3 — FUNCTION TO SIMULATE 500 SAMPLE MEANS
# ------------------------------------------------------------

simulate_means <- function(sample_size, repetitions = 500) {

  # Generate repetitions × sample_size independent observations.
  # Each ROW is one simulated sample.
  draws <- matrix(
    rexp(
      n = repetitions * sample_size,
      rate = rate
    ),
    nrow = repetitions,
    ncol = sample_size
  )

  tibble(
    sample_size = sample_size,
    repetition = seq_len(repetitions),
    sample_mean = rowMeans(draws)
  )
}

cat("\n============================================================\n")
cat("STEP 3 — GENERATING 500 SAMPLES FOR EACH n\n")
cat("============================================================\n")

means_n5 <- simulate_means(5)
means_n30 <- simulate_means(30)
means_n100 <- simulate_means(100)

sampling_means <- bind_rows(
  means_n5,
  means_n30,
  means_n100
) |>
  mutate(
    sample_size = factor(
      sample_size,
      levels = c(5, 30, 100),
      labels = c("n = 5", "n = 30", "n = 100")
    )
  )

cat("Created:", nrow(means_n5), "sample means for n = 5\n")
cat("Created:", nrow(means_n30), "sample means for n = 30\n")
cat("Created:", nrow(means_n100), "sample means for n = 100\n")

# ------------------------------------------------------------
# STEP 4 — SUMMARIZE THE SAMPLING DISTRIBUTIONS
# ------------------------------------------------------------

summary_table <- sampling_means |>
  group_by(sample_size) |>
  summarise(
    repetitions = n(),
    mean_of_sample_means = mean(sample_mean),
    empirical_se = sd(sample_mean),
    .groups = "drop"
  ) |>
  mutate(
    n = c(5, 30, 100),
    theoretical_mean = population_mean,
    theoretical_se = population_sd / sqrt(n),
    mean_error = mean_of_sample_means - theoretical_mean,
    se_ratio_empirical_to_theoretical = empirical_se / theoretical_se
  ) |>
  select(
    sample_size,
    n,
    repetitions,
    theoretical_mean,
    mean_of_sample_means,
    mean_error,
    theoretical_se,
    empirical_se,
    se_ratio_empirical_to_theoretical
  )

summary_display <- summary_table |>
  mutate(
    across(
      c(
        theoretical_mean,
        mean_of_sample_means,
        mean_error,
        theoretical_se,
        empirical_se,
        se_ratio_empirical_to_theoretical
      ),
      ~ round(.x, 3)
    )
  )

cat("\n============================================================\n")
cat("STEP 4 — SAMPLING-DISTRIBUTION SUMMARY\n")
cat("============================================================\n")
print(summary_display)

cat("\nWhat should you see?\n")
cat("1. The mean of the 500 sample means stays near 26.\n")
cat("2. The empirical SE decreases as n increases.\n")
cat("3. The empirical SE is close to sigma/sqrt(n).\n")

# ------------------------------------------------------------
# STEP 5 — VISUALIZE THE ORIGINAL SKEWED POPULATION
# ------------------------------------------------------------

population_plot_data <- tibble(
  value = population_preview
)

p_population <- ggplot(
  population_plot_data,
  aes(x = value)
) +
  geom_histogram(
    bins = 60
  ) +
  geom_vline(
    xintercept = population_mean,
    linetype = "dashed",
    linewidth = 0.8
  ) +
  coord_cartesian(xlim = c(0, 140)) +
  labs(
    title = "Original population is strongly right-skewed",
    subtitle = "Exponential distribution with theoretical mean = 26",
    x = "Population value",
    y = "Frequency",
    caption = "Synthetic simulation."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity01_central_limit_theorem/outputs/original_skewed_population.png",
  p_population,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 6 — VISUALIZE THE 500 SAMPLE MEANS
# ------------------------------------------------------------

p_sampling <- ggplot(
  sampling_means,
  aes(x = sample_mean)
) +
  geom_histogram(
    bins = 30
  ) +
  geom_vline(
    xintercept = population_mean,
    linetype = "dashed",
    linewidth = 0.8
  ) +
  facet_wrap(
    ~ sample_size,
    ncol = 1,
    scales = "free_y"
  ) +
  labs(
    title = "Central Limit Theorem in action",
    subtitle = "500 sample means at each sample size from a skewed population",
    x = "Sample mean",
    y = "Number of simulated samples",
    caption = "Dashed line = population mean (26). Synthetic simulation with fixed seed."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold")
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity01_central_limit_theorem/outputs/clt_sampling_distributions.png",
  p_sampling,
  width = 8.5,
  height = 9,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 7 — STANDARD ERROR SHRINKS WITH n
# ------------------------------------------------------------

se_table <- summary_table |>
  select(
    n,
    theoretical_se,
    empirical_se
  ) |>
  tidyr::pivot_longer(
    cols = c(theoretical_se, empirical_se),
    names_to = "se_type",
    values_to = "standard_error"
  )

p_se <- ggplot(
  se_table,
  aes(
    x = n,
    y = standard_error,
    linetype = se_type,
    shape = se_type
  )
) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 3) +
  scale_x_continuous(
    breaks = c(5, 30, 100)
  ) +
  labs(
    title = "Standard error decreases as sample size increases",
    subtitle = "Empirical simulation follows the sigma/sqrt(n) relationship",
    x = "Sample size (n)",
    y = "Standard error of the sample mean",
    linetype = "SE",
    shape = "SE",
    caption = "Synthetic simulation."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson1/activity01_central_limit_theorem/outputs/standard_error_by_sample_size.png",
  p_se,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# STEP 8 — SAVE TABLES
# ------------------------------------------------------------

write_csv(
  sampling_means,
  "practice/manual_attempts/module3_lesson1/activity01_central_limit_theorem/outputs/500_sample_means_by_n.csv"
)

write_csv(
  summary_display,
  "practice/manual_attempts/module3_lesson1/activity01_central_limit_theorem/outputs/clt_summary.csv"
)

# ------------------------------------------------------------
# STEP 9 — VALIDATION
# ------------------------------------------------------------

stopifnot(nrow(means_n5) == 500)
stopifnot(nrow(means_n30) == 500)
stopifnot(nrow(means_n100) == 500)

stopifnot(
  all(
    abs(
      summary_table$mean_of_sample_means -
        population_mean
    ) < 2
  )
)

# Standard error should decrease with n.
stopifnot(
  summary_table$empirical_se[1] >
    summary_table$empirical_se[2]
)

stopifnot(
  summary_table$empirical_se[2] >
    summary_table$empirical_se[3]
)

# Simulation should broadly follow theoretical SE.
#
# With only 500 Monte Carlo repetitions and a strongly skewed
# Exponential population, empirical SE will not equal the
# theoretical value exactly. We therefore validate the expected
# relationship without imposing an unnecessarily brittle cutoff.

relative_se_error <- abs(
  summary_table$empirical_se -
    summary_table$theoretical_se
) / summary_table$theoretical_se

cat("\nRelative empirical-vs-theoretical SE error:\n")
print(
  tibble(
    sample_size = summary_table$sample_size,
    empirical_se = round(summary_table$empirical_se, 3),
    theoretical_se = round(summary_table$theoretical_se, 3),
    relative_error_percent = round(100 * relative_se_error, 1)
  )
)

stopifnot(all(relative_se_error < 0.25))

required_figures <- c(
  "practice/manual_attempts/module3_lesson1/activity01_central_limit_theorem/outputs/original_skewed_population.png",
  "practice/manual_attempts/module3_lesson1/activity01_central_limit_theorem/outputs/clt_sampling_distributions.png",
  "practice/manual_attempts/module3_lesson1/activity01_central_limit_theorem/outputs/standard_error_by_sample_size.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n============================================================\n")
cat("✅ M3 LESSON 1 · ACTIVITY 1 PASSED\n")
cat("============================================================\n")
cat("500 samples simulated at each n.\n")
cat("\n")
cat("You demonstrated:\n")
cat("  • a skewed original population\n")
cat("  • sampling distributions of the mean\n")
cat("  • increasing Normal approximation as n grows\n")
cat("  • sample means centered near the population mean\n")
cat("  • standard error shrinking approximately as sigma/sqrt(n)\n")
