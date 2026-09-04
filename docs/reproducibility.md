# Reproducibility

Use R 4.3 or newer. Scripts check their dependencies and never install packages or download data. Required packages are `dplyr`, `readr`, `tidyr`, `lubridate`, `ggplot2`, `patchwork`, `broom`, `nlme`, and `survival`. Simulations use fixed seeds.

From the repository root:

```bash
for script in scripts/0{3..8}_*.R; do Rscript --vanilla "$script"; done
```

The two SIM scripts require a private local CSV and accept its path; raw records are deliberately excluded from Git. Outputs are written only to `results/tables` and `results/figures`.
