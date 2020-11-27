bbox <- c(
  "xmin" = min(GLODAP_cruise$lat),
  "ymin" = min(GLODAP_cruise$depth),
  "xmax" = max(GLODAP_cruise$lat),
  "ymax" = max(GLODAP_cruise$depth)
)

grd_template <- expand.grid(
  lat = seq(from = bbox["xmin"], to = bbox["xmax"], by = 1),
  depth = seq(from = bbox["ymin"], to = bbox["ymax"], by = 50) # 20 m resolution
)

crs_raster_format <- " +proj=utm  +zone=33  +ellps=GRS80  +towgs84=0,0,0,0,0,0,0  +units=m  +no_defs"

grd_template_raster <- grd_template %>%
  dplyr::mutate(Z = 0) %>%
  raster::rasterFromXYZ(
    crs = crs_raster_format)


# Generalized Additive Model
fit_GAM <- mgcv::gam( # using {mgcv}
  gamma ~ s(lat, depth),      # here come our X/Y/Z data - straightforward enough
  data = GLODAP_cruise      # specify in which object the data is stored
)

# Generalized Additive Model
interp_GAM <- grd_template %>%
  mutate(Z = predict(fit_GAM, .)) %>%
  raster::rasterFromXYZ(crs = crs_raster_format)

df <- raster::rasterToPoints(interp_GAM) %>% as_tibble()
colnames(df) <- c("X", "Y", "Z")

ggplot(df, aes(x = X, y = Y, fill = Z, z = Z))  +
  geom_raster()  +
  geom_contour(col="white")  +
  ggtitle(label = "interp GAM")  +
  scale_fill_viridis_c()  +
  scale_y_reverse() +
  coord_cartesian(expand = 0)

