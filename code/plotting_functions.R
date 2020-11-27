#### Color scales  ####

# Gruber color scale definition

rgb2hex <- function(r, g, b)
  rgb(r, g, b, maxColorValue = 100)

cols = c(rgb2hex(95, 95, 95),
         rgb2hex(0, 0, 95),
         rgb2hex(100, 0, 0),
         rgb2hex(100, 100, 0))

p_gruber_rainbow <- colorRampPalette(cols)

rm(rgb2hex, cols)


#### Section plots  ####

# Global section along transect
# Color scale continuous (default) or divergent
p_section_global <-
  function(df,
           var,
           var_name = var,
           title_text = "Global section",
           subtitle_text = "N-Atl -> SO -> N-Pac",
           col = "continuous") {

    var <- sym(var)

    # subset data along section
    df_sec <- left_join(section_global_coordinates, df)

    # prepare base section plot
    section_base <- df_sec %>%
      ggplot(aes(dist, depth, z = !!var)) +
      scale_y_reverse() +
      labs(y = "Depth (m)") +
      guides(fill = guide_colorsteps(barheight = unit(8, "cm")))

    # add chose color scale (default continuous)
    if (col == "continuous") {

      section <- section_base +
        geom_contour_filled() +
        geom_vline(data = section_global_coordinates %>% filter(lat == 0.5),
                   aes(xintercept = dist),
                   col = "white") +
        scale_fill_viridis_d(name = var_name)

    } else {

      max <- df_sec %>%
        select(!!var) %>%
        pull %>%
        abs() %>%
        quantile(0.99, na.rm = TRUE)

      breaks = seq(-max, max, length.out = 20)

      section <- section_base +
        geom_contour_filled(breaks = breaks) +
        geom_vline(data = section_global_coordinates %>% filter(lat == 0.5),
                   aes(xintercept = dist),
                   col = "white") +
        scale_fill_scico_d(palette = "vik", drop = FALSE,
                           name = var_name)

    }

    # cut out surface water section
    surface <-
      section +
      coord_cartesian(expand = 0,
                      ylim = c(500, 0)) +
      theme(
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank()
      ) +
      labs(y = "Depth (m)")

    # cut out deep water section
    deep <-
      section +
      coord_cartesian(expand = 0,
                      ylim = c(parameters$plotting_depth, 500)) +
      labs(x = "Distance (Mm)", y = "Depth (m)")

    # combine surface and deep water section
    surface / deep +
      plot_layout(guides = "collect") +
      plot_annotation(title = title_text,
                      subtitle = subtitle_text)

  }



# plot sections at regular lon intervals
p_section_climatology_regular <-
  function(df,
           var,
           var_name = var,
           col = "continuous",
           title_text = "Latitudinal sections") {

  var <- sym(var)

  # plot base section
  section <- df %>%
    filter(lon %in% parameters$longitude_sections_regular) %>%
    ggplot(aes(lat, depth, z = !!var)) +
    guides(fill = guide_colorsteps(barheight = unit(7, "cm"))) +
    scale_y_reverse() +
    scale_x_continuous(breaks = seq(-80, 80, 40)) +
    coord_cartesian(expand = 0) +
    facet_wrap( ~ lon, ncol = 3, labeller = label_both) +
    theme(axis.title.x = element_blank())

  # plot layer for chose color scale (default continuous)
  if (col == "continuous") {

    section <- section +
      geom_contour_filled() +
      scale_fill_viridis_d(name = var_name) +
      labs(title = title_text)

  } else {

    title_text <- "Latitudinal sections | Color range 99th percentile"

    max <- df %>%
      select(!!var) %>%
      pull %>%
      abs() %>%
      quantile(0.99)

    breaks = seq(-max, max, length.out = 20)

    section <- section +
      geom_contour_filled(breaks = breaks) +
      scale_fill_scico_d(palette = "vik",
                         drop = FALSE,
                         name = var_name) +
      labs(title = title_text)

  }

  section

}


# Zonal mean section of cant estimates
p_section_zonal <-
  function(df,
           var = "cant_pos",
           var_name = var,
           col = "continuous",
           gamma = "gamma_mean",
           plot_slabs = "y",
           drop_slabs = 1,
           breaks = parameters$breaks_cant_pos,
           legend_title = expression(atop(Delta * C[ant],
                                          (mu * mol ~ kg ^ {-1}))),
           title_text = "Zonal mean section",
           subtitle_text = "") {

    var <- sym(var)
    gamma <- sym(gamma)

    # plot base section
    section <- df %>%
      ggplot() +
      guides(fill = guide_colorsteps(barheight = unit(8, "cm"))) +
      scale_y_reverse() +
      scale_x_continuous(breaks = seq(-100, 100, 20),
                         limits = c(-85,85))

    # plot layer for chose color scale (default continuous)
    if (col == "continuous") {

      breaks_n <- length(breaks) - 1

      section <- section +
        geom_contour_filled(aes(lat, depth, z = !!var),
                            breaks = breaks) +
        scale_fill_manual(values = p_gruber_rainbow(breaks_n),
                          drop = FALSE,
                          name = legend_title)
    } else {

      section <- section +
        geom_contour_filled(aes(lat, depth, z = !!var),
                            breaks = breaks) +
        scale_fill_scico_d(palette = "vik",
                           drop = FALSE,
                           name = legend_title)

    }


    # plot isoneutral density lines if chosen (default yes)
    if (plot_slabs == "y") {

      # select slab breaks for plotted basin
      if (i_basin_AIP == "Atlantic") {
        slab_breaks <- parameters$slabs_Atl
      } else {
        slab_breaks <- parameters$slabs_Ind_Pac
      }


      section <- section +
        geom_contour(aes(lat, depth, z = !!gamma),
                     breaks = slab_breaks,
                     col = "black") +
        geom_text_contour(
          aes(lat, depth, z = !!gamma),
          breaks = slab_breaks,
          col = "black",
          skip = drop_slabs
        )

    }

    # cut surface water section
    surface <-
      section +
      coord_cartesian(
        expand = 0,
        ylim = c(500, 0)
      ) +
      labs(y = "Depth (m)",
           title = title_text,
           subtitle = subtitle_text) +
      theme(
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank()
      )

    # cut deep water section
    deep <-
      section +
      coord_cartesian(
        expand = 0,
        ylim = c(3000, 500)
      ) +
      labs(x = expression(latitude~(degree*N)), y = "Depth (m)")


    # combine surface and deep water section
    surface / deep +
      plot_layout(guides = "collect")

}


p_section_zonal_divergent_gamma_eras_basin <-
  function(df,
           var,
           var_name = var,
           gamma) {

  var <- sym(var)
  gamma <- sym(gamma)

  max <- df %>%
    select(!!var) %>%
    pull %>%
    abs() %>%
    max()

  breaks = seq(-max, max, length.out = 20)

  slab_breaks <- c(parameters$slabs_Atl[1:12],Inf)

  df %>%
    ggplot(aes(lat, depth, z = !!var)) +
    geom_contour_filled(breaks = breaks) +
    scale_fill_scico_d(palette = "vik",
                       drop = FALSE) +
    geom_contour(aes(lat, depth, z = !!gamma),
                 breaks = slab_breaks,
                 col = "white") +
    geom_text_contour(
      aes(lat, depth, z = !!gamma),
      breaks = slab_breaks,
      col = "white",
      skip = 2
    ) +
    scale_y_reverse() +
    coord_cartesian(expand = 0) +
    guides(fill = guide_colorsteps(barheight = unit(10, "cm"))) +
    facet_grid(basin_AIP ~ eras)

}




#### Map plots  ####


# plot column inventory map of cant estimate
# Color scale continuous (default) for pos cant or divergent for all cant
p_map_cant_inv <-
  function(df,
           var = "cant_pos_inv",
           col = "continuous",
           breaks = parameters$breaks_cant_pos_inv,
           title_text = "Column inventory map",
           subtitle_text = "era: JGOFS/WOCE - GO-SHIP") {

    var <- sym(var)

    if (col == "continuous") {
      breaks_n <- length(breaks) - 1

      df <- df %>%
        mutate(var_int = cut(!!var,
                             breaks,
                             right = FALSE))
      map +
        geom_raster(data = df,
                    aes(lon, lat, fill = var_int)) +
        scale_fill_manual(values = p_gruber_rainbow(breaks_n),
                          name = expression(atop(Delta * C["ant,pos"],
                                                 (mol ~ m ^ {
                                                   -2
                                                 })))) +
        guides(fill = guide_colorsteps(barheight = unit(6, "cm"))) +
        labs(title = title_text,
             subtitle = subtitle_text)
    } else {

      breaks = parameters$breaks_cant_inv

      map +
        geom_raster(data = df,
                    aes(lon, lat, fill = cut(!!var, breaks))) +
        scale_fill_scico_d(palette = "vik",
                           drop = FALSE,
                           name = expression(atop(Delta * C[ant],
                                                  (mu * mol ~ kg ^ {-1})))) +
        guides(fill = guide_colorsteps(barheight = unit(6, "cm")))  +
        labs(title = title_text,
             subtitle = subtitle_text)

    }

  }




# plot column inventory map of cant offset
p_map_cant_inv_offset <-
  function(df,
           var,
           breaks = parameters$breaks_cant_inv_offset,
           title_text = "Column inventory map - offset",
           subtitle_text = "era: JGOFS/WOCE - GO-SHIP") {

    var <- sym(var)

    map +
      geom_raster(data = df,
                  aes(lon, lat, fill = cut(!!var, breaks))) +
      scale_fill_scico_d(palette = "vik", drop = FALSE,
                         name = expression(atop(Offset~Delta*C[ant],
                                                (mol~m^{-2})))) +
      guides(fill = guide_colorsteps(barheight = unit(6, "cm"))) +
      labs(title = title_text,
           subtitle = subtitle_text)

  }



# plot map of mean cant within density slab
# Color scale continuous (default) for pos cant or divergent for all cant
p_map_cant_slab <-
  function(df,
           var = "cant_pos",
           col = "continuous",
           breaks = parameters$breaks_cant_pos_inv,
           legend_title = expression(atop(Delta * C[ant],
                                          (mu * mol ~ kg ^ {-1}))),
           title_text = "Isoneutral slab concentration map",
           subtitle_text = "era: JGOFS/WOCE - GO-SHIP") {

    var <- sym(var)

    # plot map for chose color scale (default continuous)
    if (col == "continuous") {

      breaks_n <- length(breaks) - 1

      df <- df %>%
        mutate(var_int = cut(!!var,
                             breaks,
                             right = FALSE))
      map +
        geom_raster(data = df,
                    aes(lon, lat, fill = var_int)) +
        scale_fill_manual(values = p_gruber_rainbow(breaks_n),
                          name = legend_title,
                          drop = FALSE) +
        guides(fill = guide_colorsteps(barheight = unit(6, "cm"))) +
        labs(title = title_text,
             subtitle = subtitle_text)

    } else {

      breaks <- parameters$breaks_cant_inv

      map +
        geom_raster(data = df,
                    aes(lon, lat, fill = cut(cant, breaks))) +
        scale_fill_scico_d(palette = "vik",
                           drop = FALSE,
                           name = expression(atop(Delta * C[ant],
                                                  (mu * mol ~ kg ^ {-1})))) +
        guides(fill = guide_colorsteps(barheight = unit(6, "cm")))  +
        labs(title = title_text,
             subtitle = subtitle_text)

    }

  }




# Maps at predefined depth layers
# Color scale continuous (default) or divergent
p_map_climatology <-
  function(df,
           var,
           title_text = "Distribution maps",
           subtitle_text = "at predefined depth levels",
           col = "continuous") {

    var <- sym(var)

    # filter depth levels
    df <- df %>%
      filter(depth %in% parameters$depth_levels)

    # prepare map
    map_base <-
      map +
      geom_raster(data = df,
                  aes(lon, lat, fill = !!var)) +
      geom_raster(data = section_global_coordinates,
                  aes(lon, lat), fill = "white") +
      facet_wrap( ~ depth, labeller = label_both) +
      labs(title = title_text,
           subtitle = subtitle_text)

    # add chose color scale (default continuous)
    if (col == "continuous") {
    map_base +
      scale_fill_viridis_c()

    } else {

      max <- df %>%
        select(!!var) %>%
        pull %>%
        abs() %>%
        max()

      limits <- c(-1, 1) * max

      map_base +
        scale_fill_scico(
          palette = "vik",
          limit = limits
        )

      }

  }
