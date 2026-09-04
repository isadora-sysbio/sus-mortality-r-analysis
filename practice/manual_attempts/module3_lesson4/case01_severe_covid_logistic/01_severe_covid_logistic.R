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

set.seed(2020)
n_covid <- 500

dados_covid <- tibble(
  id = 1:n_covid,
  idade = round(pmin(pmax(rnorm(n_covid, 50, 18), 18), 95)),
  sexo = sample(c("Feminino", "Masculino"), n_covid, replace = TRUE),
  diabetes = sample(c("Não", "Sim"), n_covid, replace = TRUE, prob = c(0.85, 0.15)),
  hipertensao = sample(c("Não", "Sim"), n_covid, replace = TRUE, prob = c(0.70, 0.30)),
  obesidade = sample(c("Não", "Sim"), n_covid, replace = TRUE, prob = c(0.75, 0.25))
) |>
  mutate(
    sexo = factor(sexo, levels = c("Feminino", "Masculino")),
    diabetes = factor(diabetes, levels = c("Não", "Sim")),
    hipertensao = factor(hipertensao, levels = c("Não", "Sim")),
    obesidade = factor(obesidade, levels = c("Não", "Sim")),
    prob_grave = plogis(
      -3 +
        0.04 * idade +
        0.3 * (sexo == "Masculino") +
        0.8 * (diabetes == "Sim") +
        0.5 * (hipertensao == "Sim") +
        0.6 * (obesidade == "Sim")
    ),
    caso_grave = rbinom(n_covid, 1, prob_grave)
  )

cat("\n============================================================\n")
cat("CASE 1 — SEVERE COVID-19 RISK FACTORS\n")
cat("============================================================\n")

severity_counts <- dados_covid |>
  count(caso_grave, name = "n") |>
  mutate(percent = 100 * n / sum(n))

descriptive <- dados_covid |>
  group_by(caso_grave) |>
  summarise(
    n = n(),
    idade_media = mean(idade),
    prop_masculino = 100 * mean(sexo == "Masculino"),
    prop_diabetes = 100 * mean(diabetes == "Sim"),
    prop_hipertensao = 100 * mean(hipertensao == "Sim"),
    prop_obesidade = 100 * mean(obesidade == "Sim"),
    .groups = "drop"
  )

cat("\nSeverity counts:\n")
print(severity_counts)

cat("\nDescriptive comparison:\n")
print(
  descriptive |>
    mutate(across(where(is.numeric), ~ round(.x, 2)))
)

modelo_covid <- glm(
  caso_grave ~ idade + sexo + diabetes + hipertensao + obesidade,
  data = dados_covid,
  family = binomial
)

cat("\nLogistic model:\n")
print(summary(modelo_covid))

# Wald ORs are fast, deterministic, and transparent.
coef_raw <- broom::tidy(modelo_covid)

resultados_or <- coef_raw |>
  mutate(
    estimate_or = exp(estimate),
    conf_low = exp(estimate - 1.96 * std.error),
    conf_high = exp(estimate + 1.96 * std.error)
  ) |>
  transmute(
    term,
    odds_ratio = estimate_or,
    conf_low,
    conf_high,
    p_value = p.value
  )

cat("\nOdds ratios:\n")
print(
  resultados_or |>
    mutate(across(where(is.numeric), ~ round(.x, 4)))
)

dados_forest <- resultados_or |>
  filter(term != "(Intercept)") |>
  mutate(
    variable = case_when(
      term == "idade" ~ "Age (per year)",
      term == "sexoMasculino" ~ "Male sex",
      term == "diabetesSim" ~ "Diabetes",
      term == "hipertensaoSim" ~ "Hypertension",
      term == "obesidadeSim" ~ "Obesity",
      TRUE ~ term
    )
  )

p_forest <- ggplot(
  dados_forest,
  aes(
    x = reorder(variable, odds_ratio),
    y = odds_ratio,
    ymin = conf_low,
    ymax = conf_high
  )
) +
  geom_hline(yintercept = 1, linetype = "dashed") +
  geom_pointrange() +
  coord_flip() +
  labs(
    title = "Factors associated with severe COVID-19",
    subtitle = "Adjusted odds ratios with 95% Wald confidence intervals",
    x = NULL,
    y = "Odds ratio",
    caption = "Synthetic data generated from the official Fiocruz integrated case."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson4/case01_severe_covid_logistic/outputs/covid_risk_forest_plot.png",
  p_forest,
  width = 8.5,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

manager_summary <- dados_forest |>
  mutate(
    direction = case_when(
      odds_ratio > 1 ~ "Higher modeled odds",
      odds_ratio < 1 ~ "Lower modeled odds",
      TRUE ~ "No modeled change"
    ),
    statistically_significant_0_05 =
      p_value < 0.05
  ) |>
  select(
    variable,
    odds_ratio,
    conf_low,
    conf_high,
    p_value,
    direction,
    statistically_significant_0_05
  )

write_csv(
  dados_covid,
  "practice/manual_attempts/module3_lesson4/case01_severe_covid_logistic/outputs/simulated_covid_data.csv"
)
write_csv(
  severity_counts,
  "practice/manual_attempts/module3_lesson4/case01_severe_covid_logistic/outputs/severity_counts.csv"
)
write_csv(
  descriptive,
  "practice/manual_attempts/module3_lesson4/case01_severe_covid_logistic/outputs/descriptive_by_severity.csv"
)
write_csv(
  resultados_or,
  "practice/manual_attempts/module3_lesson4/case01_severe_covid_logistic/outputs/logistic_odds_ratios.csv"
)
write_csv(
  manager_summary,
  "practice/manual_attempts/module3_lesson4/case01_severe_covid_logistic/outputs/manager_summary.csv"
)

stopifnot(nrow(dados_covid) == 500)
stopifnot(all(dados_covid$caso_grave %in% c(0, 1)))
stopifnot(length(unique(dados_covid$caso_grave)) == 2)
stopifnot(isTRUE(modelo_covid$converged))
stopifnot(all(resultados_or$odds_ratio > 0))
stopifnot(resultados_or$odds_ratio[resultados_or$term == "idade"] > 1)
stopifnot(file.exists(
  "practice/manual_attempts/module3_lesson4/case01_severe_covid_logistic/outputs/covid_risk_forest_plot.png"
))

cat("\n✅ M3 LESSON 4 · CASE 1 PASSED\n")
cat("Severe cases:", sum(dados_covid$caso_grave), "of", n_covid, "\n")
cat("Age OR:", round(resultados_or$odds_ratio[resultados_or$term == "idade"], 3), "\n")
