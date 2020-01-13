####################################################################################################
####################################################################################################
## Set environment variables
## Contact remi.dannunzio@fao.org 
## 2020/01/08
####################################################################################################
####################################################################################################

####################################################################################################

### Read all external files with TEXT as TEXT
options(stringsAsFactors = FALSE)

### Create a function that checks if a package is installed and installs it otherwise
packages <- function(x){
  x <- as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

### Install (if necessary) two missing packages in your local SEPAL environment
packages(Hmisc)
packages(RCurl)
packages(hexbin)

## Packages to download GFC data
packages(devtools)
install_github('yfinegold/gfcanalysis')
packages(gfcanalysis)

### Load necessary packages
packages(raster)
packages(rgeos)
packages(ggplot2)
packages(rgdal)
packages(dplyr)
packages(foreign)

## Set the working directory
rootdir       <- paste0(normalizePath("~"),"/ws_gin_20200114/")

## Set two downloads directories
gfcstore_dir  <- paste0(normalizePath("~"),"/downloads/gfc_2016/")
esastore_dir  <- paste0(normalizePath("~"),"/downloads/ESA_2016/")

## Set the country code
countrycode <- "GIN"

## Go to the root directory
scriptdir<- paste0(rootdir,"scripts/")
data_dir <- paste0(rootdir,"data/")
gadm_dir <- paste0(rootdir,"data/gadm/")
gfc_dir  <- paste0(rootdir,"data/gfc/")
lsat_dir <- paste0(rootdir,"data/mosaic_lsat/")
seg_dir  <- paste0(rootdir,"data/segments/")
dd_dir   <- paste0(rootdir,"data/dd_map/")
lc_dir   <- paste0(rootdir,"data/forest_mask/")
esa_dir  <- paste0(rootdir,"data/esa/")
tile_dir <- paste0(rootdir,"data/tiling/")
tab_dir  <- paste0(rootdir,"data/tables/")
tmp_dir  <- paste0(rootdir,"data/tmp/")

dir.create(data_dir,showWarnings = F)
dir.create(gadm_dir,showWarnings = F)
dir.create(gfc_dir,showWarnings = F)
dir.create(lsat_dir,showWarnings = F)
dir.create(seg_dir,showWarnings = F)
dir.create(dd_dir,showWarnings = F)
dir.create(lc_dir,showWarnings = F)
dir.create(esa_dir,showWarnings = F)
dir.create(gfcstore_dir,showWarnings = F)
dir.create(esastore_dir,showWarnings = F)
dir.create(tile_dir,showWarnings = F)
dir.create(tab_dir,showWarnings = F)
dir.create(tmp_dir,showWarnings = F)

#################### GFC PRODUCTS
gfc_threshold <- 30

#################### PRODUCTS AT THE THRESHOLD
gfc_tc       <- paste0(gfc_dir,"gfc_th",gfc_threshold,"_tc.tif")
gfc_ly       <- paste0(gfc_dir,"gfc_th",gfc_threshold,"_ly.tif")
gfc_gn       <- paste0(gfc_dir,"gfc_gain.tif")
gfc_16       <- paste0(gfc_dir,"gfc_th",gfc_threshold,"_F_2016.tif")
gfc_00       <- paste0(gfc_dir,"gfc_th",gfc_threshold,"_F_2000.tif")
gfc_mp       <- paste0(gfc_dir,"gfc_map_2000_2014_th",gfc_threshold,".tif")
gfc_mp_crop  <- paste0(gfc_dir,"gfc_map_2000_2014_th",gfc_threshold,"_crop.tif")
gfc_mp_sub   <- paste0(gfc_dir,"gfc_map_2000_2014_th",gfc_threshold,"_sub_crop.tif")

threshold   <- gfc_threshold
max_year    <- 18
spacing     <- 1000 #0.011
offset      <- 0.001
proj        <- '+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs'
nb_iter     <- 10

## Set a range of sub-sampling (take a point every xx point)
classes <- c(100,50,40,30,20,10,5,4,3,2,1)
#################### CREATE A COLOR TABLE FOR THE OUTPUT MAP
my_classes <- c(0,1:max_year,30,40,50,51)
my_labels  <- c("no data",paste0("loss_",2000+1:max_year),"non forest","forest","gains","gains+loss")
codes <- data.frame(cbind(my_labels,my_classes))

loss_col <- colorRampPalette(c("yellow", "darkred"))
nonf_col <- "lightgrey"
fore_col <- "darkgreen"
gain_col <- "lightgreen"
ndat_col <- "black"
gnls_col <- "purple"

my_colors  <- col2rgb(c(ndat_col,
                        loss_col(max_year),
                        nonf_col,
                        fore_col,
                        gain_col,
                        gnls_col))

pct <- data.frame(cbind(my_classes,
                        my_colors[1,],
                        my_colors[2,],
                        my_colors[3,]))

write.table(pct,paste0(gfc_dir,"color_table.txt"),row.names = F,col.names = F,quote = F)

types       <- c("treecover2000","lossyear","gain","datamask")


output_names <- c(paste("year",2000+(1:max_year),sep="_"),
                  "total","intensity","sampling","iter","offset")

####################################################################################################
################# PIXEL COUNT FUNCTION
pixel_count <- function(x){
  info    <- gdalinfo(x,hist=T)
  buckets <- unlist(str_split(info[grep("bucket",info)+1]," "))
  buckets <- as.numeric(buckets[!(buckets == "")])
  hist    <- data.frame(cbind(0:(length(buckets)-1),buckets))
  hist    <- hist[hist[,2]>0,]
}