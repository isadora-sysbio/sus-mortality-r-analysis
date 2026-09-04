# Module 3 · Lesson 2 · Activity 5

## Linear-model diagnostics

The official Fiocruz activity applies the four standard R diagnostic plots to
the simple age/SBP regression:

```r
par(mfrow = c(2, 2))
plot(modelo_simples)
```

The four panels help inspect:

1. **Residuals vs Fitted** — linearity and residual spread;
2. **Normal Q-Q** — residual distribution;
3. **Scale-Location** — homoscedasticity;
4. **Residuals vs Leverage** — influential observations.

This implementation saves the four-panel diagnostic figure and exports
observation-level residual, leverage and Cook's-distance information.

Screening thresholds such as `Cook's distance > 4/n` are treated as
**heuristics for review**, not automatic reasons to delete an observation.

Independence is primarily a property of study design and cannot be proven from
a residual plot.

## Outputs

- `outputs/linear_model_diagnostics_4panel.png`
- `outputs/diagnostic_observations.csv`
- `outputs/flagged_observations.csv`
- `outputs/diagnostic_thresholds.csv`
- `outputs/assumption_guide.csv`

## Learning source

Campus Virtual Fiocruz — **Introdução à Análise de Dados para Pesquisa no
SUS**, Module 3, Lesson 2, Activity 5.
