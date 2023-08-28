## code to prepare `canadian_census_divisions` dataset goes here
library(dplyr)
library(sf)
library(sp)
library(rgeos)
library(terra)

# Shape file of all census divisions
cds_geo <-
  st_read("data-raw/shapefiles/lcd_000b21a_e/lcd_000b21a_e.shp")

cds <- st_drop_geometry(cds_geo)

cds_geo_simplified <- as_Spatial(cds_geo) %>%
  gSimplify(tol = 1000) %>%
  sf::st_as_sf() %>%
  cbind(cds)

new_crs <- "+init=epsg:4326"

canadian_census_divisions <- cds_geo_simplified %>%
  sf::st_transform(CRS(new_crs))

usethis::use_data(canadian_census_divisions, overwrite = TRUE, internal = TRUE)
