# Module 2 · Lesson 1 · Activity 2

## Goal

Practice **measures of location** by calculating the mean, median and quantiles
of newborn birth-weight data.

The official Fiocruz activity asks the learner to use `mean()`, `median()` and
`quantile()` for newborn data. This portfolio-safe version uses an original
synthetic dataset.

## The three ideas

### Mean

The arithmetic mean uses the magnitude of every observation:

\[
\bar{x} = \frac{\sum x_i}{n}
\]

Because every value contributes directly, the mean can move substantially when
an extreme value is introduced.

### Median

The median is the central value after ordering the observations. With an even
number of observations, it is the mean of the two middle positions.

The median is usually more robust to extreme values than the arithmetic mean.

### Quantiles

Quantiles describe position within an ordered distribution.

- P10: approximately 10% of observations are at or below this point
- Q1 / P25: 25%
- Q2 / P50: 50%, which is the median
- Q3 / P75: 75%
- P90: 90%

## What I practiced in R

```r
mean(x)
median(x)
quantile(x, probs = c(0.10, 0.25, 0.50, 0.75, 0.90))
```

I also compared the original data with a copy containing an intentionally
extreme value to see how mean and median respond differently.

## Why this matters in health research

Measures of location summarize distributions, but choosing the wrong summary
can hide important structure.

For a roughly symmetric distribution, mean and median may be similar. In
strongly skewed data or data containing extreme observations, the median can
better represent the typical observation.

## Clinical lens

An extreme measurement should not automatically be deleted.

It may represent:

- a true rare clinical event;
- measurement error;
- data-entry error;
- a patient from a different underlying population.

The analyst should investigate the observation before deciding how to handle
it.

## Outputs

- `outputs/synthetic_newborn_weights.csv`
- `outputs/location_summary.csv`
- `outputs/quantiles.csv`
- `outputs/outlier_sensitivity.csv`
- `outputs/location_measures.png`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 2, Lesson 1.

This is an original practice implementation using synthetic data.
