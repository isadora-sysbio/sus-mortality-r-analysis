required_packages <- c("ggplot2", "readr", "dplyr")

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(paste0("Missing required packages: ", paste(missing_packages, collapse = ", ")))
}

suppressPackageStartupMessages({
  library(ggplot2)
  library(readr)
  library(dplyr)
})

table_dir <- "results/tables"
figure_dir <- "results/figures"
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

portfolio_theme <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 17),
    plot.subtitle = element_text(size = 11, margin = margin(b = 12)),
    plot.caption = element_text(size = 8.5, hjust = 0, margin = margin(t = 12)),
    axis.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    plot.margin = margin(18, 22, 18, 18)
  )

age <- read_csv(file.path(table_dir, "mortality_by_age_group.csv"), show_col_types = FALSE) %>%
  mutate(
    age_group = recode(
      faixa_etaria,
      "Criança" = "Child",
      "Adolescente" = "Adolescent",
      "Adulto" = "Adult",
      "Idoso" = "Older adult",
      .default = faixa_etaria
    )
  ) %>%
  arrange(deaths) %>%
  mutate(age_group = factor(age_group, levels = age_group))

top_age <- age %>% slice_max(deaths, n = 1, with_ties = FALSE)
age_subtitle <- paste0("Largest recorded count: ", top_age$age_group, " (n = ", top_age$deaths, ")")

p_age <- ggplot(age, aes(x = age_group, y = deaths)) +
  geom_col(width = 0.68, fill = "#234E70") +
  geom_text(aes(label = deaths), hjust = -0.25, size = 4) +
  coord_flip(clip = "off") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.14))) +
  labs(
    title = "Recorded mortality by age group",
    subtitle = age_subtitle,
    x = NULL,
    y = "Recorded deaths",
    caption = "Descriptive counts from a SIM-derived educational dataset. Campus Virtual Fiocruz."
  ) +
  portfolio_theme

ggsave(file.path(figure_dir, "mortality_by_age_group.png"), p_age,
       width = 8.5, height = 5.2, dpi = 320, bg = "white")

monthly <- read_csv(file.path(table_dir, "monthly_mortality.csv"), show_col_types = FALSE) %>%
  arrange(mes)

peak_month <- monthly %>% slice_max(deaths, n = 1, with_ties = FALSE)
peak_label <- paste0(month.abb[peak_month$mes], ": ", peak_month$deaths)
monthly_mean <- mean(monthly$deaths, na.rm = TRUE)
month_subtitle <- paste0("Highest monthly count: ", month.name[peak_month$mes], " (n = ", peak_month$deaths, ")")

p_month <- ggplot(monthly, aes(x = mes, y = deaths)) +
  geom_hline(yintercept = monthly_mean, linetype = "dashed", linewidth = 0.55, color = "grey55") +
  geom_line(linewidth = 1, color = "#234E70") +
  geom_point(size = 2.8, color = "#234E70") +
  geom_point(data = peak_month, size = 4.2, color = "#3A7D7C") +
  annotate("text", x = peak_month$mes - 0.25, y = peak_month$deaths + 0.7,
           label = peak_label, hjust = 1, fontface = "bold", size = 3.8) +
  annotate("text", x = 1.1, y = monthly_mean + 0.35,
           label = paste0("Monthly mean: ", round(monthly_mean, 1)),
           hjust = 0, size = 3.2, color = "grey35") +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  scale_y_continuous(expand = expansion(mult = c(0.04, 0.12))) +
  labs(
    title = "Recorded mortality varied across 2023",
    subtitle = month_subtitle,
    x = NULL,
    y = "Recorded deaths",
    caption = "Descriptive counts from a SIM-derived educational dataset. Campus Virtual Fiocruz."
  ) +
  portfolio_theme +
  theme(panel.grid.major.y = element_line(color = "grey90"))

ggsave(file.path(figure_dir, "monthly_mortality.png"), p_month,
       width = 8.5, height = 5.2, dpi = 320, bg = "white")

cat("\nPORTFOLIO FIGURES REGENERATED\n")
cat("Peak month:\n")
print(peak_month)
cat("\nLargest age-group count:\n")
print(top_age)
