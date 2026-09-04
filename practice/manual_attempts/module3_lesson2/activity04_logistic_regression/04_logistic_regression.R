required <- c("dplyr", "readr", "ggplot2", "tibble", "broom")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) install.packages(missing, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(tibble)
  library(broom)
})

set.seed(123)
n_pac <- 100

dados_hiper <- tibble(
  idade = round(runif(n_pac, 30, 70)),
  imc = round(rnorm(n_pac, 26, 4), 1),
  sexo = factor(
    sample(c("Feminino", "Masculino"), n_pac, replace = TRUE),
    levels = c("Feminino", "Masculino")
  )
) |>
  mutate(
    prob_hiper = plogis(
      -8 +
        0.05 * idade +
        0.15 * imc +
        0.3 * (sexo == "Masculino")
    ),
    hipertensao = rbinom(n_pac, 1, prob_hiper)
  )

cat("\n============================================================\n")
cat("ACTIVITY 4 — LOGISTIC REGRESSION\n")
cat("============================================================\n")

cat("\nOutcome counts:\n")
print(table(dados_hiper$hipertensao))

modelo_logistico <- glm(
  hipertensao ~ idade + imc + sexo,
  data = dados_hiper,
  family = binomial(link = "logit")
)

cat("\nModel summary:\n")
print(summary(modelo_logistico))

coef_raw <- tidy(modelo_logistico)

# Wald OR confidence intervals keep the batch fast and deterministic.
or_table <- coef_raw |>
  mutate(
    odds_ratio = exp(estimate),
    conf_low = exp(estimate - 1.96 * std.error),
    conf_high = exp(estimate + 1.96 * std.error)
  ) |>
  select(
    term,
    odds_ratio,
    conf_low,
    conf_high,
    p_value = p.value
  )

cat("\nOdds ratios:\n")
print(
  or_table |>
    mutate(across(where(is.numeric), ~ round(.x, 4)))
)

novo_paciente <- tibble(
  idade = 60,
  imc = 28,
  sexo = factor("Masculino", levels = levels(dados_hiper$sexo))
)

new_patient_probability <- unname(
  predict(
    modelo_logistico,
    newdata = novo_paciente,
    type = "response"
  )
)

prediction_summary <- tibble(
  age = 60,
  bmi = 28,
  sex = "Masculino",
  predicted_probability = new_patient_probability
)

cat("\nNew patient prediction:\n")
print(prediction_summary)

# Predicted probability curves at BMI 28.
prediction_grid <- expand.grid(
  idade = seq(30, 70, by = 1),
  sexo = levels(dados_hiper$sexo)
) |>
  as_tibble() |>
  mutate(
    imc = 28,
    sexo = factor(sexo, levels = levels(dados_hiper$sexo))
  )

link_pred <- predict(
  modelo_logistico,
  newdata = prediction_grid,
  type = "link",
  se.fit = TRUE
)

prediction_grid <- prediction_grid |>
  mutate(
    link = as.numeric(link_pred$fit),
    se_link = as.numeric(link_pred$se.fit),
    probability = plogis(link),
    lower = plogis(link - 1.96 * se_link),
    upper = plogis(link + 1.96 * se_link)
  )

p <- ggplot(
  prediction_grid,
  aes(
    x = idade,
    y = probability,
    linetype = sexo
  )
) +
  geom_ribbon(
    aes(
      ymin = lower,
      ymax = upper,
      group = sexo
    ),
    alpha = 0.12,
    inherit.aes = TRUE
  ) +
  geom_line(linewidth = 0.9) +
  scale_y_continuous(
    labels = function(x) paste0(round(100 * x), "%"),
    limits = c(0, 1)
  ) +
  labs(
    title = "Predicted probability of hypertension",
    subtitle = "Logistic model predictions at BMI = 28",
    x = "Age (years)",
    y = "Predicted probability",
    linetype = "Sex",
    caption = "Synthetic Fiocruz activity data; ribbons show approximate 95% prediction uncertainty."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

ggsave(
  "practice/manual_attempts/module3_lesson2/activity04_logistic_regression/outputs/hypertension_probability_curves.png",
  p, width = 8.5, height = 5.5, dpi = 300, bg = "white"
)

model_fit <- glance(modelo_logistico)

interpretation <- or_table |>
  filter(term != "(Intercept)") |>
  mutate(
    interpretation = case_when(
      term == "idade" ~ "Multiplicative change in odds for each additional year of age, adjusted for BMI and sex",
      term == "imc" ~ "Multiplicative change in odds for each 1-unit increase in BMI, adjusted for age and sex",
      term == "sexoMasculino" ~ "Male-vs-female odds ratio adjusted for age and BMI",
      TRUE ~ "Model term"
    )
  )

write_csv(
  dados_hiper,
  "practice/manual_attempts/module3_lesson2/activity04_logistic_regression/outputs/simulated_hypertension_data.csv"
)
write_csv(
  or_table,
  "practice/manual_attempts/module3_lesson2/activity04_logistic_regression/outputs/odds_ratios.csv"
)
write_csv(
  prediction_summary,
  "practice/manual_attempts/module3_lesson2/activity04_logistic_regression/outputs/new_patient_prediction.csv"
)
write_csv(
  prediction_grid,
  "practice/manual_attempts/module3_lesson2/activity04_logistic_regression/outputs/prediction_curve_data.csv"
)
write_csv(
  model_fit,
  "practice/manual_attempts/module3_lesson2/activity04_logistic_regression/outputs/logistic_model_fit.csv"
)
write_csv(
  interpretation,
  "practice/manual_attempts/module3_lesson2/activity04_logistic_regression/outputs/or_interpretation.csv"
)

# Robust validation.
stopifnot(nrow(dados_hiper) == 100)
stopifnot(all(dados_hiper$hipertensao %in% c(0, 1)))
stopifnot(length(unique(dados_hiper$hipertensao)) == 2)
stopifnot(isTRUE(modelo_logistico$converged))
stopifnot(all(is.finite(coef(modelo_logistico))))
stopifnot(all(or_table$odds_ratio > 0))
stopifnot(new_patient_probability >= 0, new_patient_probability <= 1)

stopifnot(file.exists(
  "practice/manual_attempts/module3_lesson2/activity04_logistic_regression/outputs/hypertension_probability_curves.png"
))

cat("\n✅ M3 LESSON 2 · ACTIVITY 4 PASSED\n")
cat("Predicted probability for male age 60, BMI 28:",
    round(100 * new_patient_probability, 1), "%\n")
