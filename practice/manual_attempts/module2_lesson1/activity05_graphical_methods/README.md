# Module 2 · Lesson 1 · Activity 5

## Goal

Create three common exploratory graphics with `ggplot2`:

1. a **bar chart**;
2. a **boxplot**;
3. a **histogram**.

The Fiocruz lesson specifically directs learners to build these graph types to
practice visualization of distributions and comparison between groups.

This public portfolio version uses original synthetic health data.

## 1. Bar chart

A bar chart is appropriate for a categorical variable when the analytical
question concerns frequency or proportion.

In this activity:

- variable: `smoking_status`;
- bar height: percentage of patients in each category.

## 2. Boxplot

A boxplot is useful for comparing a numeric distribution across groups.

In this activity:

- numeric variable: systolic blood pressure;
- grouping variable: sex.

The boxplot communicates:

- median;
- first quartile;
- third quartile;
- interquartile range;
- overall spread.

Individual points are also shown so the distribution is not hidden behind the
summary alone.

## 3. Histogram

A histogram shows how a numeric variable is distributed across intervals.

In this activity:

- variable: systolic blood pressure;
- bins divide the numeric range into intervals;
- bar height counts observations in each interval.

The number and width of bins affect the visual appearance, so the histogram
should be treated as a representation of the distribution rather than as a
fixed property of the data.

## Graph-selection rule

| Question | Variables | Plot |
|---|---|---|
| How frequent is each category? | categorical | bar chart |
| How does a numeric outcome differ by group? | numeric + categorical | boxplot |
| What is the shape of a numeric distribution? | numeric | histogram |

## Why this matters in health research

A graph should be selected based on the structure of the variables and the
research question.

Visualization is not simply decoration after statistical analysis. It can
reveal:

- skewness;
- spread;
- outliers;
- group differences;
- unexpected structure.

## Clinical lens

A visually unusual value should be investigated, not automatically deleted.
It could reflect a real extreme patient, a measurement error, a data-entry
problem, or a different clinical subgroup.

## Outputs

### Figures

- `outputs/bar_smoking_status.png`
- `outputs/boxplot_sbp_by_sex.png`
- `outputs/histogram_sbp.png`

### Tables

- `outputs/synthetic_health_data.csv`
- `outputs/smoking_status_summary.csv`
- `outputs/bp_by_sex_summary.csv`
- `outputs/bp_distribution_summary.csv`
- `outputs/graph_selection_guide.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 2, Lesson 1.

The course's Activity 5 asks the learner to construct bar charts, boxplots and
histograms with `ggplot2`. This is an original portfolio-safe implementation.
