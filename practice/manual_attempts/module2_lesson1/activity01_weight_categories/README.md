# Module 2 · Lesson 1 · Activity 1

## Goal

Practice the distinction between a **quantitative continuous variable** and a
**qualitative ordinal variable** by recoding body weight with
`dplyr::mutate()` and `case_when()`.

## What I did

I created a small synthetic dataset in which `peso_kg` contains decimal
measurements. I then recoded those measurements into three ordered categories:

- `< 60 kg`
- `60–79.9 kg`
- `≥ 80 kg`

These boundaries are **didactic only**. They are not intended as clinical
diagnostic cutoffs.

## Why the variable type changes

`peso_kg = 67.8` is quantitative because the numeric distance between values
has meaning. After categorization, `"60–79.9 kg"` is an ordered label. The
categories preserve order, but not the original numerical precision.

That means categorization can make summaries easier to read while also
discarding information.

## R concepts practiced

- `tibble()`
- `mutate()`
- `case_when()`
- ordered `factor()`
- `count()`
- `ggplot2`
- simple validation with `stopifnot()`

## Outputs

- `outputs/weights_categorized.csv`
- `outputs/category_summary.csv`
- `outputs/weight_category_distribution.png`

## Interpretation

The exercise demonstrates that changing how a variable is represented changes
what can be learned from it. The original continuous values allow direct
numerical comparisons, while the ordinal version is useful for grouped
summaries but has lower resolution.

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 2, Lesson 1.

This is an original practice implementation using synthetic data.
