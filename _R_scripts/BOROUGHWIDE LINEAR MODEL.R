
library(dplyr)
# combine counts_df with evaluation_df
# get names for each to check
names(counts_df)
names(evaluation_df)

head(counts_df)
head(evaluation_df)

counts_to_join <- counts_df %>% dplyr::select(NAME,
                          moving_vehicle_075:stationary_vehicle_offstreet_085)
  # remove geom
  st_drop_geometry()

data <- evaluation_df %>%
  st_drop_geometry()
data <- data %>% left_join(counts_to_join, by = c("NAME" = "NAME"))
names(density)
# get population density data
density <- read_csv("https://data.london.gov.uk/download/land-area-and-population-density-ward-and-borough/77e9257d-ad9d-47aa-aeed-59a00741f301/housing-density-borough.csv")
density <- density %>%
  dplyr::filter(Year == 2023)

density_selection <- density %>%
  dplyr::select(Name,
                Population,
                Population_per_hectare)
data <- data %>%
  left_join(density_selection, by = c("NAME" = "Name"))
density
data




# summary(data)
# corr matrix for all vars 
data %>%
  dplyr::select(HECTARES,
         "Onstreet.",
         total_spaces,
         stationary_vehicle_onstreet_075,
         stationary_vehicle_onstreet_085
         ) %>%
  cor()

# plot nicely
library(GGally)
ggpairs(data, columns = c("total_spaces",
                          "HECTARES",
                          "Onstreet.",
                          "stationary_vehicle_onstreet_075",
                          "stationary_vehicle_onstreet_085"), title = "Correlation Matrix")


# plot total spaces against stationary_vehicle_onstreet_075
ggplot(data, aes(y = total_spaces/HECTARES, x = stationary_vehicle_onstreet_075/HECTARES)) +
  geom_point() +
  geom_text(aes(label = NAME), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Controlled Spaces against Detected Stationary Vehicles on Street",
       y = "Total Controlled Spaces",
       x = "Detected Stationary On-street Vehicles (0.75 minimum confidence)") +
  theme_minimal()
data$NAME
# plot total spaces * cpz_coverage against stationary_vehicle_onstreet_075
ggplot(data, aes(y = total_spaces/HECTARES, x= stationary_vehicle_onstreet_075*CPZ_coverage/HECTARES)) +
  geom_point() +
  geom_text(aes(label = NAME), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Controlled Spaces against Detected Stationary Vehicles on Street * CPZ_coverage",
       y = "Total Controlled Spaces",
       x = "Detected Stationary On-street Vehicles * CPZ Coverage") +
  theme_minimal()

# investigate linearity
glin1 <- ggplot(data, aes(x = stationary_vehicle_onstreet_075, y = total_spaces)) +
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

glin2 <- ggplot(data, aes(x = stationary_vehicle_onstreet_085, y = total_spaces)) +
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

# CPZ coverage
glin3 <- ggplot(data, aes(x = CPZ_coverage, y = total_spaces)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Controlled Parking Spaces vs. CPZ Coverage",
       x = "CPZ Coverage",
       y = "Total Spaces") +
  theme_minimal()
glin3

# interaction
glin4 <- ggplot(data, aes(x = stationary_vehicle_onstreet_075*CPZ_coverage, y = total_spaces)) +
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

glin5 <- ggplot(data, aes(x = stationary_vehicle_onstreet_085*CPZ_coverage, y = total_spaces)) +
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

# multicollinearity between stationary_vehicle_onstreet_075 and CPZ_coverage
cor(data$stationary_vehicle_onstreet_075, data$CPZ_coverage)
# correlation test
cor.test(data$stationary_vehicle_onstreet_075, data$CPZ_coverage)
cor.test(data$stationary_vehicle_onstreet_085, data$CPZ_coverage)

# create a new variable spaces_per_hectare, as well as detections per hectare
data$spaces_per_hectare <- data$total_spaces / data$HECTARES
data$detections_per_hectare_075 <- data$stationary_vehicle_onstreet_075 / data$HECTARES
data$detections_per_hectare_085 <- data$stationary_vehicle_onstreet_085 / data$HECTARES

# plot spaces per hectare against detections per hectare
glin6 <- ggplot(data, aes(x = detections_per_hectare_075, y = spaces_per_hectare)) +
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

glin7 <- ggplot(data, aes(x = detections_per_hectare_085, y = spaces_per_hectare)) +
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

# plot relationship between cpz coverage and spaces per hectare
glin8 <- ggplot(data, aes(x = CPZ_coverage, y = spaces_per_hectare)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "Controlled Spaces per Hectare vs. CPZ Coverage",
       x = "CPZ Coverage",
       y = "Controlled Spaces per Hectare") +
  theme_minimal()
glin8









# check collinearity
cor(data$detections_per_hectare_075, data$CPZ_coverage)
cor(data$detections_per_hectare_085, data$CPZ_coverage)
cor.test(data$detections_per_hectare_075, data$CPZ_coverage)
cor.test(data$detections_per_hectare_085, data$CPZ_coverage)

# create new variables spaces and detections over density
data$spaces_over_density <- data$total_spaces / data$Population / data$HECTARES
data$detections_over_density_075 <- data$stationary_vehicle_onstreet_075 / data$Population / data$HECTARES
data$detections_over_density_085 <- data$stationary_vehicle_onstreet_085 / data$Population / data$HECTARES

# plot relationship between spaces over density and detections over density
glin9 <- ggplot(data, aes(x = detections_over_density_075, y = spaces_over_density)) +
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

glin10 <- ggplot(data, aes(x = detections_over_density_085, y = spaces_over_density)) +
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

# check collinearity
cor(data$detections_over_density_075, data$Population_per_hectare)
cor(data$detections_over_density_085, data$Population_per_hectare)
cor.test(data$detections_over_density_075, data$Population_per_hectare)
cor.test(data$detections_over_density_085, data$Population_per_hectare)

# make detections / Population and spaces / Population
data$spaces_per_population <- data$total_spaces / data$Population
data$detections_per_population_075 <- data$stationary_vehicle_onstreet_075 / data$Population
data$detections_per_population_085 <- data$stationary_vehicle_onstreet_085 / data$Population

# plot relationship between spaces per population and detections per population
glin11 <- ggplot(data, aes(x = detections_per_population_075, y = spaces_per_population)) +
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

glin12 <- ggplot(data, aes(x = detections_per_population_085, y = spaces_per_population)) +
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


# plot relationship between total_spaces and population
glin13 <- ggplot(data, aes(x = Population, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "Controlled Spaces vs. Population",
       x = "Population",
       y = "Controlled Spaces") +
  theme_minimal()
glin13

# plot relationship between total_spaces and HECTARES
glin14 <- ggplot(data, aes(x = HECTARES, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "Controlled Spaces vs. Hectares",
       x = "Hectares",
       y = "Controlled Spaces") +
  theme_minimal()
glin14

# plot relationship between total_spaces and Population_per_hectare
glin15 <- ggplot(data, aes(x = Population_per_hectare, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "Controlled Spaces vs. Population per Hectare",
       x = "Population per Hectare",
       y = "Controlled Spaces") +
  theme_minimal()
glin15

# plot relationship between total_spaces and Population*HECTARES
glin16 <- ggplot(data, aes(x = Population * HECTARES, y = total_spaces)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point() +
  geom_text_repel(aes(label = NAME), size = 6/.pt) +
  labs(title = "Controlled Spaces vs. Population * Hectares",
       x = "Population * Hectares",
       y = "Controlled Spaces") +
  theme_minimal()
glin16
data$NAME
glin17 <- ggplot(data, aes(x = detections_per_hectare_075*CPZ_coverage, y = spaces_per_hectare)) +
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

glin18 <- ggplot(data, aes(x = detections_per_hectare_085*CPZ_coverage, y = spaces_per_hectare)) +
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

# check collinearity
cor(data$detections_per_population_075, data$Population)
cor(data$detections_per_population_085, data$Population)
cor.test(data$detections_per_population_075, data$Population)
cor.test(data$detections_per_population_085, data$Population)
names(data)


# check VIF between variables
m75_1 <- lm(total_spaces ~ stationary_vehicle_onstreet_075, data = data)
m75_2 <- lm(total_spaces ~ stationary_vehicle_onstreet_075:CPZ_coverage, data = data)
m75_3 <- lm(total_spaces ~ stationary_vehicle_onstreet_075*CPZ_coverage, data = data)

m75_1_hec <- lm(spaces_per_hectare ~ detections_per_hectare_075, data = data)
m75_2_hec <- lm(spaces_per_hectare ~ detections_per_hectare_075:CPZ_coverage, data = data)
m75_3_hec <- lm(spaces_per_hectare ~ detections_per_hectare_075*CPZ_coverage, data = data)

m75_1_den <- lm(spaces_over_density ~ detections_over_density_075, data = data)
m75_2_den <- lm(spaces_over_density ~ detections_over_density_075:CPZ_coverage, data = data)
m75_3_den <- lm(spaces_over_density ~ detections_over_density_075*CPZ_coverage, data = data)

m75_1_pop <- lm(spaces_per_population ~ detections_per_population_075, data = data)
m75_2_pop <- lm(spaces_per_population ~ detections_per_population_075:CPZ_coverage, data = data)
m75_3_pop <- lm(spaces_per_population ~ detections_per_population_075*CPZ_coverage, data = data)

m85_1 <- lm(total_spaces ~ stationary_vehicle_onstreet_085, data = data)
m85_2 <- lm(total_spaces ~ stationary_vehicle_onstreet_085:CPZ_coverage, data = data)
m85_3 <- lm(total_spaces ~ stationary_vehicle_onstreet_085*CPZ_coverage, data = data)

m85_1_hec <- lm(spaces_per_hectare ~ detections_per_hectare_085, data = data)
m85_2_hec <- lm(spaces_per_hectare ~ detections_per_hectare_085:CPZ_coverage, data = data)
m85_3_hec <- lm(spaces_per_hectare ~ detections_per_hectare_085*CPZ_coverage, data = data)

m85_1_den <- lm(spaces_per_population ~ detections_over_density_085, data = data)
m85_2_den <- lm(spaces_per_population ~ detections_over_density_085:CPZ_coverage, data = data)
m85_3_den <- lm(spaces_per_population ~ detections_over_density_085*CPZ_coverage, data = data)

m85_1_pop <- lm(spaces_per_population ~ detections_per_population_085, data = data)
m85_2_pop <- lm(spaces_per_population ~ detections_per_population_085:CPZ_coverage, data = data)
m85_3_pop <- lm(spaces_per_population ~ detections_per_population_085*CPZ_coverage, data = data)

vif(m75_3)
vif(m75_3_hec)
vif(m75_3_den)
vif(m75_3_pop)

data_red <- data %>% dplyr::filter(NAME %in% c("Camden", "Islington", "Westminster", "Hackney"))







patch1 <- glin1 + glin2 + glin6 + glin7 + plot_layout(ncol = 4)

patch1 & theme_minimal(base_size = 12)
ggsave("./figs/spaces_detections_and_hectares_large.png", width = 11, height = 5, dpi = 300)

patch2 <- glin4 + glin5 + glin17 + glin18 + plot_layout(ncol = 4)
patch2 & theme_minimal(base_size = 6)
ggsave("./figs/spaces_detections_CPZ_and_hectares.png", width = 6.5, height = 3.5, dpi = 300)

patch3 <- glin2 + glin7 + glin5 + glin18 + plot_layout(ncol = 4)
patch3 & theme_minimal(base_size = 12)
ggsave("./figs/spaces_detections_CPZ_and_hectares_large.png", width = 11, height = 5, dpi = 300)

# models of interest: m75_1, m75_2, m75_1_hec, m75_2_hec, m85_1, m85_2, m85_1_hec, m85_2_hec
summary(m75_1)
summary(m85_1)

summary(m75_2)
summary(m85_2)

summary(m75_1_hec)
summary(m85_1_hec)

summary(m75_2_hec)
summary(m85_2_hec)

# create a residuals against fitted plot df so we can facet
residuals <- data_frame(
  fitted = c(
             fitted(m85_1), fitted(m85_2), fitted(m85_1_hec), fitted(m85_2_hec)),
  residuals = c(
                resid(m85_1), resid(m85_2), resid(m85_1_hec), resid(m85_2_hec)),
  model = rep(c("m85_1", "m85_2", "m85_1_hec", "m85_2_hec"), each = nrow(data)),
  type = rep(c("raw", "hectares"), each = nrow(data)*2)) %>%
  mutate(model = factor(model, levels = c("m85_1", "m85_2", "m85_1_hec", "m85_2_hec")))

# Define a named vector for the new facet labels
facet_labels <- c(
  "m85_1" = "M1.1",
  "m85_2" = "M1.2",
  "m85_1_hec" = "M1.3",
  "m85_2_hec" = "M1.4"
)

residuals_against_fitted <- residuals %>%
  ggplot() +
  geom_hline(yintercept = 0, color = "red", linetype = 2) +
  geom_point(aes(x = fitted, y = residuals)) +
  facet_wrap(~model, scales = "free", nrow = 1, labeller = labeller(model = facet_labels)) +
  
  theme_minimal(base_size = 8)

residuals_against_fitted

ggsave("./figs/residuals_against_fitted_all_borough_models.png", width = 6.5, height = 2.5, dpi = 300)

# ggplot qq plot of residuals
qq_plot <- residuals %>%
  ggplot() +
  geom_qq(aes(sample = residuals)) +
  geom_qq_line(aes(sample = residuals)) +
  facet_wrap(~model, scales = "free", nrow = 1) +
  theme_minimal(base_size = 6)

qq_plot





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






# create a linear model
m75_1 <- lm(total_spaces ~ stationary_vehicle_onstreet_075, data = data)
summary(m75_1)

m75_2 <- lm(total_spaces ~ stationary_vehicle_onstreet_075:CPZ_coverage, data = data)
summary(m75_2)

m75_3 <- lm(total_spaces ~ stationary_vehicle_onstreet_075*CPZ_coverage, data = data)
summary(m75_3)

# same for 0.85 conf
m85_1 <- lm(total_spaces ~ stationary_vehicle_onstreet_085, data = data)
summary(m85_1)

m85_2 <- lm(total_spaces ~ stationary_vehicle_onstreet_085:CPZ_coverage, data = data)
summary(m85_2)

m85_3 <- lm(total_spaces ~ stationary_vehicle_onstreet_085*CPZ_coverage, data = data)
summary(m85_3)

# use k-folds to predict num parking spaces using m85_3 eqn
library(caret)
set.seed(123)
folds <- createFolds(data$total_spaces, k = 10)
folds
# predict in each fold
predictions <- lapply(folds, function(fold) {
  
  # fit model on all data except fold
  model <- lm(total_spaces ~ stationary_vehicle_onstreet_085*CPZ_coverage, data = data[-fold,])
  # predict on fold
  predict(model, newdata = data[fold,])
})

#append k-folds predictions to data
data$predictions <- unlist(predictions)



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
ggplot(m85_3, aes(x = .fitted, y = data$total_spaces)) +
  geom_text(aes(label = data$NAME), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_point(color = "red")+
  geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
  labs(title = "Fitted vs. Actual Values",
       x = "Fitted Values",
       y = "Actual Values") +
  theme_minimal()

m85_1 <- lm(total_spaces ~ stationary_vehicle_onstreet_085, data = data)
summary(m85_1)




# names
names(evaluation_df)
regress_df_75 <- evaluation_df %>%
  select(NAME, total_spaces, stationary_vehicle_onstreet_075, stationary_vehicle_onstreet_085,
         HECTARES, "Onstreet.", inner, geometry)
regress_df_85 <- evaluation_df %>%
  select(NAME, total_spaces, stationary_vehicle_onstreet_075, stationary_vehicle_onstreet_085,
         HECTARES, "Onstreet.", inner, geometry)

# rename onstreet.
names(regress_df_75)[names(regress_df_75) == "Onstreet."] <- "onstreet_ndvi"
names(regress_df_85)[names(regress_df_85) == "Onstreet."] <- "onstreet_ndvi"

# stepwise regression for total parking spaces
model <- lm(total_spaces ~ stationary_vehicle_onstreet_085 *
              #stationary_vehicle_offstreet_085 +
              HECTARES * onstreet_ndvi *
              inner, data = regress_df)
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
     HECTARES + inner, data = regress_df)
summary(step_result_85)

data = regress_df_75

# Base model (intercept only)
base_model <- lm(total_spaces ~ 1, data = data)

# Full model (main effects + two-way interactions)
full_model <- lm(total_spaces ~ (stationary_vehicle_onstreet_075 + 
                                   HECTARES + 
                                   onstreet_ndvi + 
                                   inner)^2, data = data)

# Stepwise regression using both directions
stepwise_model <- step(base_model, 
                       scope = list(lower = base_model, upper = full_model),
                       direction = "both",
                       trace = TRUE)

# Summary of the selected model
summary(stepwise_model)

# Plot Cook's distance
plot(cooks.distance(stepwise_model), pch = 19, frame = FALSE, 
     xlab = "Observation", ylab = "Cook's distance", 
     main = "Cook's distance plot")
# label residual with high cooks distance
text(x = 1:nrow(data), y = cooks.distance(stepwise_model), 
     labels = ifelse(cooks.distance(stepwise_model) > 0.1, names(data), NA), 
     pos = 3)

# plot residuals
ggplot(stepwise_model, aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs. Fitted Values",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()

# plot hectares against total spaces for inner boroughs
# label each borough
ggplot(data, aes(x = HECTARES, y = total_spaces)) +
  geom_point() +
  geom_text(aes(label = NAME), check_overlap = TRUE, vjust = 1, hjust = 1) +
  labs(title = "Hectares vs. Total Spaces for Inner Boroughs",
       x = "Hectares",
       y = "Total Spaces") +
  theme_minimal()
# plot residuals with labelled points
ggplot(stepwise_model, aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_text(aes(label = NAME), check_overlap = TRUE, vjust = 1, hjust = 1) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs. Fitted Values",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()

model <- lm(total_spaces ~ stationary_vehicle_onstreet_075, data = regress_df)

# Calculate standardized residuals
standardized_res <- rstandard(model)

# Calculate studentized residuals
studentized_res <- rstudent(model)

# Plot residuals vs. fitted values
# Load libraries
library(ggplot2)
library(broom)

# Fit the model
model <- lm(total_spaces ~ stationary_vehicle_onstreet_075, data = regress_df)

# Extract model diagnostics with augment()
model_diagnostics <- augment(model)
model_diagnostics$NAME <- regress_df$NAME
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
