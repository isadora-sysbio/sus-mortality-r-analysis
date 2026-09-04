# Module 3 · Lesson 1 · Activity 4

## Independent two-sample t test

## Question

Do mean cholesterol measurements differ between two independent measurement
methods?

The official Fiocruz activity provides five measurements from each method:

### AutoAnalyzer

`177, 193, 195, 209, 226`

### Microenzimatic

`192, 197, 200, 202, 209`

and asks the learner to run:

```r
t.test(value ~ method, data = cholesterol)
```

## Hypotheses

\[
H_0:\mu_1=\mu_2
\]

\[
H_1:\mu_1\neq\mu_2
\]

## Why this is an independent two-sample test

The two sets of measurements are treated as belonging to separate groups.

This differs from a paired design, where observations would be explicitly
matched — for example, the same biological sample measured by both methods.

## Welch's t test

R's default call:

```r
t.test(value ~ method, data = cholesterol)
```

uses **Welch's two-sample t test**.

Welch's test does not require the two population variances to be equal and is
a robust default for independent-group comparisons.

## Interpretation

The analysis compares:

- the observed group means;
- the standard error of their difference;
- the t statistic;
- the Welch degrees of freedom;
- the p-value;
- the 95% confidence interval for the mean difference.

If `p < 0.05`, the data provide evidence against equal population means.

If `p >= 0.05`, the correct wording is **do not reject H0**, not "prove the
means are equal."

## Confidence-interval connection

For a two-sided test at the 5% level:

- if the 95% CI for the mean difference excludes `0`, reject H0;
- if the interval contains `0`, do not reject H0.

## Welch versus pooled-variance Student test

I also calculate the equal-variance version:

```r
t.test(value ~ method, data = cholesterol, var.equal = TRUE)
```

as a learning extension.

This makes the assumption difference explicit rather than silently treating
the two tests as interchangeable.

## Effect-size extension

Cohen's `d` is included to describe the standardized magnitude of the observed
group difference.

A p-value and an effect size answer different questions:

- p-value: evidence against H0 under the test model;
- effect size: magnitude of the observed difference.

## Outputs

### Figure

- `outputs/cholesterol_by_method.png`

### Tables

- `outputs/cholesterol_measurements.csv`
- `outputs/group_summary.csv`
- `outputs/welch_t_test_summary.csv`
- `outputs/welch_vs_equal_variance.csv`
- `outputs/ci_hypothesis_connection.csv`
- `outputs/effect_size.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 3, Lesson 1, Activity 4.

The cholesterol measurements and primary `t.test()` structure follow the
official course activity. The visualization, Welch-versus-equal-variance
comparison, confidence-interval explanation and effect-size note are study
extensions.
