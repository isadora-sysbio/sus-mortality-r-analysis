required <- c("dplyr", "ggplot2", "readr", "tidyr")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "))
suppressPackageStartupMessages({library(dplyr); library(ggplot2); library(readr); library(tidyr)})
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)
set.seed(2101)
newborns <- tibble(id = 1:180, weight_g = round(rnorm(180, 3150, 510)), gestation_weeks = round(rnorm(180, 38.4, 1.8), 1)) %>%
  mutate(weight_band = case_when(weight_g < 2500 ~ "Low", weight_g < 4000 ~ "Adequate", TRUE ~ "High"),
         weight_band = factor(weight_band, levels = c("Low", "Adequate", "High"), ordered = TRUE))
summary_table <- newborns %>% summarise(n = n(), mean = mean(weight_g), median = median(weight_g), sd = sd(weight_g), variance = var(weight_g), min = min(weight_g), q1 = quantile(weight_g, .25), q3 = quantile(weight_g, .75), max = max(weight_g), iqr = IQR(weight_g), cv_pct = 100 * sd / mean)
band_table <- newborns %>% count(weight_band) %>% mutate(percent = 100 * n / sum(n))
write_csv(summary_table, "results/tables/newborn_weight_summary.csv")
write_csv(band_table, "results/tables/newborn_weight_bands.csv")
p <- ggplot(newborns, aes(weight_g)) + geom_histogram(binwidth = 250, boundary = 0, fill = "#28666E", color = "white") + geom_vline(xintercept = median(newborns$weight_g), color = "#B24C63", linewidth = 1) + labs(title = "Synthetic newborn-weight distribution", subtitle = "The line marks the median", x = "Weight (g)", y = "Newborns", caption = "Synthetic educational data; no patient records.") + theme_minimal(base_size = 12)
ggsave("results/figures/newborn_weight_distribution.png", p, width = 8, height = 5, dpi = 240, bg = "white")
cat("Descriptive activities complete: variable classification, location, dispersion, reusable summary, visualization.\n")
