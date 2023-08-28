## code to prepare `housing_cost_cd` dataset goes here
library(dplyr)
library(tidyr)
library(sf)
library(statcanR)

# Shape file of all census divisions
cds_geo <-
  st_read("inst/shapefiles/lcd_000b21a_e/lcd_000b21a_e.shp")

cds <- st_drop_geometry(cds_geo)

# Population information of all Canadian geographics
areas_data <- statcan_download_data("98-10-0002-02", "eng")

census_divisions <- areas_data[, c("GEO", "DGUID", "Population and dwelling counts (13): Population, 2021 [1]")] %>%
  filter(DGUID %in% cds$DGUID) %>%
  rename("pop2021" = "Population and dwelling counts (13): Population, 2021 [1]")

# Data on housing availability
rawdata_housing <- statcan_download_data("98-10-0255-01", "eng")

housing_cost_cd <-
  rawdata_housing[, c(
    "GEO",
    "DGUID",
    "Residence on or off reserve (3)",
    "Household type including census family structure (9)",
    "Statistics (3C)",
    "Shelter-cost-to-income ratio (5)",
    "Tenure including presence of mortgage payments and subsidized housing (8):Total - Tenure including presence of mortgage payments and subsidized housing[1]"
  )] %>%
  filter(
    `Residence on or off reserve (3)` == "Total - Residence on or off reserve",
    `Household type including census family structure (9)` == "Total - Household type including family structure",
    `Statistics (3C)` == "Number of private households"
  ) %>%
  rename("cost_ratio" = "Shelter-cost-to-income ratio (5)",  "count" = "Tenure including presence of mortgage payments and subsidized housing (8):Total - Tenure including presence of mortgage payments and subsidized housing[1]") %>%
  select(GEO, DGUID, cost_ratio, count) %>%
  pivot_wider(names_from = cost_ratio, values_from = count) %>%
  mutate(high_housing_cost_prop = `Spending 30% or more of income on shelter costs` / `Total - Shelter-cost-to-income ratio`) %>%
  select(DGUID, high_housing_cost_prop)

housing_cost_cd <- census_divisions %>%
  left_join(housing_cost_cd, by = c("DGUID"))

usethis::use_data(housing_cost_cd, overwrite = TRUE)
