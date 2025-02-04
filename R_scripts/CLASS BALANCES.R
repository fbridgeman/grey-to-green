
# Class balance graphs
cbd <- '/Users/felixbridgeman/My Drive/_STATS THESIS/GIS Match/CLASS BALANCES'
cb <- file.path(cbd, "class_balance.csv") %>% read_csv()
cbe <- file.path(cbd, "class_balance_enlarged.csv") %>% read_csv()

#
cb <- cb %>% mutate(Vehicle = case_when(
  str_detect(cb$"Class Name", "motorcycle") ~ "motorcyle",
  str_detect(cb$"Class Name", "car") ~ "car",
  str_detect(cb$"Class Name", "bus") ~ "bus",
  str_detect(cb$"Class Name", "bicycle") ~ "bicycle",
  str_detect(cb$"Class Name", "motorcycle") ~ "motorcycle",
  str_detect(cb$"Class Name", "light-truck") ~ "light-truck",
  str_detect(cb$"Class Name", "heavy-truck") ~ "heavy-truck",
  str_detect(cb$"Class Name", "other") ~ "other",
)) %>%
  mutate(State = case_when(
    str_detect(cb$"Class Name", "moving") ~ "moving",
    str_detect(cb$"Class Name", "onstreet") ~ "parked onstreet",
    str_detect(cb$"Class Name", "offstreet") ~ "parked offstreet",
  ))

cbe <- cbe %>% mutate(Vehicle = case_when(
  str_detect(cbe$"Class Name", "motorcycle") ~ "motorcyle",
  str_detect(cbe$"Class Name", "car") ~ "car",
  str_detect(cbe$"Class Name", "bus") ~ "bus",
  str_detect(cbe$"Class Name", "bicycle") ~ "bicycle",
  str_detect(cbe$"Class Name", "motorcycle") ~ "motorcycle",
  str_detect(cbe$"Class Name", "light-truck") ~ "light-truck",
  str_detect(cbe$"Class Name", "heavy-truck") ~ "heavy-truck",
  str_detect(cbe$"Class Name", "other") ~ "other",
)) %>%
  mutate(State = case_when(
    str_detect(cbe$"Class Name", "moving") ~ "moving",
    str_detect(cbe$"Class Name", "onstreet") ~ "parked onstreet",
    str_detect(cbe$"Class Name", "offstreet") ~ "parked offstreet",
  ))

gc1 <- ggplot(cb %>% filter(`Class Name` != "x_other"),
              aes(y = `Total Count`,
                  x = `Vehicle`,
                  fill = State)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Class Balance by Vehicle Type",
       x = "Vehicle Type",
       y = "Class Balance",
       fill = "State") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")
gc1

#gc2 is same but for cbe
gc2 <- ggplot(cbe %>% filter(`Class Name` != "x_other"),
              aes(y = `Total Count`,
                  x = `Vehicle`,
                  fill = State)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Class Balance by Vehicle Type",
       x = "Vehicle Type",
       y = "Class Balance",
       fill = "State") +
  theme_minimal(base_size = 7) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")
gc2

# group by vehicle to do percents
cb <- cb %>% group_by(Vehicle) %>%
  mutate(Percent = `Total Count` / sum(`Total Count`) * 100) %>%
  ungroup()

cbe <- cbe %>% group_by(Vehicle) %>%
  mutate(Percent = `Total Count` / sum(`Total Count`) * 100) %>%
  ungroup()

gc3 <- ggplot(cb %>% filter(`Class Name` != "x_other"),
              aes(y = Percent,
                  x = `Vehicle`,
                  fill = State)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Class Balance by Vehicle Type",
       subtitle = "(Original Dataset)",
       x = "Vehicle Type",
       y = "Proportion in Each State (%)",
       fill = "State") +
  theme_minimal(base_size = 7) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")
gc3

gc4 <- ggplot(cbe %>% filter(`Class Name` != "x_other"),
              aes(y = Percent,
                  x = `Vehicle`,
                  fill = State)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(subtitle = "(Enlarged Dataset)",
       x = "Vehicle Type",
       y = "Proportion in Each State (%)",
       fill = "State") +
  theme_minimal(base_size = 7) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")
gc4

(gc3 + gc4) / guide_area() + plot_layout(heights = c(4, 0.1))
getwd()
ggsave(file.path(cbd, "figs/class_balance.png"), width = 6.5, height = 3.5, dpi = 300)
