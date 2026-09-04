# Module 3 · Lesson 3 · Activity 2

## Time series: decomposition, ARIMA and forecasting

The official Fiocruz activity simulates **156 weekly observations** — three
years of weekly influenza-like illness cases.

The generated series contains:

- a gradual trend;
- annual seasonality with a 52-week cycle;
- random noise.

It is converted to a time-series object with:

```r
ts(cases, frequency = 52, start = c(2021, 1))
```

The activity then uses:

```r
decompose()
auto.arima()
forecast(..., h = 12)
```

### Decomposition

The additive decomposition separates the observed series into:

- trend;
- seasonal pattern;
- random remainder.

### ARIMA

`auto.arima()` selects an ARIMA-family model automatically. The exact selected
orders are data-dependent, so this implementation exports them rather than
hard-coding a specific model.

### Forecasting

The final analysis predicts the next 12 weeks and exports point forecasts plus
80% and 95% forecast intervals.

## Outputs

- `outputs/weekly_ili_series.png`
- `outputs/time_series_decomposition.png`
- `outputs/arima_12_week_forecast.png`
- `outputs/weekly_ili_data.csv`
- `outputs/decomposition_components.csv`
- `outputs/arima_model_summary.csv`
- `outputs/forecast_12_weeks.csv`

## Learning source

Campus Virtual Fiocruz — **Introdução à Análise de Dados para Pesquisa no
SUS**, Module 3, Lesson 3, Activity 2.

The seed, 156-week structure, trend/seasonality formula, `ts()`,
`decompose()`, `auto.arima()` and 12-week forecast follow the official
activity.
