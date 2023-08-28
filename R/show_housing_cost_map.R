#' Show Canadian housing cost map
#'
#' @return a leaflet map
#' @import magrittr
#' @export
#'
#' @examples
show_housing_cost_map <- function(){

  housing_cost_cd <- housingcostca::housing_cost_cd %>%
    dplyr::slice(match(canadian_census_divisions[["DGUID"]], DGUID))

  housing_cost_cd_geo <- canadian_census_divisions
  housing_cost_cd_geo[["high_housing_cost_prop"]] <- housing_cost_cd[["high_housing_cost_prop"]]

  pal <- leaflet::colorBin(palette = "Reds",
                  domain = housing_cost_cd_geo$high_housing_cost_prop, n = 5)

  leaflet::leaflet() %>%
    leaflet::addProviderTiles("CartoDB.Positron") %>%
    leaflet::addPolygons(
      data = housing_cost_cd_geo,
      color = "grey",
      weight = 0.6,
      opacity = 1,
      fillOpacity = 0.8,
      fillColor = ~ pal(high_housing_cost_prop),
      label = ~ paste0(CDNAME, ": ", 100 * round(high_housing_cost_prop, 2), "%")
    ) %>%
    leaflet::setView(-75, 45, zoom = 4.5)
}
