# Module 2 · Lesson 1 · Activity 4

## Goal

Build a reusable R function that produces a complete descriptive-statistics
summary for a numeric variable.

This activity moves from **using individual statistical functions** to
**packaging a complete analytical recipe into a function**.

## Why this matters

In the previous activities, I used functions such as:

```r
mean(x)
median(x)
sd(x)
quantile(x)
```

If the same set of statistics is needed for many variables, copying and
editing the same code repeatedly is inefficient and can introduce errors.

A custom function lets the analysis be defined once and reused consistently.

## Function pattern

```r
summary_stats <- function(data, variable) {

  data |>
    summarise(
      mean = mean({{ variable }}, na.rm = TRUE),
      median = median({{ variable }}, na.rm = TRUE),
      sd = sd({{ variable }}, na.rm = TRUE)
    )
}
```

The `{{ variable }}` syntax allows an unquoted column name to be passed into
a `dplyr` expression.

Usage:

```r
summary_stats(newborns, birth_weight_g)
summary_stats(newborns, length_cm)
```

## Statistics included

The final function returns:

- number of non-missing observations;
- mean;
- median;
- standard deviation;
- coefficient of variation;
- minimum;
- first quartile;
- third quartile;
- maximum;
- interquartile range.

## Main lesson

A function is useful when an analytical procedure is:

1. repeated;
2. logically self-contained;
3. expected to behave consistently across variables or datasets.

This is an early step from writing one-off commands toward building
reproducible analytical workflows.

## Clinical / research lens

Standardizing a summary function is useful in research because it reduces
small inconsistencies between variables or cohorts.

However, automation does not remove the need for judgment. A generic summary
function does not know whether mean/SD or median/IQR is the most appropriate
description for the underlying distribution.

The analyst still has to inspect and interpret the data.

## Outputs

- `outputs/synthetic_newborn_measurements.csv`
- `outputs/birth_weight_summary.csv`
- `outputs/length_summary.csv`
- `outputs/summary_function_comparison.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 2, Lesson 1.

The course's official activity introduces a custom complete-summary function.
This is an original portfolio-safe implementation using synthetic data.
