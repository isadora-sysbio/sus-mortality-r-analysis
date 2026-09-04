# Module 3 · Lesson 2 · Activity 4

## Logistic regression

This activity follows the official Fiocruz hypertension simulation and fits:

```r
glm(
  hipertensao ~ idade + imc + sexo,
  family = binomial(link = "logit")
)
```

Logistic regression is appropriate because the outcome is binary.

Raw coefficients are on the **log-odds** scale. Exponentiating a coefficient
produces an **odds ratio (OR)**:

- `OR = 1`: no multiplicative change in odds;
- `OR > 1`: higher odds;
- `OR < 1`: lower odds.

The activity also predicts hypertension probability for a male patient aged
60 years with BMI 28, matching the course exercise.

This implementation uses fast Wald confidence intervals for the OR table and
adds a prediction-curve figure.

## Outputs

- `outputs/hypertension_probability_curves.png`
- `outputs/simulated_hypertension_data.csv`
- `outputs/odds_ratios.csv`
- `outputs/new_patient_prediction.csv`
- `outputs/prediction_curve_data.csv`
- `outputs/logistic_model_fit.csv`
- `outputs/or_interpretation.csv`

## Learning source

Campus Virtual Fiocruz — **Introdução à Análise de Dados para Pesquisa no
SUS**, Module 3, Lesson 2, Activity 4.

The random seed, simulated variables, probability equation, `glm()` model and
new-patient scenario follow the official course activity.
