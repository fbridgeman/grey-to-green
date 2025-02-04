  
# deploy model on every borough
deployment_df <- counts_df
deployment_df <- deployment_df %>%
  mutate(to_predict = !(NAME %in% data_avail)) %>%
  mutate(CPZ_coverage = case_when(
    NAME == "Barking and Dagenham" ~ 0.29,
    NAME == "Barnet" ~ 0.22,
    NAME == "Bexley" ~ 0.07,
    NAME == "Brent" ~ 0.14,
    NAME == "Bromley" ~ 0.1,
    NAME == "Camden" ~ 0.98,
    NAME == "Croydon" ~ 0.1,
    NAME == "Ealing" ~ 0.47,
    NAME == "Enfield" ~ 0.14,
    NAME == "Greenwich" ~ 0.3,
    NAME == "Hackney" ~ 1,
    NAME == "Hammersmith and Fulham" ~ 0.92,
    NAME == "Haringey" ~ 0.6,
    NAME == "Harrow" ~ 0.27,
    NAME == "Havering" ~ 0.14,
    NAME == "Hillingdon" ~ 0.14,
    NAME == "Hounslow" ~ 0.36,
    NAME == "Islington" ~ 1,
    NAME == "Kensington and Chelsea" ~ 1,
    NAME == "Kingston upon Thames" ~ 0.19,
    NAME == "Lambeth" ~ 0.8,
    NAME == "Lewisham" ~ 0.21,
    NAME == "Merton" ~ 0.46,
    NAME == "Newham" ~ 0.99,
    NAME == "Redbridge" ~ 0.14,
    NAME == "Richmond upon Thames" ~ 0.2,
    NAME == "Southwark" ~ 0.6,
    NAME == "Sutton" ~ 0.16,
    NAME == "Tower Hamlets" ~ 1,
    NAME == "Waltham Forest" ~ 0.46,
    NAME == "Wandsworth" ~ 0.67,
    NAME == "Westminster" ~ 0.99,
    TRUE ~ 1.0
  )) %>%
  mutate(detections_per_hectare_085 = stationary_vehicle_onstreet_085/HECTARES)

deployment_df$preds_per_hectare <- m85_2_hec %>% predict(deployment_df) 
deployment_df$preds <- deployment_df$preds_per_hectare * deployment_df$HECTARES
sum(deployment_df$preds, na.rm = TRUE)

library(viridis)
# map preds per hectare in different colours
ggplot(deployment_df, aes(fill = preds_per_hectare)) +
  geom_sf(color = "black") +
  geom_sf_text(aes(label = NAME), size = 2) +
  scale_fill_viridis(option = "H", direction = 1) +
  theme_void() +
  coord_sf() +
  theme(legend.position = "bottom") +
  labs(title = "Predicted stationary vehicle detections per hectare",
       fill = "Predicted parking spaces per hectare") +
  coord_sf(crs = 27700) +
  theme(legend.position = "bottom")

# map preds in different colours
ggplot(deployment_df, aes(fill = preds)) +
  geom_sf(color = "black") +
  geom_sf_text(aes(label = NAME), size = 2) +
  scale_fill_viridis(option = "H", direction = 1) +
  theme_void() +
  coord_sf() +
  theme(legend.position = "bottom") +
  labs(title = "Predicted stationary vehicle detections",
       fill = "Predicted parking spaces") +
  coord_sf(crs = 27700) +
  theme(legend.position = "bottom")

deployment_df$preds2_per_hectare <- m85_1_hec %>% predict(deployment_df)
deployment_df$preds2 <- deployment_df$preds2_per_hectare * deployment_df$HECTARES
sum(deployment_df$preds2, na.rm = TRUE)

deployment_df$preds3 <- m85_1 %>% predict(deployment_df)
sum(deployment_df$preds3, na.rm = TRUE)

deployment_df$preds4 <- m85_2 %>% predict(deployment_df)
sum(deployment_df$preds4, na.rm = TRUE)

# factor
labels <- c("preds" = "M1.4",
            "preds2" = "M1.3",
            "preds3" = "M1.1",
            "preds4" = "M1.2")



deployment_df_long <- deployment_df %>%
  pivot_longer(cols = c(preds, preds2, preds3, preds4), names_to = "model", values_to = "preds")

deployment_df_long <- deployment_df_long %>%
  mutate(model = factor(model, levels = c("preds3", "preds4", "preds2", "preds"), labels = labels))

deployment_df_long$preds_all <- deployment_df_long$preds / deployment_df_long$CPZ_coverage

sums <- deployment_df_long %>%
  group_by(model) %>%
  summarise(preds_controlleds = sum(preds, na.rm = TRUE),
            preds_all = sum(preds_all, na.rm = TRUE))

sums

# map preds in different colours
ggplot(deployment_df_long, aes(fill = preds_all)) +
  geom_sf(color = "black") +
  geom_sf_text(aes(label = NAME), size = 2) +
  scale_fill_viridis(option = "H", direction = 1) +
  theme_void() +
  coord_sf() +
  theme(legend.position = "bottom") +
  labs(title = "Total Parking Space Predictions",
       fill = "Predicted parking spaces") +
  coord_sf(crs = 27700) +
  theme(legend.position = "bottom") +
  facet_wrap(~model) +
  theme(plot.title = element_text(size = 14))

ggsave("./figs/london_preds_large.eps", width = 11.125, height = 11, dpi = 300)
