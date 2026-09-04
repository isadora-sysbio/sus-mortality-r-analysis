# Module 3 · Lesson 1 · Activity 3

## One-sample Student t test

## Question

Does the mean birth weight in this maternity sample differ from a reference
value of **3200 g**?

The official Fiocruz activity uses 20 newborn birth weights and:

```r
t.test(peso_rn, mu = 3200)
```

## Hypotheses

\[
H_0:\mu=3200\text{ g}
\]

\[
H_1:\mu\neq3200\text{ g}
\]

This is a two-sided one-sample t test.

## Why Student's t?

The population standard deviation is unknown, so uncertainty is estimated
using the sample standard deviation.

The test statistic is:

\[
t=\frac{\bar{x}-\mu_0}{s/\sqrt{n}}
\]

with:

\[
df=n-1
\]

For this sample, `n = 20`, so `df = 19`.

## Result

The sample mean is approximately **3166.9 g**.

The two-sided test gives approximately:

- `t = -0.332`;
- `df = 19`;
- `p = 0.743`.

Because `p >= 0.05`, I **do not reject H0**.

This means the sample does not provide sufficient statistical evidence that
the population mean birth weight differs from 3200 g.

It does **not** prove that the population mean is exactly 3200 g.

## Confidence-interval connection

For a two-sided test with `alpha = 0.05`, the hypothesis test and the 95%
confidence interval are linked.

If the null reference value lies inside the 95% CI for the population mean,
the corresponding two-sided test does not reject at the 5% level.

## p-value interpretation

The p-value is calculated under the assumption that H0 is true.

It is not:

- the probability that H0 is true;
- the probability that the observed result happened "by chance";
- a measure of the clinical importance of the difference.

## Effect-size extension

I also calculate one-sample Cohen's `d`:

\[
d=\frac{\bar{x}-\mu_0}{s}
\]

to separate the **magnitude of the observed difference** from the hypothesis
test's evidence against H0.

## Assumptions / design considerations

The one-sample t test assumes that observations are independent.

For a small sample, the distribution should not contain severe pathologies
that make inference about the mean unreliable. I included a Q-Q plot as an
exploratory diagnostic rather than a mechanical normality-test gate.

## Outputs

### Figures

- `outputs/qq_birth_weight.png`
- `outputs/mean_ci_vs_reference.png`

### Tables

- `outputs/newborn_birth_weights.csv`
- `outputs/one_sample_t_test_summary.csv`
- `outputs/ci_hypothesis_test_connection.csv`
- `outputs/effect_size.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 3, Lesson 1, Activity 3.

The newborn values and reference comparison follow the official course
activity. The manual t calculation, Q-Q diagnostic, confidence-interval link,
and effect-size note are study extensions.
