required <- c(
  "dplyr", "readr", "tibble", "survival"
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
  library(tibble)
  library(survival)
})

# ------------------------------------------------------------
# Official Fiocruz simulation recipe
# ------------------------------------------------------------

set.seed(456)

n_pac <- 150

dados_sobrevida <- tibble(
  id = 1:n_pac,
  tratamento = sample(
    c("Quimio", "Imuno"),
    n_pac,
    replace = TRUE
  ),
  idade = round(
    pmin(
      pmax(
        rnorm(n_pac, 60, 12),
        35
      ),
      85
    )
  ),
  estadio = sample(
    c("II", "III", "IV"),
    n_pac,
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
    taxa = case_when(
      tratamento == "Imuno" ~ 0.015,
      TRUE ~ 0.025
    ) * case_when(
      estadio == "II" ~ 0.5,
      estadio == "III" ~ 1,
      TRUE ~ 1.8
    ),
    tempo_evento = rexp(n_pac, rate = taxa),
    tempo_censura = 60,
    tempo = pmin(
      tempo_evento,
      tempo_censura
    ),
    status = as.integer(
      tempo_evento <= tempo_censura
    )
  )

cat("\n============================================================\n")
cat("ACTIVITY 3 — SURVIVAL ANALYSIS\n")
cat("============================================================\n")

event_summary <- dados_sobrevida |>
  count(
    status,
    name = "n"
  ) |>
  mutate(
    status_label = if_else(
      status == 1,
      "Event",
      "Censored"
    )
  )

cat("\nEvent/censoring summary:\n")
print(event_summary)

surv_obj <- Surv(
  time = dados_sobrevida$tempo,
  event = dados_sobrevida$status
)

# ------------------------------------------------------------
# Kaplan-Meier overall
# ------------------------------------------------------------

km_geral <- survfit(
  surv_obj ~ 1
)

cat("\nOverall Kaplan-Meier:\n")
print(km_geral)

png(
  "practice/manual_attempts/module3_lesson3/activity03_survival_analysis/outputs/kaplan_meier_overall.png",
  width = 1600,
  height = 1200,
  res = 200
)
plot(
  km_geral,
  main = "Overall Kaplan-Meier Survival Curve",
  xlab = "Time (months)",
  ylab = "Survival probability",
  lwd = 2,
  mark.time = TRUE
)
grid()
dev.off()

# ------------------------------------------------------------
# Kaplan-Meier by treatment + log-rank
# ------------------------------------------------------------

km_trat <- survfit(
  surv_obj ~ tratamento,
  data = dados_sobrevida
)

cat("\nKaplan-Meier by treatment:\n")
print(km_trat)

png(
  "practice/manual_attempts/module3_lesson3/activity03_survival_analysis/outputs/kaplan_meier_by_treatment.png",
  width = 1600,
  height = 1200,
  res = 200
)
plot(
  km_trat,
  main = "Survival by Treatment",
  xlab = "Time (months)",
  ylab = "Survival probability",
  lwd = 2,
  lty = 1:2,
  mark.time = TRUE
)
legend(
  "bottomleft",
  legend = levels(dados_sobrevida$tratamento),
  lty = 1:2,
  lwd = 2,
  bty = "n"
)
grid()
dev.off()

logrank <- survdiff(
  surv_obj ~ tratamento,
  data = dados_sobrevida
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

cat("\nLog-rank test:\n")
print(logrank)
print(logrank_summary)

# ------------------------------------------------------------
# Cox proportional hazards model
# ------------------------------------------------------------

modelo_cox <- coxph(
  surv_obj ~ tratamento + idade + estadio,
  data = dados_sobrevida
)

cat("\nCox model:\n")
print(summary(modelo_cox))

cox_summary <- summary(modelo_cox)

cox_coefficients <- as.data.frame(
  cox_summary$coefficients
) |>
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

cox_confidence <- as.data.frame(
  cox_summary$conf.int
) |>
  rownames_to_column("term") |>
  as_tibble() |>
  transmute(
    term,
    hazard_ratio = `exp(coef)`,
    lower_95 = `lower .95`,
    upper_95 = `upper .95`
  )

cox_results <- left_join(
  cox_coefficients,
  cox_confidence,
  by = c("term", "hazard_ratio")
)

cat("\nHazard ratios:\n")
print(
  cox_results |>
    mutate(
      across(
        where(is.numeric),
        ~ round(.x, 4)
      )
    )
)

# ------------------------------------------------------------
# Survival probabilities at selected times
# ------------------------------------------------------------

km_times <- summary(
  km_trat,
  times = c(12, 36, 60),
  extend = TRUE
)

km_selected <- tibble(
  strata = as.character(km_times$strata),
  time_months = km_times$time,
  n_risk = km_times$n.risk,
  n_event = km_times$n.event,
  survival_probability = km_times$surv,
  lower_95 = km_times$lower,
  upper_95 = km_times$upper
)

write_csv(
  dados_sobrevida,
  "practice/manual_attempts/module3_lesson3/activity03_survival_analysis/outputs/simulated_survival_data.csv"
)

write_csv(
  event_summary,
  "practice/manual_attempts/module3_lesson3/activity03_survival_analysis/outputs/event_censoring_summary.csv"
)

write_csv(
  logrank_summary,
  "practice/manual_attempts/module3_lesson3/activity03_survival_analysis/outputs/logrank_test.csv"
)

write_csv(
  cox_results,
  "practice/manual_attempts/module3_lesson3/activity03_survival_analysis/outputs/cox_hazard_ratios.csv"
)

write_csv(
  km_selected,
  "practice/manual_attempts/module3_lesson3/activity03_survival_analysis/outputs/km_survival_selected_times.csv"
)

# Validation.
stopifnot(nrow(dados_sobrevida) == 150)
stopifnot(all(dados_sobrevida$status %in% c(0, 1)))
stopifnot(length(unique(dados_sobrevida$status)) == 2)
stopifnot(all(dados_sobrevida$tempo > 0))
stopifnot(all(dados_sobrevida$tempo <= 60))
stopifnot(is.finite(logrank$chisq))
stopifnot(logrank_p >= 0, logrank_p <= 1)
stopifnot(all(is.finite(coef(modelo_cox))))
stopifnot(all(cox_results$hazard_ratio > 0))
stopifnot(all(cox_results$lower_95 > 0))
stopifnot(all(cox_results$upper_95 > 0))

required_figures <- c(
  "practice/manual_attempts/module3_lesson3/activity03_survival_analysis/outputs/kaplan_meier_overall.png",
  "practice/manual_attempts/module3_lesson3/activity03_survival_analysis/outputs/kaplan_meier_by_treatment.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n✅ M3 LESSON 3 · ACTIVITY 3 PASSED\n")
cat("Events:", sum(dados_sobrevida$status), "\n")
cat("Censored:", sum(dados_sobrevida$status == 0), "\n")
cat("Log-rank p-value:", format.pval(logrank_p, digits = 3), "\n")

if ("tratamentoQuimio" %in% cox_results$term) {
  quimio_hr <- cox_results$hazard_ratio[
    cox_results$term == "tratamentoQuimio"
  ]
  cat(
    "Adjusted Quimio vs Imuno HR:",
    round(quimio_hr, 3),
    "\n"
  )
}
