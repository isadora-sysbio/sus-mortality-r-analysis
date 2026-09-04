required <- c(
  "dplyr", "readr", "ggplot2", "tibble", "lme4"
)

missing <- required[
  !vapply(required, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing) > 0) {
  cat("\nInstalling missing R packages:", paste(missing, collapse = ", "), "\n")
  install.packages(missing, repos = "https://cloud.r-project.org")
}

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(tibble)
  library(lme4)
})

# ------------------------------------------------------------
# Official Fiocruz simulation recipe
# ------------------------------------------------------------

set.seed(123)

n_hospitais <- 10
n_pac_por_hosp <- 30

efeito_hospital <- rnorm(
  n_hospitais,
  mean = 0,
  sd = 5
)

dados_multinivel <- tibble(
  hospital_id = rep(
    1:n_hospitais,
    each = n_pac_por_hosp
  ),
  paciente_id = 1:(n_hospitais * n_pac_por_hosp)
) |>
  mutate(
    idade = round(runif(n(), 30, 70)),
    sexo = sample(c("F", "M"), n(), replace = TRUE),
    efeito_hosp = efeito_hospital[hospital_id],
    pa = round(
      100 +
        0.5 * idade +
        efeito_hosp +
        rnorm(n(), 0, 8),
      1
    ),
    hospital_id = factor(hospital_id),
    sexo = factor(sexo, levels = c("F", "M"))
  )

cat("\n============================================================\n")
cat("ACTIVITY 1 — MULTILEVEL MODELS\n")
cat("============================================================\n")

hospital_summary <- dados_multinivel |>
  group_by(hospital_id) |>
  summarise(
    n = n(),
    media_pa = mean(pa),
    dp_pa = sd(pa),
    .groups = "drop"
  )

cat("\nHospital summaries:\n")
print(
  hospital_summary |>
    mutate(across(where(is.numeric), ~ round(.x, 3)))
)

# Ordinary model: ignores hospital grouping.
modelo_comum <- lm(
  pa ~ idade + sexo,
  data = dados_multinivel
)

# Multilevel random-intercept model: recognizes hospital grouping.
modelo_multinivel <- lmer(
  pa ~ idade + sexo + (1 | hospital_id),
  data = dados_multinivel,
  REML = TRUE
)

cat("\nOrdinary linear model:\n")
print(summary(modelo_comum))

cat("\nMultilevel model:\n")
print(summary(modelo_multinivel))

fixed_effects <- tibble(
  term = names(fixef(modelo_multinivel)),
  estimate = unname(fixef(modelo_multinivel))
)

random_effects <- ranef(
  modelo_multinivel,
  condVar = FALSE
)$hospital_id |>
  rownames_to_column("hospital_id") |>
  as_tibble() |>
  rename(random_intercept = `(Intercept)`)

variance_components_raw <- as.data.frame(
  VarCorr(modelo_multinivel)
)

hospital_variance <- variance_components_raw$vcov[
  variance_components_raw$grp == "hospital_id"
][1]

residual_variance <- sigma(modelo_multinivel)^2

icc <- hospital_variance / (
  hospital_variance + residual_variance
)

variance_components <- tibble(
  component = c(
    "Between-hospital variance",
    "Residual within-hospital variance",
    "Intraclass correlation coefficient"
  ),
  estimate = c(
    hospital_variance,
    residual_variance,
    icc
  )
)

cat("\nVariance components + ICC:\n")
print(
  variance_components |>
    mutate(estimate = round(estimate, 4))
)

cat("\nICC interpretation:\n")
cat(
  round(100 * icc, 1),
  "% of modeled residual variance is attributable to between-hospital differences.\n"
)

model_comparison <- tibble(
  model = c(
    "Ordinary LM",
    "Multilevel random-intercept model"
  ),
  age_coefficient = c(
    coef(modelo_comum)[["idade"]],
    fixef(modelo_multinivel)[["idade"]]
  ),
  AIC = c(
    AIC(modelo_comum),
    AIC(modelo_multinivel)
  ),
  BIC = c(
    BIC(modelo_comum),
    BIC(modelo_multinivel)
  )
)

# Hospital mean visualization.
p_means <- ggplot(
  hospital_summary,
  aes(
    x = reorder(hospital_id, media_pa),
    y = media_pa
  )
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Mean systolic blood pressure varies across hospitals",
    subtitle = "Hierarchical data: patients are nested within hospitals",
    x = "Hospital",
    y = "Mean systolic blood pressure",
    caption = "Synthetic data generated from the official Fiocruz Lesson 3 recipe."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson3/activity01_multilevel_models/outputs/mean_bp_by_hospital.png",
  p_means,
  width = 8,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

p_random <- ggplot(
  random_effects,
  aes(
    x = reorder(hospital_id, random_intercept),
    y = random_intercept
  )
) +
  geom_col() +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  coord_flip() +
  labs(
    title = "Estimated hospital random intercepts",
    subtitle = "Positive values indicate hospitals with higher model-adjusted baseline BP",
    x = "Hospital",
    y = "Random-intercept deviation",
    caption = "Random effects from lmer(pa ~ idade + sexo + (1 | hospital_id))."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson3/activity01_multilevel_models/outputs/hospital_random_intercepts.png",
  p_random,
  width = 8,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

write_csv(
  dados_multinivel,
  "practice/manual_attempts/module3_lesson3/activity01_multilevel_models/outputs/multilevel_patient_data.csv"
)

write_csv(
  hospital_summary,
  "practice/manual_attempts/module3_lesson3/activity01_multilevel_models/outputs/hospital_summary.csv"
)

write_csv(
  fixed_effects,
  "practice/manual_attempts/module3_lesson3/activity01_multilevel_models/outputs/fixed_effects.csv"
)

write_csv(
  random_effects,
  "practice/manual_attempts/module3_lesson3/activity01_multilevel_models/outputs/random_intercepts.csv"
)

write_csv(
  variance_components,
  "practice/manual_attempts/module3_lesson3/activity01_multilevel_models/outputs/variance_components_icc.csv"
)

write_csv(
  model_comparison,
  "practice/manual_attempts/module3_lesson3/activity01_multilevel_models/outputs/ordinary_vs_multilevel.csv"
)

# Validation.
stopifnot(nrow(dados_multinivel) == 300)
stopifnot(nlevels(dados_multinivel$hospital_id) == 10)
stopifnot(all(hospital_summary$n == 30))
stopifnot(length(fixef(modelo_multinivel)) == 3)
stopifnot(is.finite(hospital_variance), hospital_variance >= 0)
stopifnot(is.finite(residual_variance), residual_variance > 0)
stopifnot(is.finite(icc), icc >= 0, icc <= 1)
stopifnot(fixef(modelo_multinivel)[["idade"]] > 0)

required_figures <- c(
  "practice/manual_attempts/module3_lesson3/activity01_multilevel_models/outputs/mean_bp_by_hospital.png",
  "practice/manual_attempts/module3_lesson3/activity01_multilevel_models/outputs/hospital_random_intercepts.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n✅ M3 LESSON 3 · ACTIVITY 1 PASSED\n")
cat("Estimated age effect:",
    round(fixef(modelo_multinivel)[["idade"]], 3),
    "BP units/year\n")
cat("ICC:", round(icc, 3), "\n")
