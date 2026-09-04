# Module 3 · Lesson 4 · Case 1

## Risk factors for severe COVID-19

This integrated case asks a public-health analyst to identify patient
characteristics associated with severe COVID-19.

The official Fiocruz simulation contains 500 patients and models severe disease
from:

- age;
- sex;
- diabetes;
- hypertension;
- obesity.

Because the outcome is binary, the primary model is logistic regression:

```r
glm(
  severe_case ~ age + sex + diabetes + hypertension + obesity,
  family = binomial
)
```

The model is summarized using adjusted **odds ratios (ORs)** and 95% confidence
intervals.

A forest plot places the null value at `OR = 1`, making direction and
uncertainty visible.

This is an educational synthetic-data case. Associations in the simulation
should not be treated as estimates of real-world COVID-19 risk.

## Outputs

- `outputs/covid_risk_forest_plot.png`
- `outputs/simulated_covid_data.csv`
- `outputs/severity_counts.csv`
- `outputs/descriptive_by_severity.csv`
- `outputs/logistic_odds_ratios.csv`
- `outputs/manager_summary.csv`

## Learning source

Campus Virtual Fiocruz — **Introdução à Análise de Dados para Pesquisa no
SUS**, Module 3, Lesson 4, Case 1.

The seed, sample size, prevalence assumptions, probability equation and
multivariable logistic model follow the official integrated case.
