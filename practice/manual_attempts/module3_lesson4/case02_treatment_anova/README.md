# Module 3 · Lesson 4 · Case 2

## Comparing treatments in a simulated clinical trial

The official integrated case compares three groups:

- placebo;
- Drug A;
- Drug B.

The outcome is continuous: reduction in blood pressure after 8 weeks.

The workflow is:

```text
descriptive summaries
→ boxplot
→ one-way ANOVA
→ Tukey multiple comparisons
→ equivalent linear-model interpretation
```

The omnibus ANOVA tests whether all three population means can be treated as
equal. Tukey then identifies which pairs differ while adjusting for multiple
comparisons.

The equivalent model:

```r
lm(reduction ~ treatment)
```

shows the placebo mean as the intercept and drug coefficients as differences
from placebo.

Because this is synthetic educational data, treatment-effect estimates are
not clinical evidence.

## Outputs

- `outputs/treatment_bp_reduction_boxplot.png`
- `outputs/tukey_treatment_differences.png`
- `outputs/simulated_trial_data.csv`
- `outputs/group_summary.csv`
- `outputs/anova_table.csv`
- `outputs/tukey_pairwise_comparisons.csv`
- `outputs/lm_equivalent_coefficients.csv`
- `outputs/treatment_decision_summary.csv`

## Learning source

Campus Virtual Fiocruz — **Introdução à Análise de Dados para Pesquisa no
SUS**, Module 3, Lesson 4, Case 2.

The seed, group sizes, simulated treatment effects, ANOVA, Tukey test and
equivalent `lm()` formulation follow the official case.
