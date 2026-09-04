# Module 3 · Lesson 1 · Activity 6

## One-sample proportion test

## Question

Does hypertension prevalence in a sample of 200 adults differ from a reference
prevalence of **25%**?

The official Fiocruz activity provides:

- sample size: `n = 200`;
- hypertensive adults: `x = 60`;
- observed prevalence: `60 / 200 = 30%`;
- reference prevalence: `25%`.

The official test is:

```r
prop.test(x = 60, n = 200, p = 0.25)
```

## Hypotheses

\[
H_0:p=0.25
\]

\[
H_1:p\neq0.25
\]

This is a two-sided test of one population proportion against a reference
value.

## Observed difference

The sample prevalence is:

\[
\hat p=\frac{60}{200}=0.30
\]

or **30%**.

That is **5 percentage points above** the 25% reference.

The existence of an observed difference does not automatically mean that the
difference is statistically significant.

## `prop.test()`

R's `prop.test()` uses an approximate chi-squared procedure for proportions.

For the official call, R applies its default continuity correction when
applicable.

The analysis returns:

- the estimated proportion;
- a chi-squared statistic;
- a p-value;
- a 95% confidence interval.

## Interpretation

The p-value is above `0.05`, so the correct decision is:

**do not reject H0**.

The data do not provide sufficient evidence that the population prevalence
differs from 25%.

This is not proof that the true prevalence is exactly 25%.

## Confidence-interval connection

For the two-sided comparison, the reference proportion and the compatible
95% confidence interval tell the same inferential story.

If the reference value is compatible with the 95% interval, the corresponding
two-sided 5% test does not reject H0.

## Continuity correction

I compare:

```r
prop.test(..., correct = TRUE)
prop.test(..., correct = FALSE)
```

to make the implementation choice visible.

The course's official command uses R's default continuity correction.

## Exact binomial extension

I also run:

```r
binom.test(...)
```

as an extension.

This is not a replacement for the Fiocruz activity. It demonstrates that an
exact binomial procedure and the approximate `prop.test()` procedure are
related but not identical.

## Magnitude versus statistical evidence

The observed prevalence is 30%, compared with a reference of 25%.

The **5 percentage-point difference** describes magnitude.

The **p-value** addresses evidence against H0 under the chosen test.

Those are separate questions.

## Outputs

### Figure

- `outputs/prevalence_ci_vs_reference.png`

### Tables

- `outputs/proportion_test_summary.csv`
- `outputs/ci_hypothesis_connection.csv`
- `outputs/continuity_correction_comparison.csv`
- `outputs/exact_binomial_extension.csv`
- `outputs/prevalence_magnitude.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 3, Lesson 1, Activity 6.

The sample size, event count, 25% reference and primary `prop.test()` call
follow the official course activity. The continuity-correction comparison,
exact binomial test and magnitude notes are study extensions.
