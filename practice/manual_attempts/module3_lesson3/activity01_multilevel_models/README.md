# Module 3 · Lesson 3 · Activity 1

## Multilevel models: patients nested within hospitals

The official Fiocruz activity simulates:

- 10 hospitals;
- 30 patients per hospital;
- hospital-specific baseline effects;
- systolic blood pressure influenced by age, hospital, and random noise.

It compares:

```r
lm(pa ~ idade + sexo)
```

with:

```r
lmer(pa ~ idade + sexo + (1 | hospital_id))
```

The term `(1 | hospital_id)` allows the model intercept to vary by hospital.

### Why hierarchy matters

Patients treated in the same hospital may be more similar because they share
context, protocols, staff, referral patterns, and other unmeasured factors.
Treating all 300 patients as fully independent can underrepresent that
structure.

### ICC extension

This implementation calculates the intraclass correlation coefficient:

\[
ICC =
\frac{\sigma^2_{hospital}}
{\sigma^2_{hospital}+\sigma^2_{residual}}
\]

which summarizes the modeled clustering attributable to hospitals.

## Outputs

- `outputs/mean_bp_by_hospital.png`
- `outputs/hospital_random_intercepts.png`
- `outputs/multilevel_patient_data.csv`
- `outputs/hospital_summary.csv`
- `outputs/fixed_effects.csv`
- `outputs/random_intercepts.csv`
- `outputs/variance_components_icc.csv`
- `outputs/ordinary_vs_multilevel.csv`

## Learning source

Campus Virtual Fiocruz — **Introdução à Análise de Dados para Pesquisa no
SUS**, Module 3, Lesson 3, Activity 1.

The seed, sample sizes, hospital effects, BP simulation and `lmer()` model
follow the official activity. ICC and export tables are study extensions.
