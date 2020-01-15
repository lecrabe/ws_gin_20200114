##########################################################################################
################## Read, manipulate and write raster data
##########################################################################################

########################################################################################## 
# Contact: remi.dannunzio@fao.org
# Last update: 2018-08-24
##########################################################################################

time_start  <- Sys.time()

####################################################################################
####### GET COUNTRY BOUNDARIES
####################################################################################
aoi <- getData('GADM',path=gadm_dir, country= countrycode, level=1)
bb <- extent(aoi)


####################################################################################
####### CLIP ESA MAP TO COUNTRY BOUNDING BOX
####################################################################################
system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -co COMPRESS=LZW %s %s",
               floor(bb@xmin),
               ceiling(bb@ymax),
               ceiling(bb@xmax),
               floor(bb@ymin),
               paste0(esastore_dir,"ESACCI-LC-L4-LC10-Map-20m-P1Y-2016-v1.0.tif"),
               paste0(esa_dir,"esa.tif")
))


#############################################################
### CROP TO COUNTRY BOUNDARIES
system(sprintf("python %s/oft-cutline_crop.py -v %s -i %s -o %s -a %s",
               scriptdir,
               paste0(gadm_dir,"gadm_",countrycode,"_l1.shp"),
               paste0(esa_dir,"esa.tif"),
               paste0(esa_dir,"esa_guinea.tif"),
               "OBJECTID"
))


#############################################################
### CROP TO FARANAH BOUNDARIES
system(sprintf("python %s/oft-cutline_crop.py -v %s -i %s -o %s -a %s",
               scriptdir,
               paste0(gadm_dir,"haute_guinee.shp"),
               paste0(esa_dir,"esa.tif"),
               paste0(esa_dir,"esa_haute_guinee.tif"),
               "OBJECTID"
))

#############################################################
### CREATE A FOREST MASK FOR MSPA ANALYSIS
system(sprintf("gdal_calc.py -A %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(esa_dir,"esa_haute_guinee.tif"),
               paste0(esa_dir,"esa_haute_guinee_mspa.tif"),
               paste0("(A==0)*0+(A==1)*2+(A>1)*1")
))


time_products_global <- Sys.time() - time_start


