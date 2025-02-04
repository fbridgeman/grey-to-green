
#
# STREETS REGRESSION.R
# 

d <- streets_results

# Data is prepared, let's get the names
names(d)
?st_join
# reassign which borough using within borough polygons NAME assign to d$borough
bp <- borough_polygons %>% select(NAME)
d <- d %>% st_join(bp, join = st_intersects) %>%
  select(-borough) %>% rename(borough = NAME) %>%
  #select(-parking_spaces2) %>%
  filter(borough %in% c("Camden", "Westminster", "Islington", "Hackney")) 

names(d)
dd <- d %>% st_drop_geometry() %>%
  filter(highway != "living_street")

# Let's see the data
head(dd)

# Let's see the correlation matrix
library(GGally)
ggpairs(dd, columns = c("parking_spaces",
                        "borough",
                        "length",
                        "stationary.vehicle.offstreet.75",
                        #"stationary.vehicle.offstreet.85",
                        "stationary.vehicle.onstreet.75",
                        #"stationary.vehicle.onstreet.85",
                        "moving.vehicle.75"
                        #"moving.vehicle.85"
                        ), title = "Correlation Matrix")

# ggplot  histograms for all vars in columns above
dd %>%
  dplyr::select(parking_spaces,
         length,
         stationary.vehicle.offstreet.75,
         stationary.vehicle.offstreet.85,
         stationary.vehicle.onstreet.75,
         stationary.vehicle.onstreet.85,
         moving.vehicle.75,
         moving.vehicle.85) %>%
  gather(key = "variable", value = "value") %>%
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30) +
  facet_wrap(~variable, scales = "free") +
  theme_minimal()

d_long <- dd %>%
  dplyr::select(osm_id,
                parking_spaces,
         length,
         highway,
         stationary.vehicle.offstreet.75,
         stationary.vehicle.offstreet.85,
         stationary.vehicle.onstreet.75,
         stationary.vehicle.onstreet.85,
         moving.vehicle.75,
         moving.vehicle.85) %>%
  pivot_longer(cols = c(-osm_id, -parking_spaces, -highway), names_to = "variable", values_to = "value")
  
glins <- d_long %>%
  ggplot(aes(x = parking_spaces, y = value, group = highway)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point(size = 0.5, aes(colour = highway)) +
  facet_wrap(~variable, scales = "free") +
  labs(title = "Parking Spaces vs. Other Variables",
       x = "Parking Spaces",
       y = "Value") +
  theme_minimal()
  
glins_res <- d_long %>% filter(highway == "residential") %>%
  ggplot(aes(x = parking_spaces, y = value, group = highway)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point(size = 0.5, aes(colour = highway)) +
  facet_wrap(~variable, scales = "free") +
  labs(title = "Parking Spaces vs. Other Variables (Residential)",
       x = "Parking Spaces",
       y = "Value") +
  theme_minimal()

glins_res

m2.1 <- lm(parking_spaces ~ stationary.vehicle.onstreet.85, data = dd)
summary(m2.1)

# set base factor as residential out of all highway cats
dd$highway <- factor(dd$highway, levels = c("residential", "secondary", "tertiary", "primary", "unclassified", "trunk", "living_street"))
m2.2 <- lm(parking_spaces ~ stationary.vehicle.onstreet.85 + highway, data = dd)
summary(m2.2)

# plot residuals ggplot
resid2.1 <- ggplot(m2.1, aes(.fitted, .resid)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs. Fitted",
       subtitle = "Model 2.1",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()

resid2.1
ggsave("./figs/resid2.1.png", resid2.1, width = 3, height = 3)

resid2.2 <- ggplot(m2.2, aes(.fitted, .resid)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs. Fitted",
       subtitle = "Model 2.2",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()
resid2.2
ggsave("./figs/resid2.2.png", resid2.2, width = 3, height = 3)

resid2.1+resid2.2
ggsave('./figs/resid2.1_resid2.2.png', resid2.1+resid2.2, width = 6.5, height = 3)

model2.3 <- lm(parking_spaces ~ stationary.vehicle.onstreet.85 *highway, data = dd)
summary(model2.3)

# plot residuals
resid2.3 <- ggplot(model2.3, aes(.fitted, .resid)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs. Fitted",
       subtitle = "Model 2.3",
       x = "Fitted Values",
       y = "Residuals") +
  theme_minimal()
resid2.3








gstationary.85a <- dd %>%
  ggplot(aes(y = parking_spaces, x = stationary.vehicle.onstreet.85)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point(size = 0.5, aes()) +
  #facet_wrap(~highway, scales = "fixed") +
  labs(title = "Parking Spaces vs. Stationary Vehicles",
       y = "Parking Spaces",
       x = "Stationary Vehicles") +
  theme_minimal(base_size = 8)

gstationary.85a
ggsave("./figs/detections_vs_spaces.png", gstationary.85a, width = 3, height = 3)


gstationary.85 <- dd %>%
  ggplot(aes(y = parking_spaces, x = stationary.vehicle.onstreet.85)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point(size = 0.5, aes(colour = highway)) +
  facet_wrap(~highway, scales = "fixed") +
  labs(title = "Parking Spaces vs. Stationary Vehicles",
       y = "Parking Spaces",
       x = "Stationary Vehicles") +
  theme_minimal(base_size = 12)
ggsave("./figs/detections_vs_spaces_by_highway_large.png", gstationary.85, width = 11, height = 5)
ggsave("./figs/detections_vs_spaces_by_highway_large.eps", gstationary.85, width = 11, height = 5)

gstationary.85

gleng_stationary.75 <- ddleng %>%
  ggplot(aes(y = parking_spaces, x = stationary.vehicle.onstreet.75)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point(size = 0.5, aes(colour = highway)) +
  facet_wrap(~highway, scales = "fixed") +
  labs(title = "Parking Spaces vs. Stationary Vehicles (Onstreet 75)",
       y = "Parking Spaces",
       x = "Stationary Vehicles") +
  theme_minimal()

gleng_stationary.75

dleng_long <- ddleng %>%
  dplyr::select(osm_id,
                parking_spaces,
         length,
         highway,
         stationary.vehicle.offstreet.75,
         stationary.vehicle.offstreet.85,
         stationary.vehicle.onstreet.75,
         stationary.vehicle.onstreet.85,
         moving.vehicle.75,
         moving.vehicle.85) %>%
  pivot_longer(cols = c(-osm_id, -parking_spaces, -highway, -length), names_to = "variable", values_to = "value")

gleng_lins <- dleng_long %>%
  ggplot(aes(x = parking_spaces, y = value)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point(size = 0.5) +
  facet_wrap(~variable, scales = "free") +
  labs(title = "Parking Spaces vs. Other Variables",
       x = "Parking Spaces",
       y = "Value") +
  theme_minimal()

gleng_lins

# divide all vars by length
ddleng <- dd %>%
  mutate(parking_spaces = parking_spaces / length,
         stationary.vehicle.offstreet.75 = stationary.vehicle.offstreet.75 / length,
         stationary.vehicle.offstreet.85 = stationary.vehicle.offstreet.85 / length,
         stationary.vehicle.onstreet.75 = stationary.vehicle.onstreet.75 / length,
         stationary.vehicle.onstreet.85 = stationary.vehicle.onstreet.85 / length,
         moving.vehicle.75 = moving.vehicle.75 / length,
         moving.vehicle.85 = moving.vehicle.85 / length)

# plot histograms for all vars in columns above
ddleng %>%
  select(parking_spaces,
         stationary.vehicle.offstreet.75,
         stationary.vehicle.offstreet.85,
         stationary.vehicle.onstreet.75,
         stationary.vehicle.onstreet.85,
         moving.vehicle.75,
         moving.vehicle.85) %>%
  gather(key = "variable", value = "value") %>%
  ggplot(aes(x = value)) +
  geom_histogram(bins = 100) +
  facet_wrap(~variable, scales = "free") +
  theme_minimal()

# plot total spaces against stationary_vehicle_onstreet_075
ggplot(dd, aes(x = parking_spaces, y = stationary.vehicle.onstreet.75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Recorded Parking Spaces vs. Stationary Vehicles",
       x = "Parking Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

# plot total spaces against stationary_vehicle_onstreet_085
ggplot(dd, aes(x = parking_spaces, y = stationary.vehicle.onstreet.85)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()
ggsave("./figs/spaces_vs_stationary_85_large.eps", width = 11, height = 5)

head(dd)
# linear model
lm1 <- lm(parking_spaces ~ stationary.vehicle.onstreet.75, data = dd)
summary(lm1)

lm2 <- lm(parking_spaces ~ stationary.vehicle.onstreet.85, data = dd)
summary(lm2)

# filter for borough = westminster

ddw <- dd %>% filter(borough == "Westminster")

# look at histograms for all vars in columns above
ddw %>%
  select(parking_spaces,
         length,
         stationary.vehicle.offstreet.75,
         stationary.vehicle.offstreet.85,
         stationary.vehicle.onstreet.75,
         stationary.vehicle.onstreet.85,
         moving.vehicle.75,
         moving.vehicle.85) %>%
  gather(key = "variable", value = "value") %>%
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30) +
  facet_wrap(~variable, scales = "free") +
  theme_minimal()

# plot total spaces against stationary_vehicle_onstreet_075
ggplot(ddw, aes(x = parking_spaces, y = stationary.vehicle.onstreet.75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

# do a linear model
lmw1 <- lm(parking_spaces ~ stationary.vehicle.onstreet.75, data = ddw)
summary(lmw1)

# remove zero entries
ddwz <- ddw %>% filter(parking_spaces > 0,
                      stationary.vehicle.onstreet.75 > 0)

# plot total spaces against stationary_vehicle_onstreet_075
ggplot(ddwz, aes(x = parking_spaces, y = stationary.vehicle.onstreet.75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

# do a linear model
lmw2 <- lm(parking_spaces ~ stationary.vehicle.onstreet.75, data = ddwz)
summary(lmw2)

# let's look at all boroughs
ddz <- dd %>% filter(parking_spaces > 0,
                    stationary.vehicle.onstreet.75 > 0)

# plot total spaces against stationary_vehicle_onstreet_075
ggplot(ddz, aes(x = parking_spaces, y = stationary.vehicle.onstreet.75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

# do a linear model
lmz <- lm(parking_spaces ~ stationary.vehicle.onstreet.75, data = ddz)
summary(lmz)

# do camden
ddc <- dd %>% filter(borough == "Camden")

# plot total spaces against stationary_vehicle_onstreet_075
ggplot(ddc, aes(x = parking_spaces, y = stationary.vehicle.onstreet.75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

# do a linear model
lmc <- lm(parking_spaces ~ stationary.vehicle.onstreet.75, data = ddc)
summary(lmc)

# do islington
ddi <- dd %>% filter(borough == "Islington")

# plot total spaces against stationary_vehicle_onstreet_075
ggplot(ddi, aes(x = parking_spaces, y = stationary.vehicle.onstreet.75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

# do a linear model
lmi <- lm(parking_spaces ~ stationary.vehicle.onstreet.75, data = ddi)
summary(lmi)

# do hackney
ddh <- dd %>% filter(borough == "Hackney")

# plot total spaces against stationary_vehicle_onstreet_075
ggplot(ddh, aes(x = parking_spaces, y = stationary.vehicle.onstreet.75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

# do a linear model
lmh <- lm(parking_spaces ~ stationary.vehicle.onstreet.75, data = ddh)
summary(lmh)

# do an lm of borough x stationary_vehicle_onstreet_75
lm_borough <- lm(parking_spaces ~ stationary.vehicle.onstreet.75 * borough, data = dd)
summary(lm_borough)

# poisson regression w ddz
poisson_model <- glm(parking_spaces ~ stationary.vehicle.onstreet.75, data = ddz, family = "poisson")
summary(poisson_model)

# step linear regression
base_model <- lm(parking_spaces ~ 1, data = dd)
upper_model <- lm(parking_spaces ~ stationary.vehicle.offstreet.75 + stationary.vehicle.onstreet.75 + moving.vehicle.75, data = dd)
step_model <- step(base_model, scope = list(lower = base_model, upper = upper_model), direction = "forward")
summary(step_model)

# repeat for 85
base_model <- lm(parking_spaces ~ 1, data = dd)
upper_model <- lm(parking_spaces ~ stationary.vehicle.offstreet.85 + stationary.vehicle.onstreet.85 + moving.vehicle.85, data = dd)
step_model <- step(base_model, scope = list(lower = base_model, upper = upper_model), direction = "forward")
summary(step_model)


# sum vehicles and use them for lm
dd$vehicles.75 <- dd$stationary.vehicle.offstreet.75 + dd$stationary.vehicle.onstreet.75 + dd$moving.vehicle.75
dd$vehicles.85 <- dd$stationary.vehicle.offstreet.85 + dd$stationary.vehicle.onstreet.85 + dd$moving.vehicle.85

lm_vehicles_75 <- lm(parking_spaces ~ vehicles.75, data = dd)
summary(lm_vehicles_75)

lm_vehicles_85 <- lm(parking_spaces ~ vehicles.85, data = dd)
summary(lm_vehicles_85)

# plot results
ggplot(dd, aes(x = parking_spaces, y = vehicles.75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Vehicles",
       x = "Total Spaces",
       y = "Detected Vehicles") +
  theme_minimal()

#plot lm1 results w borough group
ggplot(dd, aes(x = parking_spaces, y = stationary.vehicle.onstreet.75, color = borough)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

# check residuals
plot(lm2, which = 1)

# log transform dd and ddz and plot and do lms again
dd$log_parking_spaces <- log(dd$parking_spaces)
dd$log_stationary_vehicle_onstreet_75 <- log(dd$stationary.vehicle.onstreet.75)

ddz$log_parking_spaces <- log(ddz$parking_spaces)
ddz$log_stationary_vehicle_onstreet_75 <- log(ddz$stationary.vehicle.onstreet.75)



# plot total spaces against stationary_vehicle_onstreet_075
ggplot(dd, aes(x = log_parking_spaces, y = log_stationary_vehicle_onstreet_75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

ggplot(ddz, aes(x = log_parking_spaces, y = log_stationary_vehicle_onstreet_75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

# do lms again
lm3 <- lm(log_parking_spaces ~ log_stationary_vehicle_onstreet_75, data = dd)
summary(lm3)

lm4 <- lm(log_parking_spaces ~ log_stationary_vehicle_onstreet_75, data = ddz)
summary(lm4)
# compare to 1st model
summary(lm1)



# lm for ddleng
lm2 <- lm(parking_spaces ~ stationary.vehicle.onstreet.75, data = ddleng)
summary(lm2)

# plot total spaces against stationary_vehicle_onstreet_075
ggplot(ddleng, aes(x = parking_spaces, y = stationary.vehicle.onstreet.75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

# log transform w zeros removed
ddleng$log_parking_spaces <- log(ddleng$parking_spaces)
ddleng$log_stationary_vehicle_onstreet_75 <- log(ddleng$stationary.vehicle.onstreet.75)

# plot total spaces against stationary_vehicle_onstreet_075
ggplot(ddleng, aes(x = log_parking_spaces, y = log_stationary_vehicle_onstreet_75)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()



#####
# do all the boroughwise linear models again but with 85
#####
# do westminster
ddw <- dd %>% filter(borough == "Westminster")

# plot total spaces against stationary_vehicle_onstreet_075
ggplot(ddw, aes(x = parking_spaces, y = stationary.vehicle.onstreet.85)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Total Spaces vs. Stationary Vehicles",
       x = "Total Spaces",
       y = "Detected Stationary Vehicles") +
  theme_minimal()

# do a linear model
lmw1 <- lm(parking_spaces ~ stationary.vehicle.onstreet.85, data = ddw)
summary(lmw1)

# normal qq plot w annotation ggplot
ggplot(dd, aes(sample = parking_spaces)) +
  stat_qq() +
  geom_abline() +
  labs(title = "QQ Plot of Total Spaces",
       x = "Theoretical Quantiles",
       y = "Sample Quantiles") +
  theme_minimal()

# normal qq plot residuals shade confidence region
ggplot(dd, aes(sample = residuals(lm1))) +
  stat_qq() +
  geom_abline() +
  geom_ribbon(aes(ymin = -1.96, ymax = 1.96), fill = "blue", alpha = 0.2) +
  labs(title = "QQ Plot of Residuals",
       x = "Theoretical Quantiles",
       y = "Sample Quantiles") +
  theme_minimal()

library(qqplotr)
# Create the QQ plot with confidence bands
residuals_df <- data.frame(residuals = residuals(lm1))
ggplot(residuals_df, aes(sample = residuals)) +
  stat_qq_band(conf = 0.95, fill = "blue", alpha = 0.2) +  # Confidence region
  stat_qq_line(color = "red", linetype = "dashed") +       # Theoretical line
  stat_qq_point(size = 2, color = "blue") +                # QQ points
  labs(title = "Normal QQ Plot of Residuals with Confidence Band",
       x = "Theoretical Quantiles",
       y = "Sample Quantiles") +
  theme_minimal()
shapiro.test(residuals(model))


library(MASS)
boxcox(, lambda = seq(-2, 2, 0.1))  # Test range of lambda values


# ggplot hist of residuals
ggplot(dd, aes(residuals(lm1))) +
  geom_histogram(bins = 30, fill = "blue", color = "black") +
  labs(title = "Histogram of Residuals",
       x = "Residuals",
       y = "Frequency") +
  theme_minimal()

model_poisson <- glm(parking_spaces ~ stationary.vehicle.onstreet.75, 
                     family = poisson, data = dd)

summary(model_poisson)

library(AER)
dispersiontest(model_poisson)

cooks.distance(model_poisson)

plot(residuals(model_poisson, type = "deviance"))

# quasipoisson
model_quasipoisson <- glm(parking_spaces ~ stationary.vehicle.onstreet.75, 
                          family = quasipoisson, data = dd)

summary(model_quasipoisson)

# Extract residuals and fitted values
negbin_residuals <- residuals(model_quasipoisson, type = "deviance")  # Deviance residuals
negbin_fitted <- fitted(model_quasipoisson)  # Fitted values

# Create a data frame for ggplot
residuals_df <- data.frame(
  Fitted = negbin_fitted,
  Residuals = negbin_residuals
)

# Plot residuals vs fitted values
ggplot(residuals_df, aes(x = Fitted, y = Residuals)) +
  geom_point(color = "blue", alpha = 0.6) + 
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") + 
  labs(title = "Residuals vs Fitted Values (Negative Binomial)",
       x = "Fitted Values",
       y = "Deviance Residuals") +
  theme_minimal()

# neg bin
model_negbin <- glm.nb(parking_spaces ~ stationary.vehicle.onstreet.75, data = dd)

summary(model_negbin)



# Extract residuals and fitted values
negbin_residuals <- residuals(model_negbin, type = "deviance")  # Deviance residuals
negbin_fitted <- fitted(model_negbin)  # Fitted values

# Create a data frame for ggplot
residuals_df <- data.frame(
  Fitted = negbin_fitted,
  Residuals = negbin_residuals
)

# Plot residuals vs fitted values
ggplot(residuals_df, aes(x = Fitted, y = Residuals)) +
  geom_point(color = "blue", alpha = 0.6) + 
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") + 
  labs(title = "Residuals vs Fitted Values (Negative Binomial)",
       x = "Fitted Values",
       y = "Deviance Residuals") +
  theme_minimal()

# hurdle model
library(pscl)

model_hurdle <- hurdle(parking_spaces ~ stationary.vehicle.onstreet.75, 
                       data = dd, dist = "poisson")

summary(model_hurdle)

