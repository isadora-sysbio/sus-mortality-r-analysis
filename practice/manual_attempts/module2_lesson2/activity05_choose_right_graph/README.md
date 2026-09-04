# Module 2 · Lesson 2 · Activity 5

## Choosing the right graph

## Goal

Choose graph types according to the **structure of the data** and the
**analytical question**.

The official Fiocruz activity uses two examples:

1. pie chart versus horizontal bars for proportions;
2. weekly influenza cases displayed as a line graph.

## Pie chart versus horizontal bars

The example contains three groups:

- A: 45%
- B: 35%
- C: 20%

A pie chart can display composition, but comparing angles and areas precisely
is more difficult than comparing lengths on a shared baseline.

The horizontal-bar alternative therefore makes direct magnitude comparison
easier.

If a pie chart is used, explicit percentage labels help interpretation.

## Time series

For weekly influenza cases, temporal order is part of the data structure.

A line graph:

- preserves week order;
- connects adjacent observations;
- makes trends and possible seasonality easier to see.

## Graph selection principle

The graph should answer the question.

| Goal | Common plot |
|---|---|
| Compare category magnitudes | bar chart |
| Show simple composition | pie chart, cautiously |
| Show ordered temporal change | line chart |
| Show one numeric distribution | histogram |
| Compare numeric distributions by group | boxplot |
| Relate two numeric variables | scatter plot |

## Zero-baseline nuance

The course example includes zero on the influenza line graph.

For **bar charts**, a zero baseline is usually essential because bar length
itself represents magnitude.

For **line charts**, a zero baseline is context-dependent rather than a
universal rule. The appropriate axis should preserve honest interpretation of
the temporal pattern.

## Outputs

### Figures

- `outputs/group_proportions_pie.png`
- `outputs/group_proportions_horizontal_bar.png`
- `outputs/influenza_weekly_line.png`

### Tables

- `outputs/group_proportions.csv`
- `outputs/influenza_weekly_series.csv`
- `outputs/graph_selection_guide.csv`
- `outputs/zero_baseline_note.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 2, Lesson 2, Activity 5.

The group proportions and influenza-series structure follow the official
activity script. The graph-selection table and zero-baseline clarification are
original study notes.
