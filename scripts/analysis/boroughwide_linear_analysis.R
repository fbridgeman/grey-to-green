#' ---
#' boroughwide_linear_analysis.R
#' Title: Boroughwide Linear Analysis
#' Author: Felix Bridgeman
#' Date: 2024-04-17
#' LAST EDITED: 2025-04-20
#' ---
#'
#' Inputs:
#' - borough_lm_df.csv: CSV file containing borough-level data for linear regression analysis.
#'
#' Outputs:
#' - borough_models_residuals.csv: CSV file containing residuals from linear models for 
#'   models m85_1, m85_2, m85_1_hec, and m85_2_hec. (This is used for visualisations in
#'   boroughwide_linear_analysis.R)
#' 
#' - Multiple visualizations are made here due to code limitations of doing it in another
#'   script:
#'   - Residuals vs. Fitted Values plots for various models.
#'   - Fitted vs. Actual Values plots for selected models.
#'   - Cook's distance plot for stepwise regression models.
#'   - Scatterplots of borough characteristics (e.g., hectares vs. total spaces).
#'
#' Description:
#' This script performs borough-level linear regression analysis to explore relationships between 
#' controlled parking spaces, vehicle detections, CPZ (Controlled Parking Zone) coverage, and borough-level 
#' characteristics such as area, population, and density. It includes correlation analysis, model fitting, 
#' stepwise regression, and residual diagnostics. The script also generates visualizations to assess model 
#' performance and relationships between variables.
#'
#' Key analyses include:
#' - Correlation testing between variables.
#' - Linear regression models at different confidence thresholds (75% and 85%).
#' - Stepwise regression to identify significant predictors.
#' - Residual diagnostics and Cook's distance analysis.
#' - K-fold cross-validation for model evaluation.
#'
#' The script uses ggplot2, dplyr, and caret for analysis and visualization.
#'


# Load libraries
library(tidyverse)
library(dplyr)
library(caret)
library(ggplot2)
library(broom)
set.seed(123)

# IMPORT THE LINEAR ANALYSIS DATAFRAME `./data/results/by_borough/borough_lm_df.csv`
borough_data <- st_read("./data/results/by_borough/borough_lm_df.shp")

# remove geometry but preserve it in borough_data_shp
borough_data_shp <- borough_data
borough_data <- borough_data %>%
  st_drop_geometry()

summary(borough_data)
# corr matrix for all vars 

# we check correlation between the variables
borough_data %>%
  dplyr::select(HECTARES,
         "Onstreet.",
         total_spaces,
         stationary_vehicle_onstreet_075,
         stationary_vehicle_onstreet_085
         ) %>%
  cor()

# PAIRWISE CORRELATION TESTING

# check collinearity between total spaces and CPZ coverage
cor(borough_data$stationary_vehicle_onstreet_075, borough_data$CPZ_coverage)
cor(borough_data$stationary_vehicle_onstreet_085, borough_data$CPZ_coverage)
cor.test(borough_data$stationary_vehicle_onstreet_075, borough_data$CPZ_coverage)
cor.test(borough_data$stationary_vehicle_onstreet_085, borough_data$CPZ_coverage)

# check collinearity of predictions per hectare and CPZ coverage
cor(borough_data$predictions_per_hectare_075, borough_data$CPZ_coverage)
cor(borough_data$predictions_per_hectare_085, borough_data$CPZ_coverage)
cor.test(borough_data$predictions_per_hectare_075, borough_data$CPZ_coverage)
cor.test(borough_data$predictions_per_hectare_085, borough_data$CPZ_coverage)

# check collinearity of predictions over density and population
cor(borough_data$predictions_over_density_075, borough_data$Population_per_hectare)
cor(borough_data$predictions_over_density_085, borough_data$Population_per_hectare)
cor.test(borough_data$predictions_over_density_075, borough_data$Population_per_hectare)
cor.test(borough_data$predictions_over_density_085, borough_data$Population_per_hectare)

# check collinearity of predictions per population and population
cor(borough_data$predictions_per_population_075, borough_data$Population)
cor(borough_data$predictions_per_population_085, borough_data$Population)
cor.test(borough_data$predictions_per_population_075, borough_data$Population)
cor.test(borough_data$predictions_per_population_085, borough_data$Population)


### CREATE LINEAR MODELS!!!
# model code:
# 1st number (75 or 85) = confidence level
# 2nd number (1, 2, 3) = model number
## 1: just by predictions alone
## 2: by (predictions:CPZ coverage)
## 3: by (predictions*CPZ coverage)

# 1st letter: scaling by area (hectare), density, or population
## _hec: by area
## _den: by density
## _pop: by population

m75_1 <- lm(total_spaces ~ stationary_vehicle_onstreet_075, data = borough_data)
m75_2 <- lm(total_spaces ~ stationary_vehicle_onstreet_075:CPZ_coverage, data = borough_data)
m75_3 <- lm(total_spaces ~ stationary_vehicle_onstreet_075*CPZ_coverage, data = borough_data)

m75_1_hec <- lm(spaces_per_hectare ~ predictions_per_hectare_075, data = borough_data)
m75_2_hec <- lm(spaces_per_hectare ~ predictions_per_hectare_075:CPZ_coverage, data = borough_data)
m75_3_hec <- lm(spaces_per_hectare ~ predictions_per_hectare_075*CPZ_coverage, data = borough_data)

m75_1_den <- lm(spaces_over_density ~ predictions_over_density_075, data = borough_data)
m75_2_den <- lm(spaces_over_density ~ predictions_over_density_075:CPZ_coverage, data = borough_data)
m75_3_den <- lm(spaces_over_density ~ predictions_over_density_075*CPZ_coverage, data = borough_data)

m75_1_pop <- lm(spaces_per_population ~ predictions_per_population_075, data = borough_data)
m75_2_pop <- lm(spaces_per_population ~ predictions_per_population_075:CPZ_coverage, data = borough_data)
m75_3_pop <- lm(spaces_per_population ~ predictions_per_population_075*CPZ_coverage, data = borough_data)

m85_1 <- lm(total_spaces ~ stationary_vehicle_onstreet_085, data = borough_data)
m85_2 <- lm(total_spaces ~ stationary_vehicle_onstreet_085:CPZ_coverage, data = borough_data)
m85_3 <- lm(total_spaces ~ stationary_vehicle_onstreet_085*CPZ_coverage, data = borough_data)

m85_1_hec <- lm(spaces_per_hectare ~ predictions_per_hectare_085, data = borough_data)
m85_2_hec <- lm(spaces_per_hectare ~ predictions_per_hectare_085:CPZ_coverage, data = borough_data)
m85_3_hec <- lm(spaces_per_hectare ~ predictions_per_hectare_085*CPZ_coverage, data = borough_data)

m85_1_den <- lm(spaces_per_population ~ predictions_over_density_085, data = borough_data)
m85_2_den <- lm(spaces_per_population ~ predictions_over_density_085:CPZ_coverage, data = borough_data)
m85_3_den <- lm(spaces_per_population ~ predictions_over_density_085*CPZ_coverage, data = borough_data)

m85_1_pop <- lm(spaces_per_population ~ predictions_per_population_085, data = borough_data)
m85_2_pop <- lm(spaces_per_population ~ predictions_per_population_085:CPZ_coverage, data = borough_data)
m85_3_pop <- lm(spaces_per_population ~ predictions_per_population_085*CPZ_coverage, data = borough_data)

# check VIF between variables
vif(m75_3)
vif(m75_3_hec)
vif(m75_3_den)
vif(m75_3_pop)

# LINEAR ANALYSIS SUMMARY RESULTS
# models of interest: m75_1, m75_2, m75_1_hec, m75_2_hec, m85_1, m85_2, m85_1_hec, m85_2_hec
summary(m75_1)
summary(m85_1)

summary(m75_2)
summary(m85_2)

summary(m75_1_hec)
summary(m85_1_hec)

summary(m75_2_hec)
summary(m85_2_hec)

data_red <- borough_data %>% dplyr::filter(NAME %in% c("Camden", "Islington", "Westminster", "Hackney"))

###############################################################################
# create a residuals against fitted plot df so we can facet
residuals <- data_frame(
  fitted = c(
             fitted(m85_1), fitted(m85_2), fitted(m85_1_hec), fitted(m85_2_hec)),
  residuals = c(
                resid(m85_1), resid(m85_2), resid(m85_1_hec), resid(m85_2_hec)),
  model = rep(c("m85_1", "m85_2", "m85_1_hec", "m85_2_hec"), each = nrow(borough_data)),
  type = rep(c("raw", "hectares"), each = nrow(borough_data)*2)) %>%
  mutate(model = factor(model, levels = c("m85_1", "m85_2", "m85_1_hec", "m85_2_hec")))

# save residuals to csv
write_csv(residuals, "./data/results/by_borough/borough_models_residuals.csv")

###############################################################################################

### INCOMPLETE: K-FOLDS CROSS VALIDATION
# use k-folds to predict num parking spaces using m85_3 eqn
# equation: total_spaces ~ stationary_vehicle_onstreet_085*CPZ_coverage

# create folds
folds <- createFolds(borough_data$total_spaces, k = 10)
folds

# predict in each fold
predictions <- lapply(folds, function(fold) {
  
  # fit model on all data except fold
  model <- lm(total_spaces ~ stationary_vehicle_onstreet_085*CPZ_coverage, data = borough_data[-fold,])
  # predict on fold
  predict(model, newdata = borough_data[fold,])
})

#append k-folds predictions to data
borough_data$k_fold_m85_3_preds <- unlist(predictions)

###############################################################################################


# ggplot fitted vs residuals of m75_3
ggplot(m75_3, aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs. Fitted Values",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()

# ggplot fitted vs residuals of m85_3
ggplot(m85_3, aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs. Fitted Values",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()
m85_3.fitted

# plot fitted vs actual of m85_3
ggplot(m85_3, aes(x = .fitted, y = borough_data$total_spaces)) +
  geom_text(aes(label = borough_data$NAME), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_point(color = "red")+
  geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
  labs(title = "Fitted vs. Actual Values",
       x = "Fitted Values",
       y = "Actual Values") +
  theme_minimal()

## IMPORTING DATA FOR STEPWISE REGRESSION FROM borough_data_shp
# names
names(borough_data_shp)
regress_df_75 <- borough_data_shp %>%
  select(NAME, total_spaces, stationary_vehicle_onstreet_075, stationary_vehicle_onstreet_085,
         HECTARES, "Onstreet.", inner, geometry)
regress_df_85 <- borough_data_shp %>%
  select(NAME, total_spaces, stationary_vehicle_onstreet_075, stationary_vehicle_onstreet_085,
         HECTARES, "Onstreet.", inner, geometry)

# rename onstreet.
names(regress_df_75)[names(regress_df_75) == "Onstreet."] <- "onstreet_ndvi"
names(regress_df_85)[names(regress_df_85) == "Onstreet."] <- "onstreet_ndvi"


### STEPWISE REGRESSION FOR TOTAL PARKING SPACES (THIS DID NOT NECESSARILY
### PRODUCE THE BEST RESULTS AT THE TIME OF WRITING THE THESIS IN DEC 24)
# stepwise regression for total parking spaces
model <- lm(total_spaces ~ stationary_vehicle_onstreet_085 *
              #stationary_vehicle_offstreet_085 +
              HECTARES * onstreet_ndvi *
              inner, data = regress_df_85)
summary(model)

# find the best predictors
step(model)

# plot residuals
ggplot(model, aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs. Fitted Values",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()

step_result_85 <- lm(formula = total_spaces ~ stationary_vehicle_onstreet_085 + 
     HECTARES + inner, data = regress_df_85)
summary(step_result_85)

# CREATE A BASE MODEL
# Base model (intercept only)
base_model <- lm(total_spaces ~ 1, data = regress_df_75)

# CREATE A FULL MODEL
# Full model (main effects + two-way interactions)
full_model_75 <- lm(total_spaces ~ (stationary_vehicle_onstreet_075 + 
                                    HECTARES + 
                                    onstreet_ndvi + 
                                    inner)^2, data = regress_df_75)

# 2 WAY STEPWISE REGRESSION
# Stepwise regression using both directions
stepwise_model_75 <- step(base_model, 
                          scope = list(lower = base_model, upper = full_model),
                          direction = "both",
                          trace = TRUE)

# Summary of the selected model
summary(stepwise_model_75)

# Plot Cook's distance of the 75 confidence stepwise model
plot(cooks.distance(stepwise_model_75), pch = 19, frame = FALSE, 
     xlab = "Observation", ylab = "Cook's distance", 
     main = "Cook's distance plot")

# label residual with high cooks distance
text(x = 1:nrow(borough_data_shp), y = cooks.distance(stepwise_model), 
     labels = ifelse(cooks.distance(stepwise_model) > 0.1, names(borough_data), NA), 
     pos = 3)

# plot residuals
ggplot(stepwise_model_75, aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs. Fitted Values",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()

# plot hectares against total spaces for inner boroughs
# label each borough
ggplot(regress_df_75, aes(x = HECTARES, y = total_spaces)) +
  geom_point() +
  geom_text(aes(label = NAME), check_overlap = TRUE, vjust = 1, hjust = 1) +
  labs(title = "Hectares vs. Total Spaces for Inner Boroughs",
       x = "Hectares",
       y = "Total Spaces") +
  theme_minimal()

# plot residuals with labelled points
ggplot(stepwise_model_75, aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_text(aes(label = NAME), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs. Fitted Values",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()

### INCOMPLETE: CALCULATE RESIDUALS AND EXTRACT DIAGNOSTICS FOR MOST SIMPLE MODEL

model <- lm(total_spaces ~ stationary_vehicle_onstreet_075, data = regress_df_75)

# Calculate standardized residuals
standardized_res <- rstandard(model)

# Calculate studentized residuals
studentized_res <- rstudent(model)

# Extract model diagnostics with augment()
model_diagnostics <- augment(model)
model_diagnostics$NAME <- regress_df_75$NAME
# Add a column to label large residuals (|.std.resid| > 2)
model_diagnostics$label <- ifelse(abs(rstandard(model)) > 2, rownames(model_diagnostics), "")

# Plot Residuals vs Fitted values in ggplot
ggplot(model_diagnostics, aes(x = .fitted, y = .resid)) +
  geom_point(color = "blue") +
  geom_text(aes(label = NAME), vjust = -0.5, hjust = 1, check_overlap = TRUE) +
  geom_hline(yintercept = 0, linetype = "dashed") +  # Residual = 0 line
  geom_hline(yintercept = c(-2, 2), linetype = "dotted", color = "red") +  # Threshold lines
  labs(title = "Residuals vs Fitted Values",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()

# Find large standardized residuals
large_residuals <- which(abs(standardized_res) > 2)
print(large_residuals)

# Print corresponding rows in the dataset
regress_df[large_residuals, ]
