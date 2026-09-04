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

# Official Fiocruz Activity 1/2 dataset recipe.
set.seed(42)
n <- 30

pasis <- tibble(
  idade = round(runif(n, min = 25, max = 75)),
  pa = round(100 + 0.8 * idade + rnorm(n, 0, 10)),
  sexo = if_else(runif(n) >= 0.5, "Feminino", "Masculino")
)

cat("\n============================================================\n")
cat("ACTIVITY 2 — SIMPLE LINEAR REGRESSION\n")
cat("============================================================\n")

modelo_simples <- lm(pa ~ idade, data = pasis)

cat("\nModel:\n")
print(modelo_simples)

cat("\nSummary:\n")
print(summary(modelo_simples))

coef_table <- tidy(modelo_simples, conf.int = TRUE)
fit_table <- glance(modelo_simples)

intercept <- coef(modelo_simples)[["(Intercept)"]]
slope <- coef(modelo_simples)[["idade"]]
r_squared <- summary(modelo_simples)$r.squared

interpretation <- tibble(
  quantity = c("Intercept", "Age slope", "R-squared"),
  estimate = c(intercept, slope, r_squared),
  interpretation = c(
    "Predicted SBP when age = 0; mathematically required but not clinically meaningful here",
    paste0("Expected SBP change per additional year of age: ", round(slope, 2), " mmHg"),
    paste0(round(100 * r_squared, 1), "% of observed SBP variance is explained by age in this fitted model")
  )
)

cat("\nInterpretation:\n")
print(interpretation)

p <- ggplot(pasis, aes(x = idade, y = pa)) +
  geom_point(size = 2.8, alpha = 0.75) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 0.8) +
  labs(
    title = "Simple linear regression: systolic BP ~ age",
    subtitle = paste0(
      "Slope = ", round(slope, 2),
      " mmHg/year · R² = ", round(r_squared, 2)
    ),
    x = "Age (years)",
    y = "Systolic blood pressure (mmHg)",
    caption = "Synthetic data generated from the Campus Virtual Fiocruz Module 3 Lesson 2 recipe."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson2/activity02_simple_linear_regression/outputs/simple_linear_regression.png",
  p, width = 8.5, height = 5.5, dpi = 300, bg = "white"
)

write_csv(
  pasis,
  "practice/manual_attempts/module3_lesson2/activity02_simple_linear_regression/outputs/simulated_bp_age_data.csv"
)
write_csv(
  coef_table,
  "practice/manual_attempts/module3_lesson2/activity02_simple_linear_regression/outputs/regression_coefficients.csv"
)
write_csv(
  fit_table,
  "practice/manual_attempts/module3_lesson2/activity02_simple_linear_regression/outputs/model_fit_statistics.csv"
)
write_csv(
  interpretation,
  "practice/manual_attempts/module3_lesson2/activity02_simple_linear_regression/outputs/model_interpretation.csv"
)

# Robust validation.
stopifnot(nrow(pasis) == 30)
stopifnot(is.finite(intercept), is.finite(slope), slope > 0)
stopifnot(r_squared >= 0, r_squared <= 1)
stopifnot(coef_table$p.value[coef_table$term == "idade"] < 0.05)

# With an intercept, simple-regression R² equals Pearson r².
stopifnot(
  abs(
    r_squared - cor(pasis$pa, pasis$idade)^2
  ) < 1e-10
)

stopifnot(file.exists(
  "practice/manual_attempts/module3_lesson2/activity02_simple_linear_regression/outputs/simple_linear_regression.png"
))

cat("\n✅ M3 LESSON 2 · ACTIVITY 2 PASSED\n")
cat("Slope:", round(slope, 3), "mmHg/year\n")
cat("R²:", round(r_squared, 3), "\n")
