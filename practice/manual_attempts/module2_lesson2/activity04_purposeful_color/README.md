# Module 2 · Lesson 2 · Activity 4

## Purposeful and accessible color

## Goal

Use color only when it contributes analytical meaning.

The Fiocruz activity has two main examples:

1. cardiovascular-event incidence rate ratios after dengue, using color to
   distinguish post-infection periods;
2. average fuel consumption by manufacturer, using a sequential color scale to
   represent numeric magnitude.

## 1. Color for categories

In the dengue example, color distinguishes:

- Days 1–7 after infection;
- Days 8–14 after infection.

This is purposeful because color represents an actual variable: **time
period**.

I also encoded the two periods with different point shapes. This creates
redundancy: the groups remain distinguishable even if color perception is
limited.

## 2. Color for magnitude

The `mtcars` extension calculates average miles per gallon by manufacturer.

Because `mpg_mean` is a numeric ordered quantity, a sequential gradient is
appropriate:

```r
aes(fill = mpg_mean)
```

The color intensity represents the same underlying numeric magnitude.

## Decorative color

Different colors should not be added merely because a plotting package makes
it easy.

If every bar represents the same type of quantity and color adds no new
information, multiple colors can make the graph noisier without making it more
informative.

## Accessibility

Important checks include:

- do not rely only on red-versus-green distinctions;
- use labels, positions, shapes or line types when useful;
- keep legends explicit;
- use sufficient contrast;
- match the palette to the data type.

## Statistical / clinical interpretation

The dengue values are **incidence rate ratios (IRR)**.

- `IRR = 1` is the reference of no rate increase;
- `IRR > 1` indicates a higher incidence rate relative to the reference.

The figure's color distinguishes *when* after infection the measurement
applies; it does not represent the magnitude of the IRR itself.

## Outputs

### Figures

- `outputs/dengue_purposeful_color.png`
- `outputs/sequential_color_mpg.png`

### Tables

- `outputs/dengue_events.csv`
- `outputs/manufacturer_mpg.csv`
- `outputs/decorative_vs_purposeful_color.csv`
- `outputs/color_accessibility_checklist.csv`

## Learning source

Developed while studying **Introdução à Análise de Dados para Pesquisa no
SUS**, Campus Virtual Fiocruz, Module 2, Lesson 2, Activity 4.

The structure and simplified dengue values follow the official course activity.
Accessibility checks and redundant shape encoding are original learning
extensions.
