#' ---
#' boroughwide_linear_visualisations.R
#' Title: Boroughwide Linear Visualisations
#' Author: Felix Bridgeman
#' Date: 2024-04-17
#' LAST EDITED: 2025-04-20
#' ---
#'
#' Inputs:
#' - borough_lm_df.csv: CSV file containing borough-level data for linear regression analysis.
#' - borough_models_residuals.csv: CSV file containing residuals from linear models for 
#'   model m85_1, m85_2, m85_1_hec, and m85_2_hec.
#' Outputs:
#' - Multiple visualizations saved as PNG files:
#'   - spaces_detections_and_hectares_large.png
#'   - spaces_detections_CPZ_and_hectares.png
#'   - spaces_detections_CPZ_and_hectares_large.png
#'
#' Description:
#' This script generates a series of visualizations to explore relationships between controlled parking spaces, 
#' vehicle detections, CPZ (Controlled Parking Zone) coverage, and borough-level characteristics such as area, 
#' population, and density. The visualizations include scatterplots, correlation matrices, and linear regression 
#' fits. The outputs are saved as PNG files for inclusion in reports or further analysis.
#'
#' Key visualizations include:
#' - Correlation matrix of selected variables.
#' - Scatterplots of controlled spaces against vehicle detections at different confidence thresholds.
#' - Normalized comparisons (e.g., per hectare, per population).
#' - Relationships between controlled spaces and borough-level characteristics (e.g., area, population, density).
#'
#' The script uses ggplot2 and GGally for visualization, and patchwork for combining plots into layouts.
#'

# Load required libraries
library(tidyverse)
library(dplyr)
library(ggplot2)
library(GGally)

# IMPORT THE LINEAR ANALYSIS DATAFRAME `./data/results/by_borough/borough_lm_df.csv`
borough_data <- read_csv("./data/results/by_borough/borough_lm_df.csv")
residuals <- read_csv("./data/results/by_borough/borough_models_residuals.csv")

# Plot ggpairs
# e.g. a matrix of scatterplots to visualise the relationships between the variables
ggpairs(borough_data, columns = c("total_spaces",
                          "HECTARES",
                          "Onstreet.",
                          "stationary_vehicle_onstreet_075",
                          "stationary_vehicle_onstreet_085"), title = "Correlation Matrix")

# plot total spaces against stationary_vehicle_onstreet_075
ggplot(borough_data, aes(y = total_spaces/HECTARES, x = stationary_vehicle_onstreet_075/HECTARES)) +
  geom_point() +
  geom_text(aes(label = NAME), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Controlled Spaces against Detected Stationary Vehicles on Street",
       y = "Total Controlled Spaces",
       x = "Detected Stationary On-street Vehicles (0.75 minimum confidence)") +
  theme_minimal()

# plot total spaces * cpz_coverage against stationary_vehicle_onstreet_075
ggplot(borough_data, aes(y = total_spaces/HECTARES, x= stationary_vehicle_onstreet_075*CPZ_coverage/HECTARES)) +
  geom_point() +
  geom_text(aes(label = NAME), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Controlled Spaces against Detected Stationary Vehicles on Street * CPZ_coverage",
       y = "Total Controlled Spaces",
       x = "Detected Stationary On-street Vehicles * CPZ Coverage") +
  theme_minimal()

# investigate linearity variable by variable
# total spaces vs 75% confidence predictions
glin1 <- ggplot(borough_data, aes(x = stationary_vehicle_onstreet_075, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  coord_fixed() +
  labs(title = "Controlled Spaces vs. Vehicle Detections",
       subtitle = "0.75 Confidence Threshold",
       x = "Stationary On-Street Vehicle Detections",
       y = "Total Spaces") +
  theme_minimal()
glin1

# total spaces vs 85% confidence predictions
glin2 <- ggplot(borough_data, aes(x = stationary_vehicle_onstreet_085, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "",
       subtitle = "0.85 Confidence Threshold",
       x = "Stationary On-Street Vehicle Detections",
       y = "Total Spaces") +
  coord_fixed() +
  theme_minimal()
glin2

# total spaces vs CPZ coverage
glin3 <- ggplot(borough_data, aes(x = CPZ_coverage, y = total_spaces)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Controlled Parking Spaces vs. CPZ Coverage",
       x = "CPZ Coverage",
       y = "Total Spaces") +
  theme_minimal()
glin3

# total spaces vs (75% confidence predictions * CPZ coverage)
glin4 <- ggplot(borough_data, aes(x = stationary_vehicle_onstreet_075*CPZ_coverage, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "Controlled Spaces vs. Vehicle Detections x CPZ rate",
       subtitle = "0.75 Confidence Threshold",
       x = "Detections * CPZ Coverage Rate",
       y = "Total Spaces") +
  coord_fixed() +
  theme_minimal()
glin4

# total spaces vs (85% confidence predictions * CPZ coverage)
glin5 <- ggplot(borough_data, aes(x = stationary_vehicle_onstreet_085*CPZ_coverage, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "",
       subtitle = "0.85 Confidence Threshold",
       x = "Detections * CPZ Coverage Rate",
       y = "Total Spaces") +
  coord_fixed() +
  theme_minimal()
glin5

# plot spaces per hectare vs 75% confidence predictions per hectare
glin6 <- ggplot(borough_data, aes(x = predictions_per_hectare_075, y = spaces_per_hectare)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  coord_fixed() +
  labs(title = "Controlled Spaces vs. Vehicle Detections per Hectare",
       subtitle = "0.75 Confidence Threshold",
       x = "Detections per Hectare",
       y = "Controlled Spaces per Hectare") +
  theme_minimal()
glin6

# plot spaces per hectare vs 85% confidence predictions per hectare
glin7 <- ggplot(borough_data, aes(x = predictions_per_hectare_085, y = spaces_per_hectare)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "",
       subtitle = "0.85 Confidence Threshold",
       x = "Detections per Hectare",
       y = "Controlled Spaces per Hectare") +
  coord_fixed() +
  theme_minimal()
glin7

# plot spaces per hectare vs CPZ coverage
glin8 <- ggplot(borough_data, aes(x = CPZ_coverage, y = spaces_per_hectare)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "Controlled Spaces per Hectare vs. CPZ Coverage",
       x = "CPZ Coverage",
       y = "Controlled Spaces per Hectare") +
  theme_minimal()
glin8

# plot spaces over density against 75% confidence predictions over density
glin9 <- ggplot(borough_data, aes(x = predictions_over_density_075, y = spaces_over_density)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  coord_fixed() +
  labs(title = "Controlled Spaces over Density vs. Vehicle Detections over Density",
       subtitle = "0.75 Confidence Detection Threshold",
       x = "Stationary On-Street Vehicle Detections over Density",
       y = "Controlled Spaces over Density") +
  coord_fixed() +
  theme_minimal()
glin9

# plot spaces over density against 85% confidence predictions over density
glin10 <- ggplot(borough_data, aes(x = predictions_over_density_085, y = spaces_over_density)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  coord_fixed() +
  labs(title = "Controlled Spaces over Density vs. Vehicle Detections over Density",
       subtitle = "0.85 Confidence Detection Threshold",
       x = "Stationary On-Street Vehicle Detections over Density",
       y = "Controlled Spaces over Density") +
  coord_fixed() +
  theme_minimal()
glin10

# plot spaces per population against 75% confidence predictions per population
glin11 <- ggplot(borough_data, aes(x = predictions_per_population_075, y = spaces_per_population)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  coord_fixed() +
  labs(title = "Controlled Spaces per Population vs. Vehicle Detections per Population",
       subtitle = "0.75 Confidence Detection Threshold",
       x = "Stationary On-Street Vehicle Detections per Population",
       y = "Controlled Spaces per Population") +
  theme_minimal()
glin11

# plot spaces per population against 85% confidence predictions per population
glin12 <- ggplot(borough_data, aes(x = predictions_per_population_085, y = spaces_per_population)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  coord_fixed() +
  labs(title = "Controlled Spaces per Population vs. Vehicle Detections per Population",
       subtitle = "0.85 Confidence Detection Threshold",
       x = "Stationary On-Street Vehicle Detections per Population",
       y = "Controlled Spaces per Population") +
  theme_minimal()
glin12

# plot spaces vs borough population
glin13 <- ggplot(borough_data, aes(x = Population, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "Controlled Spaces vs. Population",
       x = "Population",
       y = "Controlled Spaces") +
  theme_minimal()
glin13

# plot spaces vs borough area (hectares)
glin14 <- ggplot(borough_data, aes(x = HECTARES, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "Controlled Spaces vs. Hectares",
       x = "Hectares",
       y = "Controlled Spaces") +
  theme_minimal()
glin14

# plot spaces vs borough density (population per hectare)
glin15 <- ggplot(borough_data, aes(x = Population_per_hectare, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "Controlled Spaces vs. Population per Hectare",
       x = "Population per Hectare",
       y = "Controlled Spaces") +
  theme_minimal()
glin15

# plot spaces vs (population * area)
glin16 <- ggplot(borough_data, aes(x = Population * HECTARES, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "Controlled Spaces vs. Population * Hectares",
       x = "Population * Hectares",
       y = "Controlled Spaces") +
  theme_minimal()
glin16

# plot spaces per hectare vs (75% confidence predictions * CPZ coverage)
glin17 <- ggplot(borough_data, aes(x = predictions_per_hectare_075*CPZ_coverage, y = spaces_per_hectare)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "(Normalised over Borough Area)",
       subtitle = "0.75 Confidence Threshold",
       x = "Detections * CPZ Coverage Rate / hectare",
       y = "Total Spaces / hectare") +
  coord_fixed() +
  theme_minimal()
glin17

# plot spaces per hectare vs (85% confidence predictions * CPZ coverage)
glin18 <- ggplot(borough_data, aes(x = predictions_per_hectare_085*CPZ_coverage, y = spaces_per_hectare)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "",
       subtitle = "0.85 Confidence Threshold",
       x = "Detections * CPZ Coverage Rate / hectare",
       y = "Total Spaces / hectare") +
  coord_fixed() +
  theme_minimal()
glin18

# PATCH TOGETHER PLOTS FOR REPORT
patch1 <- glin1 + glin2 + glin6 + glin7 + plot_layout(ncol = 4)

patch1 & theme_minimal(base_size = 12)
ggsave("./figs/spaces_detections_and_hectares_large.png", width = 11, height = 5, dpi = 300)

patch2 <- glin4 + glin5 + glin17 + glin18 + plot_layout(ncol = 4)
patch2 & theme_minimal(base_size = 6)
ggsave("./figs/spaces_detections_CPZ_and_hectares.png", width = 6.5, height = 3.5, dpi = 300)

patch3 <- glin2 + glin7 + glin5 + glin18 + plot_layout(ncol = 4)
patch3 & theme_minimal(base_size = 12)
ggsave("./figs/spaces_detections_CPZ_and_hectares_large.png", width = 11, height = 5, dpi = 300)


# Make RESIDUALS PLOTS of models!
# Define a named vector for the new facet labels
facet_labels <- c(
  "m85_1" = "M1.1",
  "m85_2" = "M1.2",
  "m85_1_hec" = "M1.3",
  "m85_2_hec" = "M1.4"
)

# Make a facetted residuals plot for each model
# If we want to plot more models than just those included in `residuals`, we need to
# modify the script that writes residuals in `boroughwide_linear_analysis.R`.

residuals_against_fitted <- residuals %>%
  ggplot() +
  geom_hline(yintercept = 0, color = "red", linetype = 2) +
  geom_point(aes(x = fitted, y = residuals)) +
  facet_wrap(~model, scales = "free", nrow = 1, labeller = labeller(model = facet_labels)) +
  
  theme_minimal(base_size = 8)

ggsave("./figs/residuals_against_fitted_all_borough_models.png", width = 6.5, height = 2.5, dpi = 300)

# ggplot qq plot of residuals
qq_plot <- residuals %>%
  ggplot() +
  geom_qq(aes(sample = residuals)) +
  geom_qq_line(aes(sample = residuals)) +
  facet_wrap(~model, scales = "free", nrow = 1) +
  theme_minimal(base_size = 6)

  # Create a residuals against fitted plot for models normalised over area
  # (m85_1_hec and m85_2_hec)
residuals_against_fitted2 <- residuals %>% filter(type == "hectares") %>%
  ggplot() +
  geom_hline(yintercept = 0, color = "red", linetype = 2) +
  geom_point(aes(x = fitted, y = residuals)) +
  facet_wrap(~model, scales = "free", nrow = 1) +
  theme_minimal(base_size = 12)

residuals_against_fitted2

ggsave("./figs/residuals_against_fitted_hectares_borough_models_large.png", width = 11, height = 5, dpi = 300)

# plot histograms of residuals
residuals_hist_raw <- residuals %>% filter(type == "raw") %>%
  ggplot() +
  geom_histogram(aes(x = residuals), bins = 20) +
  facet_wrap(~model, scales = "free", nrow = 1) +
  theme_minimal(base_size = 12)
residuals_hist_raw
ggsave("./figs/residuals_hist_raw_borough_models.png", width = 6.5, height = 3.5, dpi = 300)

residuals_hist_hectares <- residuals %>% filter(type == "hectares") %>%
  ggplot() +
  geom_histogram(aes(x = residuals), bins = 20) +
  facet_wrap(~model, scales = "free", nrow = 1) +
  theme_minimal(base_size = 12)
residuals_hist_hectares

ggsave("./figs/residuals_hist_hectares_borough_models.png", width = 6.5, height = 3.5, dpi = 300)


