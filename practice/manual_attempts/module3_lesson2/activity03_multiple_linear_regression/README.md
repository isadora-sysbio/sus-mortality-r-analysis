# Module 3 · Lesson 2 · Activity 3

## Multiple linear regression and interaction

The official course extends the age/SBP model by adding sex:

```r
lm(pa ~ idade + sexo, data = pasis)
```

The age coefficient is interpreted **adjusted for sex**. The sex coefficient
compares males with the female reference group at the same age.

The course then introduces:

```r
lm(pa ~ idade * sexo, data = pasis)
```

which adds an age-by-sex interaction. An interaction allows the age slope to
differ by sex.

### Visualization note

The course explains the additive model conceptually as parallel regression
lines. This implementation plots predictions directly from the additive model
so that the visual is constrained to match that model. A second plot shows the
interaction model, where slopes are allowed to differ.

The simulated outcome itself was generated from age plus random noise, without
an explicit sex effect, so this exercise is about **model interpretation**, not
about proving a sex association.

## Outputs

- `outputs/additive_parallel_lines.png`
- `outputs/interaction_model_lines.png`
- `outputs/additive_model_coefficients.csv`
- `outputs/interaction_model_coefficients.csv`
- `outputs/additive_vs_interaction_anova.csv`
- `outputs/model_fit_comparison.csv`
- `outputs/term_interpretation.csv`

## Learning source

Campus Virtual Fiocruz — **Introdução à Análise de Dados para Pesquisa no
SUS**, Module 3, Lesson 2, Activity 3.
