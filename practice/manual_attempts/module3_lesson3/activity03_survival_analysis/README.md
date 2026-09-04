# Module 3 · Lesson 3 · Activity 3

## Survival analysis: Kaplan-Meier, log-rank and Cox regression

The official Fiocruz activity simulates 150 oncology patients with:

- treatment: chemotherapy or immunotherapy;
- age;
- cancer stage II, III or IV;
- time to event;
- administrative censoring at 60 months.

The activity introduces the defining feature of survival data: some patients
are **censored**, meaning the event time is not fully observed.

## Kaplan-Meier

```r
survfit()
```

estimates survival probabilities over time.

This implementation creates:

- an overall survival curve;
- treatment-specific curves.

## Log-rank test

```r
survdiff()
```

compares survival curves between treatment groups.

## Cox model

```r
coxph(
  Surv(time, status) ~ treatment + age + stage
)
```

estimates covariate-adjusted hazard ratios.

Interpretation:

- `HR = 1`: no hazard difference;
- `HR > 1`: higher event hazard;
- `HR < 1`: lower event hazard.

Immunotherapy is explicitly set as the treatment reference category so the
chemotherapy coefficient is interpreted relative to immunotherapy, matching
the course explanation.

## Outputs

- `outputs/kaplan_meier_overall.png`
- `outputs/kaplan_meier_by_treatment.png`
- `outputs/simulated_survival_data.csv`
- `outputs/event_censoring_summary.csv`
- `outputs/logrank_test.csv`
- `outputs/cox_hazard_ratios.csv`
- `outputs/km_survival_selected_times.csv`

## Learning source

Campus Virtual Fiocruz — **Introdução à Análise de Dados para Pesquisa no
SUS**, Module 3, Lesson 3, Activity 3.

The seed, sample size, treatment/stage structure, event-rate simulation,
60-month censoring, Kaplan-Meier comparison, log-rank test and Cox model follow
the official activity.
