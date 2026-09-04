# Module 2 · Lesson 2 · Activity 1

## Anscombe's Quartet

## Goal

Demonstrate that datasets can have nearly identical numerical summaries while
having dramatically different visual structures.

The Fiocruz lesson uses **Anscombe's Quartet** to show why analysts should not
rely only on summary statistics or correlation coefficients.

## Dataset

This implementation uses R's built-in `anscombe` dataset.

The quartet contains four datasets with very similar:

- means of `x`;
- means of `y`;
- variances;
- Pearson correlations.

Yet their scatter plots are very different.

## What I calculated

For each of the four datasets:

```r
mean(x)
mean(y)
var(x)
var(y)
cor(x, y)
```

## What visualization reveals

### Dataset I

Approximately linear.

### Dataset II

Clearly nonlinear. A single Pearson correlation coefficient does not describe
the curved shape adequately.

### Dataset III

Mostly linear, but one influential outlier strongly affects the fitted
relationship.

### Dataset IV

Most observations have the same x value. A single influential point creates a
very different geometry from the other datasets.

## Main lesson

**Similar summary statistics do not imply similar datasets.**

Before interpreting correlation or fitting a statistical model, visualize the
data.

## Research lens

This matters in health research because:

- an outlier may be a real rare patient or an error;
- a nonlinear biological relationship can produce a misleading linear
  coefficient;
- mixtures of patient subgroups can be hidden by a single summary;
- influential observations can strongly alter estimated associations.

## Outputs

- `outputs/anscombe_summary_statistics.csv`
- `outputs/anscombe_long_data.csv`
- `outputs/anscombe_visual_interpretation.csv`
- `outputs/anscombe_quartet.png`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 2, Lesson 2, Activity 1.

The course uses Anscombe's Quartet to demonstrate why numerical summaries
should be accompanied by visualization.
