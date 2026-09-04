required <- c("dplyr", "readr", "tibble", "survival")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  cat("Installing missing packages:", paste(missing, collapse = ", "), "\n")
  install.packages(missing, repos = "https://cloud.r-project.org")
}

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tibble)
  library(survival)
})

set.seed(789)
n_onco <- 150

dados_onco <- tibble(
  id = 1:n_onco,
  tratamento = sample(c("Quimio", "Imuno"), n_onco, replace = TRUE),
  idade = round(pmin(pmax(rnorm(n_onco, 60, 10), 40), 80)),
  estadio = sample(
    c("II", "III", "IV"),
    n_onco,
    replace = TRUE,
    prob = c(0.3, 0.4, 0.3)
  )
) |>
  mutate(
    tratamento = factor(
      tratamento,
      levels = c("Imuno", "Quimio")
    ),
    estadio = factor(
      estadio,
      levels = c("II", "III", "IV")
    ),
    taxa = if_else(
      tratamento == "Imuno",
      0.02,
      0.03
    ) * case_when(
      estadio == "II" ~ 0.6,
      estadio == "III" ~ 1,
      TRUE ~ 1.5
    ),
    tempo_evento = rexp(n_onco, rate = taxa),
    tempo_censura = runif(n_onco, 24, 60),
    tempo = pmin(tempo_evento, tempo_censura),
    status = as.integer(tempo_evento <= tempo_censura)
  )

cat("\n============================================================\n")
cat("CASE 3 — ONCOLOGY SURVIVAL\n")
cat("============================================================\n")

event_summary <- dados_onco |>
  count(tratamento, status, name = "n")

cat("\nEvents/censoring by treatment:\n")
print(event_summary)

surv_onco <- Surv(
  time = dados_onco$tempo,
  event = dados_onco$status
)

km_onco <- survfit(
  surv_onco ~ tratamento,
  data = dados_onco
)

png(
  "practice/manual_attempts/module3_lesson4/case03_oncology_survival/outputs/km_survival_by_treatment.png",
  width = 1600,
  height = 1200,
  res = 200
)
plot(
  km_onco,
  main = "Survival by Treatment",
  xlab = "Time (months)",
  ylab = "Survival probability",
  lwd = 2,
  lty = 1:2,
  mark.time = TRUE
)
legend(
  "bottomleft",
  legend = levels(dados_onco$tratamento),
  lwd = 2,
  lty = 1:2,
  bty = "n"
)
grid()
dev.off()

logrank <- survdiff(
  surv_onco ~ tratamento,
  data = dados_onco
)

logrank_df <- length(logrank$n) - 1
logrank_p <- pchisq(
  logrank$chisq,
  df = logrank_df,
  lower.tail = FALSE
)

logrank_summary <- tibble(
  chisq = unname(logrank$chisq),
  df = logrank_df,
  p_value = logrank_p
)

modelo_cox <- coxph(
  surv_onco ~ tratamento + idade + estadio,
  data = dados_onco
)

cat("\nCox model:\n")
print(summary(modelo_cox))

cox_sum <- summary(modelo_cox)

cox_coef <- as.data.frame(cox_sum$coefficients) |>
  rownames_to_column("term") |>
  as_tibble() |>
  transmute(
    term,
    coefficient = coef,
    hazard_ratio = `exp(coef)`,
    standard_error = `se(coef)`,
    z = z,
    p_value = `Pr(>|z|)`
  )

cox_ci <- as.data.frame(cox_sum$conf.int) |>
  rownames_to_column("term") |>
  as_tibble() |>
  transmute(
    term,
    hazard_ratio = `exp(coef)`,
    lower_95 = `lower .95`,
    upper_95 = `upper .95`
  )

cox_results <- left_join(
  cox_coef,
  cox_ci,
  by = c("term", "hazard_ratio")
)

cat("\nHazard ratios:\n")
print(
  cox_results |>
    mutate(across(where(is.numeric), ~ round(.x, 4)))
)

# Proportional-hazards diagnostic requested by the official case.
test_ph <- cox.zph(modelo_cox)

cat("\nProportional-hazards test:\n")
print(test_ph)

ph_table <- as.data.frame(test_ph$table) |>
  rownames_to_column("term") |>
  as_tibble() |>
  rename(
    chisq = chisq,
    df = df,
    p_value = p
  )

png(
  "practice/manual_attempts/module3_lesson4/case03_oncology_survival/outputs/cox_proportional_hazards_diagnostics.png",
  width = 1800,
  height = 1600,
  res = 200
)
old_par <- par(no.readonly = TRUE)
plot(test_ph)
par(old_par)
dev.off()

km_times_raw <- summary(
  km_onco,
  times = c(12, 24, 36, 48),
  extend = TRUE
)

km_times <- tibble(
  strata = as.character(km_times_raw$strata),
  time_months = km_times_raw$time,
  n_risk = km_times_raw$n.risk,
  n_event = km_times_raw$n.event,
  survival_probability = km_times_raw$surv,
  lower_95 = km_times_raw$lower,
  upper_95 = km_times_raw$upper
)

write_csv(
  dados_onco,
  "practice/manual_attempts/module3_lesson4/case03_oncology_survival/outputs/simulated_oncology_data.csv"
)
write_csv(
  event_summary,
  "practice/manual_attempts/module3_lesson4/case03_oncology_survival/outputs/events_by_treatment.csv"
)
write_csv(
  logrank_summary,
  "practice/manual_attempts/module3_lesson4/case03_oncology_survival/outputs/logrank_test.csv"
)
write_csv(
  cox_results,
  "practice/manual_attempts/module3_lesson4/case03_oncology_survival/outputs/cox_hazard_ratios.csv"
)
write_csv(
  ph_table,
  "practice/manual_attempts/module3_lesson4/case03_oncology_survival/outputs/proportional_hazards_test.csv"
)
write_csv(
  km_times,
  "practice/manual_attempts/module3_lesson4/case03_oncology_survival/outputs/km_selected_times.csv"
)

stopifnot(nrow(dados_onco) == 150)
stopifnot(all(dados_onco$status %in% c(0, 1)))
stopifnot(length(unique(dados_onco$status)) == 2)
stopifnot(all(dados_onco$tempo > 0))
stopifnot(all(is.finite(coef(modelo_cox))))
stopifnot(all(cox_results$hazard_ratio > 0))
stopifnot(logrank_p >= 0, logrank_p <= 1)
stopifnot("GLOBAL" %in% ph_table$term)

required_figures <- c(
  "practice/manual_attempts/module3_lesson4/case03_oncology_survival/outputs/km_survival_by_treatment.png",
  "practice/manual_attempts/module3_lesson4/case03_oncology_survival/outputs/cox_proportional_hazards_diagnostics.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n✅ M3 LESSON 4 · CASE 3 PASSED\n")
cat("Events:", sum(dados_onco$status), "\n")
cat("Censored:", sum(dados_onco$status == 0), "\n")
cat("Log-rank p-value:", format.pval(logrank_p, digits = 3), "\n")

if ("tratamentoQuimio" %in% cox_results$term) {
  cat(
    "Adjusted Quimio vs Imuno HR:",
    round(
      cox_results$hazard_ratio[
        cox_results$term == "tratamentoQuimio"
      ],
      3
    ),
    "\n"
  )
}
