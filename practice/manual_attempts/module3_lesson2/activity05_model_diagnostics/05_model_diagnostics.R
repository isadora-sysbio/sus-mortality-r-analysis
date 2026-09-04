required <- c("dplyr", "readr", "tibble", "broom")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) install.packages(missing, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tibble)
  library(broom)
})

set.seed(42)
n <- 30

pasis <- tibble(
  idade = round(runif(n, min = 25, max = 75)),
  pa = round(100 + 0.8 * idade + rnorm(n, 0, 10)),
  sexo = if_else(runif(n) >= 0.5, "Feminino", "Masculino")
)

modelo_simples <- lm(pa ~ idade, data = pasis)

cat("\n============================================================\n")
cat("ACTIVITY 5 — MODEL DIAGNOSTICS\n")
cat("============================================================\n")

# Reproduce the four standard diagnostic panels requested by the course.
png(
  filename = "practice/manual_attempts/module3_lesson2/activity05_model_diagnostics/outputs/linear_model_diagnostics_4panel.png",
  width = 1800,
  height = 1600,
  res = 200
)

old_par <- par(no.readonly = TRUE)
par(mfrow = c(2, 2))
plot(modelo_simples)
par(old_par)
dev.off()

diagnostics <- augment(modelo_simples) |>
  mutate(
    observation = row_number()
  )

p_parameters <- length(coef(modelo_simples))
cook_threshold <- 4 / nrow(diagnostics)
leverage_threshold <- 2 * p_parameters / nrow(diagnostics)

diagnostic_flags <- diagnostics |>
  transmute(
    observation,
    idade,
    pa,
    fitted = .fitted,
    residual = .resid,
    standardized_residual = .std.resid,
    leverage = .hat,
    cooks_distance = .cooksd,
    high_cooks_distance = .cooksd > cook_threshold,
    high_leverage = .hat > leverage_threshold
  )

flagged <- diagnostic_flags |>
  filter(
    high_cooks_distance |
      high_leverage |
      abs(standardized_residual) > 2
  )

thresholds <- tibble(
  diagnostic = c(
    "Cook's distance",
    "Leverage",
    "Absolute standardized residual"
  ),
  heuristic = c(
    "4/n",
    "2p/n",
    "> 2"
  ),
  threshold = c(
    cook_threshold,
    leverage_threshold,
    2
  ),
  note = c(
    "Screening heuristic, not an automatic deletion rule",
    "Screening heuristic, not an automatic deletion rule",
    "Large residual flag for closer inspection"
  )
)

assumptions <- tibble(
  assumption = c(
    "Linearity",
    "Residual Normality",
    "Homoscedasticity",
    "Independence"
  ),
  diagnostic = c(
    "Residuals vs Fitted",
    "Normal Q-Q",
    "Residuals vs Fitted + Scale-Location",
    "Primarily determined by study design"
  ),
  desirable_pattern = c(
    "No systematic curve",
    "Points approximately follow the diagonal",
    "No strong funnel/change in spread",
    "Observations not structurally dependent"
  )
)

cat("\nDiagnostic thresholds:\n")
print(thresholds)

cat("\nFlagged observations for review:\n")
if (nrow(flagged) == 0) {
  cat("None under the selected screening heuristics.\n")
} else {
  print(flagged)
}

cat("\nAssumption guide:\n")
print(assumptions)

write_csv(
  diagnostic_flags,
  "practice/manual_attempts/module3_lesson2/activity05_model_diagnostics/outputs/diagnostic_observations.csv"
)
write_csv(
  flagged,
  "practice/manual_attempts/module3_lesson2/activity05_model_diagnostics/outputs/flagged_observations.csv"
)
write_csv(
  thresholds,
  "practice/manual_attempts/module3_lesson2/activity05_model_diagnostics/outputs/diagnostic_thresholds.csv"
)
write_csv(
  assumptions,
  "practice/manual_attempts/module3_lesson2/activity05_model_diagnostics/outputs/assumption_guide.csv"
)

# Validation.
stopifnot(nrow(diagnostics) == 30)
stopifnot(all(is.finite(diagnostics$.fitted)))
stopifnot(all(is.finite(diagnostics$.resid)))
stopifnot(all(is.finite(diagnostics$.hat)))
stopifnot(all(is.finite(diagnostics$.cooksd)))
stopifnot(file.info(
  "practice/manual_attempts/module3_lesson2/activity05_model_diagnostics/outputs/linear_model_diagnostics_4panel.png"
)$size > 10000)

cat("\n✅ M3 LESSON 2 · ACTIVITY 5 PASSED\n")
cat("Cook threshold:", round(cook_threshold, 3), "\n")
cat("Leverage threshold:", round(leverage_threshold, 3), "\n")
cat("Observations flagged for review:", nrow(flagged), "\n")
