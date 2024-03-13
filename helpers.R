library(tidyverse)

df <- read_csv("datasets/full_data.csv") %>% 
  drop_na() %>% 
  select(name, avg_price, cat_name, match_subcat, brand, gender_2) %>% 
  group_by(match_subcat, gender_2,cat_name) %>% 
  summarize(average = mean(avg_price)) %>% 
  ungroup() %>%
  pivot_wider(names_from = gender_2, values_from = average) %>% 
  rename(price_others = "Non-Male", price_male = Male) %>% 
  mutate(price_others = replace_na(price_others,0),
         price_male = replace_na(price_male,0)) %>% 
  rename(product = match_subcat)

cat <- df$cat_name %>% unique()

make_donut <- function(df, subcat, price_male, price_others) {
  subcat <- enquo(subcat)
  price_male <- enquo(price_male)
  price_others <- enquo(price_others)
  
  dataframe <- df %>% 
    mutate(overcharge = ifelse(price_others - price_male <= 0, 0, price_others - price_male)) %>% 
    group_by(product) %>% 
    summarise(price_others = mean(price_others),
              price_male = mean(price_male),
              overcharge = mean(overcharge))
  
  sum_male <- sum(dataframe$price_male)
  overcharge <- sum(dataframe$overcharge)
  
  # Create data frame for donut chart
  donut_data <- data.frame(
    group = c("Price Male", "Overcharge"),
    value = c(sum_male, overcharge)
  ) %>% 
    mutate(value = round(value,2))

  #Make necessary columns
  donut_data$percent = donut_data$value / sum(donut_data$value)

  donut_data$ymax = cumsum(donut_data$percent)

  donut_data$ymin = c(0, head(donut_data$ymax, n=-1))

  # Create donut chart
  donut <- ggplot(donut_data, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=group)) +
    geom_rect() +
    coord_polar(theta="y") +
    xlim(c(1, 4)) +
    geom_text(x=2.2, aes(y=(ymax + ymin)/2, label= group, color = group), size=4) +
    geom_text(x = 4.5, aes(y = (ymax + ymin)/2, label = paste0("$", value), color = group), size = 4) +
    labs(title = "Disparity in Product Pricing",
         subtitle = "Highlighting the overcharged amount of gender-based pricing") +
    theme_void() +
    theme(legend.position = "none",
          plot.title = element_text(size = 24, face = "bold"),
          plot.subtitle = element_text(size = 14, color = "gray60")) 
  return(donut)
}

make_donut(df, product, price_male, price_others)

