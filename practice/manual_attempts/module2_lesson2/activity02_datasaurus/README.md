# Module 2 · Lesson 2 · Activity 2

## Datasaurus Dozen

## Goal

Explore the **Datasaurus Dozen**, a collection of datasets deliberately
constructed to have nearly identical summary statistics while producing very
different scatter plots.

The Fiocruz lesson uses this example immediately after Anscombe's Quartet to
reinforce the principle that analysts should visualize data rather than rely
only on numerical summaries.

## Dataset

This activity uses the CRAN package `datasauRus`.

The package's `datasaurus_dozen` object contains the original dinosaur-shaped
dataset plus twelve companion shapes.

## What I calculated

For every dataset:

```r
mean(x)
mean(y)
sd(x)
sd(y)
var(x)
var(y)
cor(x, y)
```

The numerical summaries are intentionally very similar.

## What the plots reveal

Despite those similar numbers, the datasets form patterns such as:

- a dinosaur;
- circles;
- stars;
- lines;
- X-shaped patterns;
- clusters and other geometries.

These structures are almost invisible if the analysis stops at means,
standard deviations and Pearson correlation.

## Statistical lesson

Summary statistics are a form of **information compression**.

Compression is useful because it lets us describe large amounts of data with
a few numbers. But information that is not represented by those numbers is
lost.

For example, Pearson correlation describes **linear association**. It cannot
describe every possible nonlinear spatial pattern.

## Health-research lens

The same problem can occur with real biomedical data.

Two cohorts can have similar means and standard deviations while differing in:

- subgroup structure;
- outliers;
- nonlinear relationships;
- batch effects;
- multimodality;
- ceiling/floor effects.

Visual exploration therefore belongs before formal modeling.

## Bioinformatics connection

In omics, datasets with similar global summaries can still differ because of:

- batch effects;
- sample swaps;
- hidden clusters;
- technical outliers;
- disease subtypes.

This is why PCA, sample-level QC and distribution plots are important before
differential-expression or machine-learning analyses.

## Outputs

### Figures

- `outputs/datasaurus_all_shapes.png`
- `outputs/datasaurus_dino.png`

### Tables

- `outputs/datasaurus_summary_statistics.csv`
- `outputs/datasaurus_similarity_ranges.csv`
- `outputs/datasaurus_interpretation.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 2, Lesson 2, Activity 2.

The course explicitly uses the Datasaurus example and recommends the
`datasauRus` package to demonstrate why numerical summaries should be combined
with visualization.
