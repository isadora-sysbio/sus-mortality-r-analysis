# Module 3 · Lesson 2 · Activity 1

## Pearson correlation: age and systolic blood pressure

## Goal

Measure and visualize the linear relationship between **age** and **systolic
blood pressure (SBP)**.

The official Fiocruz activity asks the learner to:

1. calculate the correlation between SBP and age;
2. interpret its strength and direction;
3. visualize the relationship with a scatter plot.

## Official simulation design

The course fixes:

```r
set.seed(42)
n <- 30
```

and generates:

```r
age = round(runif(n, min = 25, max = 75))
SBP = round(100 + 0.8 * age + rnorm(n, 0, 10))
```

plus a randomly generated sex variable.

Because the simulated SBP formula contains a positive age term, the dataset is
designed to contain a positive association.

## Pearson correlation

Pearson's correlation coefficient is denoted by:

\[
r
\]

and ranges from `-1` to `+1`.

The course uses this practical classification:

- `|r| < 0.3`: weak;
- `0.3 <= |r| < 0.7`: moderate;
- `|r| >= 0.7`: strong.

The sign gives the direction.

## Hypothesis test

The correlation test evaluates:

\[
H_0:\rho=0
\]

versus:

\[
H_1:\rho\neq0
\]

where `rho` is the population Pearson correlation.

The activity uses:

```r
cor.test(bp, age)
```

which reports:

- Pearson's `r`;
- test statistic;
- degrees of freedom;
- p-value;
- confidence interval for the population correlation.

## Visualization first

A correlation coefficient should not replace the scatter plot.

Pearson's `r` measures **linear** association. A nonlinear relationship can
have a small Pearson correlation despite a strong visual pattern.

## Correlation is not causation

A statistically significant correlation does not establish a causal effect.

Both variables may be influenced by:

- confounding;
- selection;
- measurement processes;
- additional biological or social variables.

## Spearman extension

The primary task uses Pearson's correlation.

I also calculate Spearman's rank correlation as a learning extension to make
the distinction between:

- **Pearson:** linear association;
- **Spearman:** monotonic rank association.

## Outputs

### Figures

- `outputs/age_sbp_scatter.png`
- `outputs/age_sbp_linear_trend.png`
- `outputs/qq_age.png`
- `outputs/qq_sbp.png`

### Tables

- `outputs/simulated_bp_age_data.csv`
- `outputs/descriptive_summary.csv`
- `outputs/pearson_correlation_summary.csv`
- `outputs/pearson_vs_spearman.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 3, Lesson 2, Activity 1.

The random seed, sample size, synthetic age/SBP generation formula and primary
Pearson-correlation task follow the official course activity. The enriched
trend plot, diagnostic plots and Spearman comparison are study extensions.
