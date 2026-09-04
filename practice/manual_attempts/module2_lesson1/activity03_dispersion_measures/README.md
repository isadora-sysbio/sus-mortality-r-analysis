# Module 2 · Lesson 1 · Activity 3

## Goal

Compare the **dispersion** of cholesterol measurements obtained by two
different methods using:

- variance;
- standard deviation;
- coefficient of variation;
- grouped summaries in `dplyr`.

The Fiocruz activity specifically asks learners to compare two measurement
methods using `var()`, `sd()` and `group_by()`. This version uses original
synthetic data so the public portfolio does not redistribute course data.

## Why dispersion matters

Measures of location such as the mean tell us where the center of a
distribution lies. They do not tell us how tightly observations cluster
around that center.

Two methods can have very similar means while one produces much more variable
measurements.

## Variance

Sample variance is based on squared deviations from the mean:

\[
s^2 = \frac{\sum (x_i-\bar{x})^2}{n-1}
\]

Squaring prevents positive and negative deviations from cancelling.

The tradeoff is that variance is expressed in **squared units**. If cholesterol
is measured in mg/dL, the variance is expressed in `(mg/dL)^2`.

## Standard deviation

Standard deviation is the square root of variance:

\[
s = \sqrt{s^2}
\]

It returns the dispersion measure to the original unit, here mg/dL.

## Coefficient of variation

The coefficient of variation expresses the standard deviation relative to the
mean:

\[
CV = \frac{s}{\bar{x}}\times100\%
\]

Because both numerator and denominator have the same units, the CV is
dimensionless.

A lower CV means less relative dispersion around the mean.

## R pattern practiced

```r
dados |>
  group_by(method) |>
  summarise(
    mean = mean(value),
    variance = var(value),
    sd = sd(value),
    cv = 100 * sd(value) / mean(value)
  )
```

## Main interpretation

In this synthetic example, both methods have broadly similar central values,
but Method B is much more tightly clustered. Its smaller standard deviation
and coefficient of variation make that difference explicit.

## Clinical / laboratory lens

Lower dispersion does **not automatically prove** that a method is more
accurate.

- **Precision** concerns reproducibility / spread.
- **Accuracy** concerns closeness to a true or reference value.

A method can be precise but systematically biased.

## Extension: IQR

The script also calculates the interquartile range (`IQR`) as a robust
dispersion measure. This is included as an extension because IQR is less
sensitive to extremes than range or standard deviation in many settings.

## Outputs

- `outputs/synthetic_cholesterol_methods.csv`
- `outputs/dispersion_summary.csv`
- `outputs/deviation_check_method_a.csv`
- `outputs/cholesterol_dispersion_comparison.png`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 2, Lesson 1.

This is an original practice implementation using synthetic data.
