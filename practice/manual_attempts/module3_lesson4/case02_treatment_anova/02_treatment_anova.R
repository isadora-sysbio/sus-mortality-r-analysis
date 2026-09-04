required <- c("dplyr", "readr", "ggplot2", "tibble", "broom")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  cat("Installing missing packages:", paste(missing, collapse = ", "), "\n")
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
n_por_grupo <- 50

dados_trat <- tibble(
  tratamento = factor(
    rep(c("Placebo", "Droga A", "Droga B"), each = n_por_grupo),
    levels = c("Placebo", "Droga A", "Droga B")
  ),
  pa_basal = round(rnorm(n_por_grupo * 3, 150, 10))
) |>
  mutate(
    reducao = case_when(
      tratamento == "Placebo" ~ rnorm(n(), mean = 2, sd = 5),
      tratamento == "Droga A" ~ rnorm(n(), mean = 15, sd = 6),
      tratamento == "Droga B" ~ rnorm(n(), mean = 20, sd = 7)
    )
  )

cat("\n============================================================\n")
cat("CASE 2 — TREATMENT COMPARISON\n")
cat("============================================================\n")

group_summary <- dados_trat |>
  group_by(tratamento) |>
  summarise(
    n = n(),
    mean_reduction = mean(reducao),
    sd_reduction = sd(reducao),
    minimum = min(reducao),
    maximum = max(reducao),
    .groups = "drop"
  )

cat("\nGroup summary:\n")
print(
  group_summary |>
    mutate(across(where(is.numeric), ~ round(.x, 3)))
)

p_box <- ggplot(
  dados_trat,
  aes(
    x = tratamento,
    y = reducao
  )
) +
  geom_boxplot(outlier.shape = NA, width = 0.55) +
  geom_jitter(width = 0.12, alpha = 0.4, size = 1.6) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "Blood-pressure reduction by treatment",
    subtitle = "After 8 weeks of treatment",
    x = NULL,
    y = "Reduction in blood pressure (mmHg)",
    caption = "Synthetic clinical-trial data from the official Fiocruz integrated case."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson4/case02_treatment_anova/outputs/treatment_bp_reduction_boxplot.png",
  p_box,
  width = 8,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

modelo_anova <- aov(
  reducao ~ tratamento,
  data = dados_trat
)

anova_table <- broom::tidy(modelo_anova)
anova_p <- anova_table$p.value[anova_table$term == "tratamento"]

cat("\nANOVA:\n")
print(summary(modelo_anova))

tukey_raw <- TukeyHSD(modelo_anova, "tratamento")

tukey_table <- as.data.frame(tukey_raw$tratamento) |>
  rownames_to_column("comparison") |>
  as_tibble() |>
  rename(
    mean_difference = diff,
    ci_lower = lwr,
    ci_upper = upr,
    adjusted_p_value = `p adj`
  ) |>
  mutate(
    significant_0_05 = adjusted_p_value < 0.05
  )

cat("\nTukey comparisons:\n")
print(
  tukey_table |>
    mutate(across(where(is.numeric), ~ round(.x, 4)))
)

mod_lm <- lm(
  reducao ~ tratamento,
  data = dados_trat
)

lm_coefficients <- broom::tidy(
  mod_lm,
  conf.int = TRUE
)

p_tukey <- ggplot(
  tukey_table,
  aes(
    x = reorder(comparison, mean_difference),
    y = mean_difference,
    ymin = ci_lower,
    ymax = ci_upper
  )
) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_pointrange() +
  coord_flip() +
  labs(
    title = "Tukey-adjusted treatment comparisons",
    subtitle = "95% confidence intervals for pairwise mean differences",
    x = NULL,
    y = "Difference in BP reduction (mmHg)",
    caption = "Intervals excluding zero indicate adjusted evidence of a pairwise difference."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson4/case02_treatment_anova/outputs/tukey_treatment_differences.png",
  p_tukey,
  width = 8,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

decision_summary <- tukey_table |>
  mutate(
    interpretation = if_else(
      significant_0_05,
      "Evidence of a pairwise mean difference after Tukey adjustment",
      "No sufficient evidence of a pairwise mean difference after Tukey adjustment"
    )
  )

write_csv(
  dados_trat,
  "practice/manual_attempts/module3_lesson4/case02_treatment_anova/outputs/simulated_trial_data.csv"
)
write_csv(
  group_summary,
  "practice/manual_attempts/module3_lesson4/case02_treatment_anova/outputs/group_summary.csv"
)
write_csv(
  anova_table,
  "practice/manual_attempts/module3_lesson4/case02_treatment_anova/outputs/anova_table.csv"
)
write_csv(
  tukey_table,
  "practice/manual_attempts/module3_lesson4/case02_treatment_anova/outputs/tukey_pairwise_comparisons.csv"
)
write_csv(
  lm_coefficients,
  "practice/manual_attempts/module3_lesson4/case02_treatment_anova/outputs/lm_equivalent_coefficients.csv"
)
write_csv(
  decision_summary,
  "practice/manual_attempts/module3_lesson4/case02_treatment_anova/outputs/treatment_decision_summary.csv"
)

stopifnot(nrow(dados_trat) == 150)
stopifnot(all(group_summary$n == 50))
stopifnot(anova_p < 0.05)
stopifnot(sum(tukey_table$significant_0_05) >= 2)

mean_placebo <- group_summary$mean_reduction[group_summary$tratamento == "Placebo"]
mean_a <- group_summary$mean_reduction[group_summary$tratamento == "Droga A"]
mean_b <- group_summary$mean_reduction[group_summary$tratamento == "Droga B"]

stopifnot(mean_a > mean_placebo)
stopifnot(mean_b > mean_placebo)

required_figures <- c(
  "practice/manual_attempts/module3_lesson4/case02_treatment_anova/outputs/treatment_bp_reduction_boxplot.png",
  "practice/manual_attempts/module3_lesson4/case02_treatment_anova/outputs/tukey_treatment_differences.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n✅ M3 LESSON 4 · CASE 2 PASSED\n")
cat("ANOVA p-value:", format.pval(anova_p, digits = 3), "\n")
cat("Significant Tukey pairs:", sum(tukey_table$significant_0_05), "\n")
