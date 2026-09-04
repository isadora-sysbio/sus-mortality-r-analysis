# Module 3 · Lesson 4 · Case 3

## Oncology survival: Kaplan-Meier, log-rank and Cox regression

This final integrated case compares survival under chemotherapy versus
immunotherapy in 150 simulated oncology patients.

The official workflow is:

```text
censoring-aware survival object
→ Kaplan-Meier curves
→ log-rank comparison
→ multivariable Cox model
→ proportional-hazards diagnostic
```

The Cox model adjusts treatment comparisons for age and cancer stage.

Hazard ratios are interpreted relative to explicit reference categories:

- treatment reference: immunotherapy;
- stage reference: stage II.

The official activity also requires checking the proportional-hazards
assumption with:

```r
cox.zph()
```

A small p-value may indicate that a covariate effect changes over time and
therefore deserves closer model review.

This is synthetic educational data and should not be interpreted as treatment
evidence.

## Outputs

- `outputs/km_survival_by_treatment.png`
- `outputs/cox_proportional_hazards_diagnostics.png`
- `outputs/simulated_oncology_data.csv`
- `outputs/events_by_treatment.csv`
- `outputs/logrank_test.csv`
- `outputs/cox_hazard_ratios.csv`
- `outputs/proportional_hazards_test.csv`
- `outputs/km_selected_times.csv`

## Learning source

Campus Virtual Fiocruz — **Introdução à Análise de Dados para Pesquisa no
SUS**, Module 3, Lesson 4, Case 3.

The seed, sample size, treatment/stage simulation, variable censoring,
Kaplan-Meier analysis, log-rank comparison, Cox model and `cox.zph()` check
follow the official integrated case.
