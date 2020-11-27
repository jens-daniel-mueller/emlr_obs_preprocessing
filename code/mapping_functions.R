#### Averaging of mapped fields ####

m_cant_predictor_model_average <- function(df) {

  df <- df %>%
    fselect(lon, lat, depth, eras, basin,
            cant_intercept,
            cant_aou,
            cant_oxygen,
            cant_phosphate,
            cant_phosphate_star,
            cant_silicate,
            cant_tem,
            cant_sal,
            cant_sum,
            gamma) %>%
    fgroup_by(lon, lat, depth, eras, basin) %>% {
      add_vars(fgroup_vars(.,"unique"),
               fmean(., keep.group_vars = FALSE))
    }

  return(df)

}

m_cant_model_average <- function(df) {

  df <- df %>%
    fselect(lon, lat, depth, eras, basin, cant, cant_pos, gamma) %>%
    fgroup_by(lon, lat, depth, eras, basin) %>% {
      add_vars(fgroup_vars(.,"unique"),
               fmean(., keep.group_vars = FALSE),
               fsd(., keep.group_vars = FALSE) %>% add_stub(pre = FALSE, "_sd"))
    }

  return(df)

}

m_cstar_model_average <- function(df) {

  df <- df %>%
    fselect(lon, lat, depth, era, basin, cstar, gamma) %>%
    fgroup_by(lon, lat, depth, era, basin) %>% {
      add_vars(fgroup_vars(.,"unique"),
               fmean(., keep.group_vars = FALSE),
               fsd(., keep.group_vars = FALSE) %>% add_stub(pre = FALSE, "_sd"))
    }

  return(df)

}

m_cant_predictor_zonal_mean <- function(df) {

  df <- df %>%
    fselect(lat, depth, eras, basin, basin_AIP,
            cant_intercept:gamma) %>%
    fgroup_by(lat, depth, eras, basin, basin_AIP) %>% {
      add_vars(fgroup_vars(.,"unique"),
               fmean(., keep.group_vars = FALSE))
    }

  return(df)

}

m_cant_zonal_mean <- function(df) {

  df <- df %>%
    fselect(lat, depth, eras, basin, basin_AIP,
            cant, cant_pos, gamma, cant_sd, cant_pos_sd, gamma_sd) %>%
    fgroup_by(lat, depth, eras, basin, basin_AIP) %>% {
      add_vars(fgroup_vars(.,"unique"),
               fmean(., keep.group_vars = FALSE) %>% add_stub(pre = FALSE, "_mean"),
               fsd(., keep.group_vars = FALSE) %>% add_stub(pre = FALSE, "_sd"))
    }

  return(df)

}

m_cstar_zonal_mean <- function(df) {

  df <- df %>%
    fselect(lat, depth, era, basin, basin_AIP,
            cstar, gamma, cstar_sd, gamma_sd) %>%
    fgroup_by(lat, depth, era, basin, basin_AIP) %>% {
      add_vars(fgroup_vars(.,"unique"),
               fmean(., keep.group_vars = FALSE) %>% add_stub(pre = FALSE, "_mean"),
               fsd(., keep.group_vars = FALSE) %>% add_stub(pre = FALSE, "_sd"))
    }

  return(df)

}



# calculate cant column inventory [mol m-2] from cant concentration [umol kg-1]
m_cant_inv <- function(df) {

  depth_level_volume <- tibble(
    depth = unique(df$depth)) %>%
    arrange(depth)

  depth_level_volume <- depth_level_volume %>%
    mutate(layer_thickness_above = replace_na((depth - lag(depth)) / 2, 0),
           layer_thickness_below = replace_na((lead(depth) - depth) / 2, 0),
           layer_thickness = layer_thickness_above + layer_thickness_below) %>%
    select(-c(layer_thickness_above,
              layer_thickness_below))

  df <- full_join(df, depth_level_volume)

  df <- df %>%
    filter(depth <= parameters$inventory_depth)

  df <- df %>%
    mutate(cant_layer_inv = cant * layer_thickness * 1.03,
           cant_pos_layer_inv = cant_pos * layer_thickness * 1.03) %>%
    select(-layer_thickness)

  df_inv <- df %>%
    group_by(lon, lat, basin_AIP, eras) %>%
    summarise(
      cant_pos_inv = sum(cant_pos_layer_inv, na.rm = TRUE) / 1000,
      cant_inv     = sum(cant_layer_inv, na.rm = TRUE) / 1000
    ) %>%
    ungroup()

  return(df_inv)

}


# calculate mean cant concentration within each grid cell of density slab
m_cant_slab <- function(df) {

  df_group <- df %>%
    group_by(lat, lon, gamma_slab, eras) %>%
    summarise(cant_pos = mean(cant_pos, na.rm = TRUE),
              cant = mean(cant, na.rm = TRUE),
              depth_max = max(depth, na.rm = TRUE)) %>%
    ungroup()

  return(df_group)

}


# calculate zonal mean section
m_zonal_mean_section <- function(df) {

  zonal_mean_section <- df %>%
    select(-lon) %>%
    fgroup_by(lat, depth, eras, basin_AIP) %>% {
      add_vars(fgroup_vars(.,"unique"),
               fmean(., keep.group_vars = FALSE) %>% add_stub(pre = FALSE, "_mean"),
               fsd(., keep.group_vars = FALSE) %>% add_stub(pre = FALSE, "_sd"))
    }

  return(zonal_mean_section)

}


#### Horizontal gridding ####

# cut lat and lon to a 1 x 1 deg horizontal grid
m_grid_horizontal <- function(df) {

  df <- df %>%
    mutate(
      lat = cut(lat, seq(-90, 90, 1), seq(-89.5, 89.5, 1)),
      lat = as.numeric(as.character(lat)),
      lon = cut(lon, seq(20, 380, 1), seq(20.5, 379.5, 1)),
      lon = as.numeric(as.character(lon))
    )

  return(df)

}

# cut lat and lon to a 5 x 5 deg horizontal grid
m_grid_horizontal_coarse <- function(df) {

  df <- df %>%
    mutate(
      lat_grid = cut(lat, seq(-90, 90, 5), seq(-87.5, 87.5, 5)),
      lat_grid = as.numeric(as.character(lat_grid)),
      lon_grid = cut(lon, seq(20, 380, 5), seq(22.5, 377.5, 5)),
      lon_grid = as.numeric(as.character(lon_grid))
    )

  return(df)

}



#### Neutral density slab assignment ####
# cut neutral density gamma into specific slabs for basins
m_cut_gamma <- function(df, var) {

  var <- sym(var)

  df_Atl <- df %>%
    filter(basin == "Atlantic") %>%
    mutate(gamma_slab = cut(!!var, parameters$slabs_Atl))

  df_Ind_Pac <- df %>%
    filter(basin == "Indo-Pacific") %>%
    mutate(gamma_slab = cut(!!var, parameters$slabs_Ind_Pac))

  df <- bind_rows(df_Atl, df_Ind_Pac)

  return(df)

}
