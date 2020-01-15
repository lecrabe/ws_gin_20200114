####################################################################################################
################################### PART I: GET GADM DATA
####################################################################################################

## Get the list of countries from getData: "getData"
(gadm_list  <- data.frame(getData('ISO3')))
?getData

## Get GADM data, check object propreties
aoi         <- getData('GADM',path=gadm_dir , country= countrycode, level=1)

summary(aoi)
extent(aoi)
proj4string(aoi)

## Display the SPDF
plot(aoi)

##  Export the SpatialPolygonDataFrame as a ESRI Shapefile
aoi@data$OBJECTID <- row(aoi@data)[,1]

writeOGR(aoi,
         paste0(gadm_dir,"gadm_",countrycode,"_l1.shp"),
         paste0("gadm_",countrycode,"_l1"),
         "ESRI Shapefile",
         overwrite_layer = T)

aoi_name   <- paste0(gadm_dir,"gadm_",countrycode,"_l1")
aoi_shp    <- paste0(aoi_name,".shp")
aoi_field <-  "OBJECTID"

sub_aoi   <- aoi[aoi$NAME_1 == "Faranah" | aoi$NAME_1 == "Kankan",]
head(aoi@data)
plot(sub_aoi)

writeOGR(sub_aoi,
         paste0(gadm_dir,"haute_guinee.shp"),
         paste0("haute_guinee"),
         "ESRI Shapefile",
         overwrite_layer = T)
