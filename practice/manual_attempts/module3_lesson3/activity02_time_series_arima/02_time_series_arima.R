required <- c(
  "dplyr", "readr", "ggplot2", "tibble", "forecast"
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
  library(forecast)
})

# ------------------------------------------------------------
# Official Fiocruz simulation recipe
# ------------------------------------------------------------

set.seed(42)

n_semanas <- 156

serie_gripal <- tibble(
  semana = 1:n_semanas,
  ano = rep(2021:2023, each = 52),
  semana_ano = rep(1:52, 3)
) |>
  mutate(
    tendencia = 100 + 0.3 * semana,
    sazonalidade =
      50 * sin(
        2 * pi * (semana_ano - 10) / 52
      ),
    ruido = rnorm(n_semanas, 0, 15),
    casos = round(
      pmax(
        tendencia + sazonalidade + ruido,
        10
      )
    )
  )

cat("\n============================================================\n")
cat("ACTIVITY 2 — TIME SERIES\n")
cat("============================================================\n")

cat("\nFirst observations:\n")
print(serie_gripal |> slice_head(n = 12))

serie_ts <- ts(
  serie_gripal$casos,
  frequency = 52,
  start = c(2021, 1)
)

decomposicao <- decompose(
  serie_ts,
  type = "additive"
)

# Save the official-style decomposition plot.
png(
  "practice/manual_attempts/module3_lesson3/activity02_time_series_arima/outputs/time_series_decomposition.png",
  width = 1800,
  height = 1600,
  res = 200
)
plot(decomposicao)
dev.off()

p_series <- ggplot(
  serie_gripal,
  aes(
    x = semana,
    y = casos
  )
) +
  geom_line(linewidth = 0.8) +
  labs(
    title = "Weekly influenza-like illness cases (2021–2023)",
    subtitle = "Synthetic trend + annual seasonality + random noise",
    x = "Week",
    y = "Number of cases",
    caption = "Official Fiocruz Lesson 3 simulation recipe."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  "practice/manual_attempts/module3_lesson3/activity02_time_series_arima/outputs/weekly_ili_series.png",
  p_series,
  width = 10,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

# ARIMA model selected automatically, matching the course activity.
modelo_arima <- auto.arima(
  serie_ts
)

cat("\nSelected ARIMA model:\n")
print(modelo_arima)

ordem <- arimaorder(modelo_arima)

model_summary <- tibble(
  p = ordem[["p"]],
  d = ordem[["d"]],
  q = ordem[["q"]],
  P = ordem[["P"]],
  D = ordem[["D"]],
  Q = ordem[["Q"]],
  frequency = frequency(serie_ts),
  AIC = AIC(modelo_arima),
  BIC = BIC(modelo_arima)
)

previsao <- forecast(
  modelo_arima,
  h = 12,
  level = c(80, 95)
)

cat("\n12-week forecast:\n")
print(previsao)

# Save the official forecast style.
png(
  "practice/manual_attempts/module3_lesson3/activity02_time_series_arima/outputs/arima_12_week_forecast.png",
  width = 1800,
  height = 1200,
  res = 200
)
plot(
  previsao,
  main = "Forecast of Cases for the Next 12 Weeks",
  xlab = "Time",
  ylab = "Cases"
)
dev.off()

decomposition_table <- tibble(
  week = serie_gripal$semana,
  observed = as.numeric(decomposicao$x),
  trend = as.numeric(decomposicao$trend),
  seasonal = as.numeric(decomposicao$seasonal),
  random = as.numeric(decomposicao$random)
)

forecast_table <- tibble(
  horizon_week = 1:12,
  point_forecast = as.numeric(previsao$mean),
  lower_80 = as.numeric(previsao$lower[, "80%"]),
  upper_80 = as.numeric(previsao$upper[, "80%"]),
  lower_95 = as.numeric(previsao$lower[, "95%"]),
  upper_95 = as.numeric(previsao$upper[, "95%"])
)

write_csv(
  serie_gripal,
  "practice/manual_attempts/module3_lesson3/activity02_time_series_arima/outputs/weekly_ili_data.csv"
)

write_csv(
  decomposition_table,
  "practice/manual_attempts/module3_lesson3/activity02_time_series_arima/outputs/decomposition_components.csv"
)

write_csv(
  model_summary,
  "practice/manual_attempts/module3_lesson3/activity02_time_series_arima/outputs/arima_model_summary.csv"
)

write_csv(
  forecast_table,
  "practice/manual_attempts/module3_lesson3/activity02_time_series_arima/outputs/forecast_12_weeks.csv"
)

# Validation.
stopifnot(nrow(serie_gripal) == 156)
stopifnot(frequency(serie_ts) == 52)
stopifnot(length(decomposicao$seasonal) == 156)
stopifnot(length(previsao$mean) == 12)
stopifnot(all(is.finite(as.numeric(previsao$mean))))
stopifnot(all(forecast_table$lower_95 <= forecast_table$point_forecast))
stopifnot(all(forecast_table$upper_95 >= forecast_table$point_forecast))

required_figures <- c(
  "practice/manual_attempts/module3_lesson3/activity02_time_series_arima/outputs/weekly_ili_series.png",
  "practice/manual_attempts/module3_lesson3/activity02_time_series_arima/outputs/time_series_decomposition.png",
  "practice/manual_attempts/module3_lesson3/activity02_time_series_arima/outputs/arima_12_week_forecast.png"
)

stopifnot(all(file.exists(required_figures)))

cat("\n✅ M3 LESSON 3 · ACTIVITY 2 PASSED\n")
cat(
  "Selected model: ARIMA(",
  ordem[["p"]], ",",
  ordem[["d"]], ",",
  ordem[["q"]], ")",
  sep = ""
)
cat("\n12 future weeks forecast successfully.\n")
