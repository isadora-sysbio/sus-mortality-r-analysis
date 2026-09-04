# Module 3 · Lesson 2 · Activity 2

## Simple linear regression

This activity follows the Fiocruz progression from correlation to regression,
using the same synthetic age and systolic-blood-pressure data.

The fitted model is:

```r
lm(pa ~ idade, data = pasis)
```

or conceptually:

\[
PA = \beta_0 + \beta_1(\text{age}) + \epsilon
\]

The slope `beta1` quantifies the expected change in systolic blood pressure for
one additional year of age.

`R²` describes the proportion of observed outcome variation explained by age
in this fitted model.

The intercept is mathematically necessary but is not clinically meaningful
here because age 0 lies far outside the simulated adult age range.

## Outputs

- `outputs/simple_linear_regression.png`
- `outputs/simulated_bp_age_data.csv`
- `outputs/regression_coefficients.csv`
- `outputs/model_fit_statistics.csv`
- `outputs/model_interpretation.csv`

## Learning source

Campus Virtual Fiocruz — **Introdução à Análise de Dados para Pesquisa no
SUS**, Module 3, Lesson 2, Activity 2.

The simulation recipe and primary `lm(pa ~ idade)` analysis follow the official
course activity; the tidy output tables are study/portfolio extensions.
