
# Crossover checks

## Indian N-S

```{r IO_NS_data}

IO_NS_cruises <- c(249, 250,
                   352, 353,
                   1046,
                   3035)

IO_NS_GLODAP_grid <- GLODAP %>%
  filter(basin_AIP == "Indian",
         lon > 70,
         lon < 100,
         cruise %in% IO_NS_cruises
  ) %>%
  mutate(cruise = as.factor(cruise)) %>%
  distinct(lon, lat, cruise, year = as.factor(year(date)))

map +
  geom_tile(data = IO_NS_GLODAP_grid,
            aes(lon, lat, fill = year)) +
  facet_wrap(~ year)


IO_NS <- GLODAP %>%
  filter(cruise %in% IO_NS_cruises)

IO_NS <- IO_NS %>%
  mutate(
    cstar = tco2  - (117 * phosphate)  - 0.5 * (talk - (16 * phosphate)),
    cstar_tco2 = tco2,
    cstar_talk = -0.5 * talk,
    cstar_phosphate = -117 * phosphate + 16 * 0.5 * phosphate
  )


IO_NS <- IO_NS %>%
  select(year,
         lon, lat, depth,
         cruise, station, cast,
         temp, sal, gamma,
         tco2, talk, phosphate,
         starts_with("cstar"))


IO_NS <- IO_NS %>%
  mutate(year = if_else(year == 1994, 1995, year),
         year = as.factor(as.character(year)))

IO_NS <- IO_NS %>%
  filter(lon < 98)

IO_NS <- IO_NS %>%
  filter(lat > -25,
         lat < 0,
         depth > 2000,
         depth < 4000,
         !(lat %in% c(-18.5,-5.5)))

map +
  geom_tile(data = IO_NS %>%
              distinct(lon, lat, year),
            aes(lon, lat, fill = year)) +
  facet_wrap(~ year, ncol = 2)


IO_NS <- IO_NS %>%
  pivot_longer(temp:cstar_phosphate,
               names_to = "parameter",
               values_to = "value")

```

### Section

```{r IO_NS_sections}


IO_NS %>%
  group_split(parameter) %>%
  # head(1) %>%
  map(
    ~ ggplot(data = .x,
             aes(lat , depth, col = value)) +
      geom_point() +
      scale_color_viridis_c(name = unique(.x$parameter)) +
      scale_y_reverse() +
      facet_grid(year ~ .)
  )


```

### Profiles, absolute

```{r IO_NS_profiles, fig.asp=2}

IO_NS %>%
  arrange(depth) %>%
  group_split(parameter) %>%
  # head(1) %>%
  map(
    ~ ggplot(data = .x,
             aes(
               value , depth, fill = year,
             )) +
      geom_point(shape = 21) +
      scale_fill_scico_d(direction = -1) +
      scale_y_reverse() +
      labs(x = unique(.x$parameter)) +
      facet_wrap( ~ lat, ncol = 3)
  )

```


```{r IO_NS_profiles_gridded, fig.asp=1.5}

IO_NS_grid <- IO_NS %>%
  select(lat, lon, depth, year, parameter, value) %>%
  mutate(depth = as.numeric(as.character(cut(depth,
                                             seq(0,1e4, 500),
                                             seq(250,1e4,500))))) %>%
  group_by(lat, depth, year, parameter) %>%
  summarise(value = mean(value, na.rm=TRUE)) %>%
  ungroup()


IO_NS_grid %>%
  group_by(depth, year, parameter) %>%
  summarise(value = mean(value, na.rm = TRUE)) %>%
  ungroup() %>%
  ggplot(aes(value , depth, fill = year)) +
  geom_point(shape = 21) +
  scale_fill_scico_d(direction = -1) +
  scale_y_reverse() +
  facet_wrap(~ parameter, scales = "free_x", ncol = 3)

```

### Profiles, offset

```{r IO_NS_profiles_gridded_offset, fig.asp=2}

IO_NS_grid_offset <- IO_NS_grid %>%
  arrange(year) %>%
  group_by(lat, depth, parameter) %>%
  mutate(delta_value = value - lag(value),
         delta_year = paste(lag(year), year, sep = "-")) %>%
  ungroup() %>%
  drop_na()

IO_NS_grid_offset %>%
  group_split(parameter) %>%
  # head(1) %>%
  map(
    ~ ggplot(data = .x,
             aes(
               delta_value , depth, fill = delta_year,
             )) +
      geom_vline(xintercept = 0) +
      geom_point(shape = 21) +
      scale_fill_scico_d(direction = -1) +
      scale_y_reverse() +
      labs(x = unique(.x$parameter)) +
      facet_wrap( ~ lat, ncol = 3)
  )

```

### Mean offset

```{r IO_NS_mean_offset}

IO_NS_grid_offset_mean <-
  IO_NS_grid_offset %>%
  group_by(parameter, delta_year) %>%
  summarise(mean_delta_value = mean(delta_value),
            sd_delta_value = sd(delta_value)) %>%
  ungroup()

IO_NS_grid_offset_mean %>%
  filter(str_detect(parameter, "cstar")) %>%
  ggplot(aes(delta_year, mean_delta_value,
             ymin = mean_delta_value - sd_delta_value,
             ymax = mean_delta_value + sd_delta_value)) +
  geom_hline(yintercept = 0) +
  geom_pointrange() +
  facet_wrap(~ parameter)

IO_NS_grid_offset_mean %>%
  filter(!(str_detect(parameter, "cstar"))) %>%
  ggplot(aes(delta_year, mean_delta_value,
             ymin = mean_delta_value - sd_delta_value,
             ymax = mean_delta_value + sd_delta_value)) +
  geom_hline(yintercept = 0) +
  geom_pointrange() +
  facet_wrap(~ parameter, scales = "free_y")


```


## Indian E-W

```{r IO_EW_data}

IO_EW_cruises <- c(252, 488)

IO_EW_GLODAP_grid <- GLODAP %>%
  filter(basin_AIP == "Indian",
         lat > -25,
         lat < -15,
         cruise %in% IO_EW_cruises
  ) %>%
  mutate(cruise = as.factor(cruise)) %>%
  distinct(lon, lat, cruise, year = as.factor(year(date)))

map +
  geom_tile(data = IO_EW_GLODAP_grid,
            aes(lon, lat, fill = year)) +
  facet_wrap(~ year)


IO_EW <- GLODAP %>%
  filter(cruise %in% IO_EW_cruises)

IO_EW <- IO_EW %>%
  mutate(
    cstar = tco2  - (117 * phosphate)  - 0.5 * (talk - (16 * phosphate)),
    cstar_tco2 = tco2,
    cstar_talk = -0.5 * talk,
    cstar_phosphate = -117 * phosphate + 16 * 0.5 * phosphate
  )


IO_EW <- IO_EW %>%
  select(year,
         lon, lat, depth,
         cruise, station, cast,
         temp, sal, gamma,
         tco2, talk, phosphate,
         starts_with("cstar"))


IO_EW <- IO_EW %>%
  mutate(year = if_else(year == 2003, 2004, year),
         year = as.factor(as.character(year)))

IO_EW <- IO_EW %>%
  filter(lon > 48)

IO_EW <- IO_EW %>%
  filter(depth > 2000,
         depth < 4000)

map +
  geom_tile(data = IO_EW %>%
              distinct(lon, lat, year),
            aes(lon, lat, fill = year)) +
  # geom_vline(xintercept = 48) +
  facet_wrap(~ year, ncol = 2)


IO_EW <- IO_EW %>%
  pivot_longer(temp:cstar_phosphate,
               names_to = "parameter",
               values_to = "value")

```

### Section

```{r IO_EW_sections, fig.asp=1}


IO_EW %>%
  group_split(parameter) %>%
  # head(1) %>%
  map(
    ~ ggplot(data = .x,
             aes(lon , depth, col = value)) +
      geom_point() +
      scale_color_viridis_c() +
      scale_y_reverse() +
      facet_grid(year ~ parameter)
  )


```

### Profiles, absolute

```{r IO_EW_profiles, fig.asp=3}

IO_EW %>%
  arrange(depth) %>%
  group_split(parameter) %>%
  # head(1) %>%
  map(
    ~ ggplot(data = .x,
             aes(
               value , depth, fill = year,
             )) +
      geom_point(shape = 21) +
      scale_fill_scico_d(direction = -1) +
      scale_y_reverse() +
      labs(x = unique(.x$parameter)) +
      facet_wrap( ~ lon, ncol = 3)
  )

```

```{r IO_EW_profiles_gridded, fig.asp=2}

IO_EW_grid <- IO_EW %>%
  select(lon, lat, depth, year, parameter, value) %>%
  mutate(depth = as.numeric(as.character(cut(depth,
                                             seq(0,1e4, 500),
                                             seq(250,1e4,500))))) %>%
  group_by(lon, depth, year, parameter) %>%
  summarise(value = mean(value, na.rm=TRUE)) %>%
  ungroup()


IO_EW_grid %>%
  group_by(depth, year, parameter) %>%
  summarise(value = mean(value, na.rm = TRUE)) %>%
  ungroup() %>%
  ggplot(aes(value , depth, fill = year)) +
  geom_point(shape = 21) +
  scale_fill_scico_d(direction = -1) +
  scale_y_reverse() +
  facet_wrap(~ parameter, scales = "free_x", ncol = 3)

```

### Profiles, offset

```{r IO_EW_profiles_gridded_offset, fig.asp=3}

IO_EW_grid_offset <- IO_EW_grid %>%
  arrange(year) %>%
  group_by(lon, depth, parameter) %>%
  mutate(delta_value = value - lag(value),
         delta_year = paste(lag(year), year, sep = "-")) %>%
  ungroup() %>%
  drop_na()

IO_EW_grid_offset %>%
  group_split(parameter) %>%
  # head(1) %>%
  map(
    ~ ggplot(data = .x,
             aes(
               delta_value , depth, fill = delta_year,
             )) +
      geom_vline(xintercept = 0) +
      geom_point(shape = 21) +
      scale_fill_scico_d(direction = -1) +
      scale_y_reverse() +
      labs(x = unique(.x$parameter)) +
      facet_wrap( ~ lon, ncol = 3)
  )

```

### Mean offset

```{r IO_EW_mean_offset}

IO_EW_grid_offset_mean <-
  IO_EW_grid_offset %>%
  group_by(parameter, delta_year) %>%
  summarise(mean_delta_value = mean(delta_value),
            sd_delta_value = sd(delta_value)) %>%
  ungroup()

IO_EW_grid_offset_mean %>%
  filter(str_detect(parameter, "cstar")) %>%
  ggplot(aes(delta_year, mean_delta_value,
             ymin = mean_delta_value - sd_delta_value,
             ymax = mean_delta_value + sd_delta_value)) +
  geom_hline(yintercept = 0) +
  geom_pointrange() +
  facet_wrap(~ parameter)

IO_EW_grid_offset_mean %>%
  filter(!(str_detect(parameter, "cstar"))) %>%
  ggplot(aes(delta_year, mean_delta_value,
             ymin = mean_delta_value - sd_delta_value,
             ymax = mean_delta_value + sd_delta_value)) +
  geom_hline(yintercept = 0) +
  geom_pointrange() +
  facet_wrap(~ parameter, scales = "free_y")


```

## Indian N-S + E-W

```{r IO_NS_EW_map}

map +
  geom_tile(data = IO_EW %>%
              distinct(lon, lat, year),
            aes(lon, lat)) +
  geom_tile(data = IO_NS %>%
              distinct(lon, lat, year),
            aes(lon, lat)) +
  xlim(c(20,150)) +
  ylim(c(-80, 40))


```


```{r IO_NS_EW_profiles_gridded, fig.asp=1}


IO_NS_EW_grid <-
  bind_rows(
    IO_NS_grid %>%
      filter(year %in% c("1995", "2007")) %>%
      mutate(year = recode(year, "2007" = "2004"),
             lon = 999),
    IO_EW_grid %>%
      mutate(lat = 999)
  ) %>%
  mutate(year = recode(year, "2004" = "2000s", "1995" = "1990s"))

IO_NS_EW_grid %>%
  filter(parameter %in% c("cstar", "tco2", "talk", "phosphate")) %>%
  group_by(depth, year, parameter) %>%
  summarise(value = mean(value, na.rm = TRUE)) %>%
  ungroup() %>%
  ggplot(aes(value , depth, fill = year, col = year)) +
  geom_path() +
  geom_point(shape = 21) +
  scale_color_brewer(palette = "Set1",
                     name = "decade") +
  scale_fill_brewer(palette = "Set1",
                    name = "decade") +
  scale_y_reverse() +
  facet_wrap( ~ parameter, scales = "free_x", ncol = 2)


IO_NS_EW_grid %>%
  filter(!(parameter %in% c("cstar", "tco2", "talk", "phosphate"))) %>%
  group_by(depth, year, parameter) %>%
  summarise(value = mean(value, na.rm = TRUE)) %>%
  ungroup() %>%
  ggplot(aes(value , depth, fill = year)) +
  geom_point(shape = 21) +
  scale_fill_scico_d(direction = -1) +
  scale_y_reverse() +
  facet_wrap(~ parameter, scales = "free_x", ncol = 3)

IO_NS_EW_grid_offset <- IO_NS_EW_grid %>%
  arrange(year) %>%
  group_by(lat, lon, depth, parameter) %>%
  mutate(delta_value = value - lag(value),
         delta_year = paste(lag(year), year, sep = "-")) %>%
  ungroup() %>%
  drop_na()

```


### Mean offset

```{r IO_NS_EW_mean_offset}

IO_NS_EW_grid_offset_mean <-
  IO_NS_EW_grid_offset %>%
  group_by(parameter, delta_year) %>%
  summarise(mean_delta_value = mean(delta_value),
            sd_delta_value = sd(delta_value)) %>%
  ungroup()

IO_NS_EW_grid_offset_mean %>%
  filter(str_detect(parameter, "cstar")) %>%
  ggplot(aes(delta_year, mean_delta_value,
             ymin = mean_delta_value - sd_delta_value,
             ymax = mean_delta_value + sd_delta_value)) +
  geom_hline(yintercept = 0) +
  geom_pointrange() +
  facet_wrap(~ parameter)

IO_NS_EW_grid_offset_mean %>%
  filter(!(str_detect(parameter, "cstar"))) %>%
  ggplot(aes(delta_year, mean_delta_value,
             ymin = mean_delta_value - sd_delta_value,
             ymax = mean_delta_value + sd_delta_value)) +
  geom_hline(yintercept = 0) +
  geom_pointrange() +
  facet_wrap(~ parameter, scales = "free_y")


```



