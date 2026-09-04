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

set.seed(42)
n <- 30

pasis <- tibble(
  idade = round(runif(n, min = 25, max = 75)),
  pa = round(100 + 0.8 * idade + rnorm(n, 0, 10)),
  sexo = if_else(runif(n) >= 0.5, "Feminino", "Masculino")
) |>
  mutate(
    sexo = factor(sexo, levels = c("Feminino", "Masculino"))
  )

cat("\n============================================================\n")
cat("ACTIVITY 3 — MULTIPLE LINEAR REGRESSION\n")
cat("============================================================\n")

modelo_multiplo <- lm(pa ~ idade + sexo, data = pasis)
modelo_interacao <- lm(pa ~ idade * sexo, data = pasis)

cat("\nAdditive model: pa ~ idade + sexo\n")
print(summary(modelo_multiplo))

cat("\nInteraction model: pa ~ idade * sexo\n")
print(summary(modelo_interacao))

coef_additive <- tidy(modelo_multiplo, conf.int = TRUE)
coef_interaction <- tidy(modelo_interacao, conf.int = TRUE)
fit_additive <- glance(modelo_multiplo)
fit_interaction <- glance(modelo_interacao)

nested_comparison <- tidy(
  anova(modelo_multiplo, modelo_interacao)
)

# Predictions from the ADDITIVE model guarantee the parallel-line
# interpretation described conceptually by the course.
prediction_grid <- expand.grid(
  idade = seq(min(pasis$idade), max(pasis$idade), length.out = 100),
  sexo = levels(pasis$sexo)
) |>
  as_tibble() |>
  mutate(
    sexo = factor(sexo, levels = levels(pasis$sexo))
  )

prediction_grid$predicted_pa <- predict(
  modelo_multiplo,
  newdata = prediction_grid
)

p_additive <- ggplot(pasis, aes(x = idade, y = pa, shape = sexo)) +
  geom_point(size = 2.7, alpha = 0.7) +
  geom_line(
    data = prediction_grid,
    aes(x = idade, y = predicted_pa, linetype = sexo),
    linewidth = 0.9
  ) +
  labs(
    title = "Multiple linear regression: SBP ~ age + sex",
    subtitle = "Additive model: the age slope is constrained to be equal across sex groups",
    x = "Age (years)",
    y = "Systolic blood pressure (mmHg)",
    shape = "Sex",
    linetype = "Sex",
    caption = "Predicted lines come from the fitted additive model."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

ggsave(
  "practice/manual_attempts/module3_lesson2/activity03_multiple_linear_regression/outputs/additive_parallel_lines.png",
  p_additive, width = 8.5, height = 5.5, dpi = 300, bg = "white"
)

interaction_grid <- expand.grid(
  idade = seq(min(pasis$idade), max(pasis$idade), length.out = 100),
  sexo = levels(pasis$sexo)
) |>
  as_tibble() |>
  mutate(
    sexo = factor(sexo, levels = levels(pasis$sexo))
  )

interaction_grid$predicted_pa <- predict(
  modelo_interacao,
  newdata = interaction_grid
)

p_interaction <- ggplot(pasis, aes(x = idade, y = pa, shape = sexo)) +
  geom_point(size = 2.7, alpha = 0.7) +
  geom_line(
    data = interaction_grid,
    aes(x = idade, y = predicted_pa, linetype = sexo),
    linewidth = 0.9
  ) +
  labs(
    title = "Interaction model: SBP ~ age × sex",
    subtitle = "An interaction allows the age slope to differ between sex groups",
    x = "Age (years)",
    y = "Systolic blood pressure (mmHg)",
    shape = "Sex",
    linetype = "Sex",
    caption = "Interaction-model predictions."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

ggsave(
  "practice/manual_attempts/module3_lesson2/activity03_multiple_linear_regression/outputs/interaction_model_lines.png",
  p_interaction, width = 8.5, height = 5.5, dpi = 300, bg = "white"
)

interpretation <- tibble(
  term = c("idade", "sexoMasculino", "idade:sexoMasculino"),
  meaning = c(
    "Age effect adjusted for sex in the additive model",
    "Male-vs-female difference at the same age in the additive model",
    "Change in the age slope for males relative to females in the interaction model"
  )
)

write_csv(
  pasis,
  "practice/manual_attempts/module3_lesson2/activity03_multiple_linear_regression/outputs/simulated_bp_age_sex_data.csv"
)
write_csv(
  coef_additive,
  "practice/manual_attempts/module3_lesson2/activity03_multiple_linear_regression/outputs/additive_model_coefficients.csv"
)
write_csv(
  coef_interaction,
  "practice/manual_attempts/module3_lesson2/activity03_multiple_linear_regression/outputs/interaction_model_coefficients.csv"
)
write_csv(
  nested_comparison,
  "practice/manual_attempts/module3_lesson2/activity03_multiple_linear_regression/outputs/additive_vs_interaction_anova.csv"
)
write_csv(
  bind_rows(
    fit_additive |> mutate(model = "Additive"),
    fit_interaction |> mutate(model = "Interaction")
  ),
  "practice/manual_attempts/module3_lesson2/activity03_multiple_linear_regression/outputs/model_fit_comparison.csv"
)
write_csv(
  interpretation,
  "practice/manual_attempts/module3_lesson2/activity03_multiple_linear_regression/outputs/term_interpretation.csv"
)

# Validation: structure rather than brittle significance assumptions.
stopifnot(nrow(pasis) == 30)
stopifnot("idade" %in% names(coef(modelo_multiplo)))
stopifnot("sexoMasculino" %in% names(coef(modelo_multiplo)))
stopifnot("idade:sexoMasculino" %in% names(coef(modelo_interacao)))
stopifnot(coef(modelo_multiplo)[["idade"]] > 0)
stopifnot(all(is.finite(coef(modelo_multiplo))))
stopifnot(all(is.finite(coef(modelo_interacao))))

stopifnot(file.exists(
  "practice/manual_attempts/module3_lesson2/activity03_multiple_linear_regression/outputs/additive_parallel_lines.png"
))
stopifnot(file.exists(
  "practice/manual_attempts/module3_lesson2/activity03_multiple_linear_regression/outputs/interaction_model_lines.png"
))

cat("\n✅ M3 LESSON 2 · ACTIVITY 3 PASSED\n")
cat("Adjusted age coefficient:",
    round(coef(modelo_multiplo)[["idade"]], 3), "mmHg/year\n")
