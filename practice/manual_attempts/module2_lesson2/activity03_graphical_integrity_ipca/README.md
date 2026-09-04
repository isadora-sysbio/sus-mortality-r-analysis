# Module 2 · Lesson 2 · Activity 3

## Graphical integrity: IPCA example

## Goal

Understand why the design of an axis can change the visual message of a graph.

The Fiocruz lesson presents a misleading IPCA bar chart in which the y-axis
starts around 4%, greatly amplifying relatively modest differences between
years. Activity 3 reconstructs the IPCA data and produces the corrected graph.

## Data used

The activity script supplies the following values:

| Year | IPCA (%) |
|---:|---:|
| 2009 | 4.31 |
| 2010 | 5.92 |
| 2011 | 6.50 |
| 2012 | 5.84 |
| 2013 | 5.91 |

## Why the truncated chart is misleading

In a bar chart, the **length of each bar** is the visual encoding of
magnitude.

If the axis begins at 4% rather than zero, a value such as 6.5% can appear
many times taller than 4.31%, even though the actual ratio is much smaller.

This can exaggerate the impression of change.

## Correct principle

For ordinary quantitative bar charts:

> the magnitude axis should normally begin at zero so bar lengths remain
> proportional to the represented quantities.

That rule is specific to bar-length encoding. It should not be applied
mechanically to every possible graph type.

## What I added

In addition to the corrected Fiocruz-style graph, I generated a deliberately
truncated version for side-by-side conceptual comparison and calculated the
absolute and relative year-to-year differences.

## Graphical-integrity checklist

A clear graph should consider:

- an honest baseline;
- proportional visual encoding;
- axis units;
- informative title/context;
- meaningful reference lines;
- purposeful rather than decorative color.

## Outputs

### Figures

- `outputs/ipca_misleading_truncated_axis.png`
- `outputs/ipca_correct_zero_baseline.png`

### Tables

- `outputs/ipca_values.csv`
- `outputs/ipca_change_table.csv`
- `outputs/graphical_integrity_checklist.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 2, Lesson 2, Activity 3.

The IPCA values follow the official course activity script. The misleading
comparison figure and explanatory checklist are original learning extensions.
