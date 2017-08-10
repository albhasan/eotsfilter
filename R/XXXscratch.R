#scratch

################################################################################
# get the samples data from SciDb
################################################################################

source("R/scidbUtil.R")
samples1 <- read.csv("inst/extdata/deforestation_points1.csv")
samples2 <- read.csv("inst/extdata/deforestation_points2.csv")


#-------------------------------
# read the sata
#-------------------------------
getwd()
source("scidbUtil.R")
samples1 <- read.csv("deforestation_points1.csv")
samples2 <- read.csv("deforestation_points2.csv")
#-------------------------------
# coordinates transformation
# WGS84 to col_id row_id
#-------------------------------
pixelSize <- .calcPixelSize(4800, .calcTileWidth())
proj4326 <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
proj_modis_sinusoidal <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
lonlat.Matrix1 <- as.matrix(samples1[c("X", "Y")])
lonlat.Matrix2 <- as.matrix(samples2[c("X", "Y")])
S1 <- sp::SpatialPoints(lonlat.Matrix1)
S2 <- sp::SpatialPoints(lonlat.Matrix2)
proj4string(S1) <- sp::CRS(proj4326)
proj4string(S2) <- sp::CRS(proj4326)
lonlat.Matrix.res1 <- sp::spTransform(S1, sp::CRS(proj_modis_sinusoidal))
lonlat.Matrix.res2 <- sp::spTransform(S2, sp::CRS(proj_modis_sinusoidal))
res1 <- .sinusoidal2gmpi(t(bbox(lonlat.Matrix.res1)), pixelSize)
res2 <- .sinusoidal2gmpi(t(bbox(lonlat.Matrix.res2)), pixelSize)





