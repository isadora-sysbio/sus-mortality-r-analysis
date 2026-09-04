# Module 3 · Lesson 1 · Activity 5

## One-way ANOVA and Tukey post-hoc comparisons

## Question

Does mean systolic blood pressure differ across three age groups?

The official Fiocruz activity simulates 20 observations per group:

- **Young:** mean 115 mmHg, SD 10;
- **Adult:** mean 125 mmHg, SD 12;
- **Older:** mean 135 mmHg, SD 15.

The random seed is fixed at `123` for reproducibility.

## Why ANOVA?

A two-sample t test compares two population means.

When there are three or more groups, running many separate unadjusted t tests
inflates the chance of false-positive conclusions.

A one-way ANOVA first asks one global question:

\[
H_0:\mu_1=\mu_2=\mu_3
\]

versus:

\[
H_1:\text{at least one mean differs}
\]

## F statistic

ANOVA compares variation **between groups** with variation **within groups**.

Conceptually:

\[
F=\frac{\text{between-group variation}}
        {\text{within-group variation}}
\]

A large F statistic suggests that group differences are large relative to the
natural variation inside groups.

## Important limitation

A statistically significant ANOVA does **not** identify which groups differ.

It only establishes evidence against the hypothesis that all group means are
equal.

## Tukey HSD

After a significant omnibus ANOVA, I use:

```r
TukeyHSD(anova_model)
```

Tukey's procedure performs pairwise comparisons while controlling the
familywise error rate.

For each comparison it reports:

- mean difference;
- lower 95% confidence limit;
- upper 95% confidence limit;
- multiplicity-adjusted p-value.

## Multiple testing

With three groups there are:

\[
{3 \choose 2}=3
\]

pairwise comparisons.

Repeatedly using unadjusted `alpha = 0.05` tests increases the probability of
at least one false positive across the family of tests. This is why a post-hoc
multiple-comparison method is useful.

## Effect-size extension

I calculate **eta-squared**:

\[
\eta^2=\frac{SS_{between}}{SS_{total}}
\]

which describes how much of the observed outcome variance is associated with
the grouping variable in the fitted ANOVA model.

Statistical significance and effect magnitude are separate questions.

## Diagnostics

I include:

- a residual Q-Q plot;
- residuals versus fitted values;
- within-group variance summaries.

These are exploratory diagnostics rather than mechanical pass/fail tests.

Independence is primarily a property of study design and cannot be diagnosed
from a residual plot alone.

## Outputs

### Figures

- `outputs/bp_by_age_group.png`
- `outputs/anova_residual_qq.png`
- `outputs/anova_residuals_vs_fitted.png`
- `outputs/tukey_pairwise_differences.png`

### Tables

- `outputs/blood_pressure_by_age_group.csv`
- `outputs/group_summary.csv`
- `outputs/anova_table.csv`
- `outputs/tukey_pairwise_comparisons.csv`
- `outputs/eta_squared.csv`
- `outputs/group_variance_summary.csv`
- `outputs/multiple_testing_note.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 3, Lesson 1, Activity 5.

The simulation design, seed, ANOVA structure, and Tukey follow-up are based on
the official course activity. The effect-size, multiplicity explanation and
diagnostic figures are study extensions.
