###############################################################
# Part 1: Working with "spatial" American Community Survey data
###############################################################
install.packages(c("tidycensus", "tidyverse"))

install.packages(c("mapview", "mapedit", "mapboxapi", 
                   "leafsync", "spdep", "segregation",
                   "ggiraph"))

library(tidycensus)

# census_api_key("YOUR KEY GOES HERE", install = TRUE)

texas_income <- get_acs(
  geography = "county",
  variables = "B19013_001",
  state = "TX",
  year = 2021,
  geometry = TRUE
)

plot(texas_income["estimate"])

library(mapview)

mapview(texas_income, zcol = "estimate")

vars <- load_variables(2021, "acs5")

View(vars)

king_income <- get_acs(
  geography = "tract",
  variables = "B19013_001",
  state = "WA",
  county = "King",
  geometry = TRUE
)

mapview(king_income, zcol = "estimate")

orange_race <- get_acs(
  geography = "tract",
  variables = c(
    Hispanic = "DP05_0071P",
    White = "DP05_0077P",
    Black = "DP05_0078P",
    Asian = "DP05_0080P"
  ),
  state = "CA",
  county = "Orange",
  geometry = TRUE
)

orange_race_wide <- get_acs(
  geography = "tract",
  variables = c(
    Hispanic = "DP05_0071P",
    White = "DP05_0077P",
    Black = "DP05_0078P",
    Asian = "DP05_0080P"
  ),
  state = "CA",
  county = "Orange",
  geometry = TRUE,
  output = "wide" #<<
)

library(tigris)
library(sf)
sf_use_s2(FALSE)

king_erase <- erase_water(king_income, 
                          area_threshold = 0.9, 
                          year = 2021)

mapview(king_erase, zcol = "estimate")


##########################
# Part 2: Mapping ACS data
##########################

library(tidyverse)

orange_hispanic <- filter(orange_race, variable == "Hispanic")

ggplot(orange_hispanic, aes(fill = estimate)) + 
  geom_sf()

ggplot(orange_hispanic, aes(fill = estimate)) + 
  geom_sf() + 
  theme_void() + 
  scale_fill_viridis_c(option = "rocket") + 
  labs(title = "Percent Hispanic by Census tract",
       subtitle = "Orange County, California",
       fill = "ACS estimate",
       caption = "2017-2021 ACS | tidycensus R package")

ggplot(orange_hispanic, aes(fill = estimate)) + 
  geom_sf() + 
  theme_void() + 
  scale_fill_viridis_b(option = "rocket", n.breaks = 6) + 
  labs(title = "Percent Hispanic by Census tract",
       subtitle = "Orange County, California",
       fill = "ACS estimate",
       caption = "2017-2021 ACS | tidycensus R package")

ggplot(orange_race, aes(fill = estimate)) + 
  geom_sf(color = NA) + 
  theme_void() + 
  scale_fill_viridis_c(option = "rocket") + 
  facet_wrap(~variable) + #<<
  labs(title = "Race / ethnicity by Census tract",
       subtitle = "Orange County, California",
       fill = "ACS estimate (%)",
       caption = "2017-2021 ACS | tidycensus R package")

orange_race_counts <- get_acs(
  geography = "tract",
  variables = c(
    Hispanic = "DP05_0071",
    White = "DP05_0077",
    Black = "DP05_0078",
    Asian = "DP05_0080"
  ),
  state = "CA",
  county = "Orange",
  geometry = TRUE
)

library(sf)

orange_black <- filter(
  orange_race_counts, 
  variable == "Black"
)

centroids <- st_centroid(orange_black)

ggplot() + 
  geom_sf(data = orange_black, color = "black", fill = "lightgrey") + 
  geom_sf(data = centroids, aes(size = estimate),
          alpha = 0.7, color = "navy") + 
  theme_void() + 
  labs(title = "Black population by Census tract",
       subtitle = "2017-2021 ACS, Orange County, California",
       size = "ACS estimate") + 
  scale_size_area(max_size = 6) #<<

orange_race_dots <- as_dot_density(
  orange_race_counts,
  value = "estimate",
  values_per_dot = 200,
  group = "variable"
)

ggplot() + 
  geom_sf(data = orange_black, color = "lightgrey", fill = "white") + 
  geom_sf(data = orange_race_dots, aes(color = variable), size = 0.01) + #<<
  scale_color_brewer(palette = "Set1") + 
  guides(color = guide_legend(override.aes = list(size = 3))) + #<<
  theme_void() + 
  labs(color = "Race / ethnicity",
       caption = "2017-2021 ACS | 1 dot = approximately 200 people")

library(viridisLite)

colors <- rocket(n = 100)

mapview(orange_hispanic, zcol = "estimate", 
        layer.name = "Percent Hispanic<br/>2017-2021 ACS",
        col.regions = colors)

library(leafsync)

orange_white <- filter(orange_race, variable == "White")

m1 <- mapview(orange_hispanic, zcol = "estimate", 
              layer.name = "Percent Hispanic<br/>2017-2021 ACS",
              col.regions = colors)

m2 <- mapview(orange_white, zcol = "estimate", 
              layer.name = "Percent White<br/>2017-2021 ACS",
              col.regions = colors)

sync(m1, m2)

state_age <- get_acs(
  geography = "state",
  variables = "B01002_001",
  year = 2021,
  survey = "acs1",
  geometry = TRUE
)

mapview(state_age, zcol = "estimate",
        col.regions = plasma(7),
        layer.name = "Median age<br/>2021 ACS")

library(tigris)

age_shifted <- shift_geometry(state_age)

ggplot(age_shifted, aes(fill = estimate)) + 
  geom_sf() + 
  scale_fill_viridis_c(option = "plasma") + 
  theme_void() + 
  labs(fill = "Median age \n2021 ACS")

library(ggiraph)

gg <- ggplot(age_shifted, aes(fill = estimate, data_id = GEOID,
                              tooltip = estimate)) + 
  geom_sf_interactive() + #<<
  scale_fill_viridis_c(option = "plasma") + 
  theme_void() + 
  labs(fill = "Median age\n2021 ACS")


girafe(ggobj = gg) %>% #<<
  girafe_options(opts_hover(css = "fill:cyan;")) #<<




####################################################################
# Part 3: Applications: segregation, diversity, and spatial analysis
####################################################################
library(segregation)

orange_race_counts %>%
  filter(variable %in% c("White", "Hispanic")) %>%
  dissimilarity(
    group = "variable",
    unit = "GEOID",
    weight = "estimate"
  )

la_race_counts <- get_acs(
  geography = "tract",
  variables = c(
    Hispanic = "DP05_0071",
    White = "DP05_0077",
    Black = "DP05_0078",
    Asian = "DP05_0080"
  ),
  state = "CA",
  county = c("Orange", "Los Angeles",
             "San Bernardino", "Riverside")
) %>%
  separate(NAME, 
           into = c("state", "county", "tract"),
           sep = ", ")

la_race_counts %>%
  filter(variable %in% c("White", "Hispanic")) %>%
  group_by(county) %>%
  group_modify(
    ~dissimilarity(
      data = .x,
      group = "variable",
      unit = "GEOID",
      weight = "estimate"
    )
  )

orange_entropy <- orange_race_counts %>%
  group_by(GEOID) %>%
  group_modify(~tibble(
    entropy = entropy(
      data = .x,
      group = "variable",
      weight = "estimate",
      base = 4
    )
  ))

orange_tracts <- tracts("CA", "Orange", year = 2021, cb = TRUE)

orange_diversity_geo <- left_join(orange_tracts, orange_entropy, by = "GEOID")

ggplot(orange_diversity_geo, aes(fill = entropy)) + 
  geom_sf() + 
  scale_fill_viridis_c(option = "mako") + 
  theme_void() + 
  labs(fill = "Entropy index")

library(spdep)

neighbors <- poly2nb(
  orange_diversity_geo, 
  queen = TRUE
)

weights <- nb2listw(neighbors)

G <- localG(
  orange_diversity_geo$entropy, 
  listw = weights
)

orange_localG <- orange_diversity_geo %>%
  mutate(localG = G, 
         Hotspot = case_when(
           localG >= 2.576 ~ "High cluster",
           localG <= -2.576 ~ "Low cluster",
           TRUE ~ "Not significant"
         ))

ggplot(orange_localG, aes(fill = Hotspot)) + 
  geom_sf(color = "grey90") + 
  scale_fill_manual(values = c("red", "blue", "grey")) + 
  theme_void()
































