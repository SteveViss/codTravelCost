# Prep the environment
library(dplyr)
library(sf)
library(mapview)
library(raster)
library(gdistance)
library(sp)

# Read the files
stations <- read.csv2("./stations.csv") %>% 
    st_as_sf(coords = c("LONDEC","LATDEC"), crs = 4326)
world_land <- read_sf("ne_10m_land/ne_10m_land.shp")

# Create Study area (maximum extent of the stations) in sf object
area <- st_as_sfc("POLYGON((-74.73246245811687 53.9192683504064,-47.57425933311688 53.9192683504064,-47.57425933311688 40.99903081925713,-74.73246245811687 40.99903081925713,-74.73246245811687 53.9192683504064))", crs = 4326)

# Crop the land using the study area
area_land <- st_crop(world_land, area)

# Get the reverse polygon of land = water
water <- st_difference(area,st_union(area_land))

# reproject
stations <- st_transform(stations, st_crs(32198))
water <- st_transform(water, st_crs(32198))

# Keep only polygon
water <- water %>% subset(st_is(water, "MULTIPOLYGON"))

# Make grid from the water
water_grid <- rasterize(as(water, "Spatial"), raster(extent(as(water, "Spatial")), res = 1000), crs = projection(water))

# Lock Bras d'or
bras_dor_lake <- st_transform(st_as_sfc("POLYGON((-60.93991497178168 45.757378237982095,-61.09372356553168 45.68451187913338,-61.19534710068793 45.7056145453812,-61.15964153428168 45.77270641511787,-61.08823040146918 45.826321868586,-61.15964153428168 45.920024774798144,-61.16788128037543 45.96204407868146,-61.00857952256293 46.0478934718115,-60.77786663193793 46.13551293667534,-60.69821575303168 46.15644479487579,-60.57736614365668 46.20208667737513,-60.45102337021918 46.30274496105455,-60.35214641709418 46.289461059267886,-60.06924846787543 46.18687692616136,-60.67898967881293 45.80526480754243,-60.69546917100043 45.7056145453812,-60.82455852646918 45.63652165817365,-60.91244915146918 45.64996306632425,-60.93991497178168 45.757378237982095))", crs = 4326), st_crs(32198))

water_grid[extract(water_grid, as(bras_dor_lake, "Spatial"), cellnumbers=TRUE)[[1]][,1]] <- NA

# Lock Canso Canal
canal <- st_transform(st_as_sfc("POLYGON((-61.50333636302357 45.6834559927143,-61.43741839427357 45.72373675132462,-61.24515765208607 45.566285379013095,-61.35502093333607 45.50664580152536,-61.50333636302357 45.6834559927143))", crs = 4326), st_crs(32198))

water_grid[extract(water_grid, as(canal, "Spatial"), cellnumbers=TRUE)[[1]][,1]] <- NA

# Coerce to spatial object (not sf, but sp)
sp_stations <- as(stations, "Spatial")

# Create the gdistance transition matrix
r <- transition(water_grid, mean, directions = 16)

# Loop over all stations
distances <- list()
for(s in 1:length(sp_stations)){
    # Compute shortest paths for a specific station (one station by iteration of the loop)
    distance <- shortestPath(r, sp_stations[s,], sp_stations, output = "SpatialLines")
    # Retrieve the length (in meters) for all shortest paths 
    distances[[s]] <- st_length(st_as_sf(distance))
    # Then write all shortest paths in a shapefile
    st_write(st_as_sf(distance), paste0("shp/station_", sp_stations$Station[s], ".shp"))
}

# Recreate the distance matrix
distances <- as.matrix(sapply(distances, as.numeric))
colnames(distances) <- paste0("station_",sp_stations$Station)
rownames(distances) <- paste0("station_",sp_stations$Station)

# Write the matrix in csv
write.csv2(distances, "distances.csv")
