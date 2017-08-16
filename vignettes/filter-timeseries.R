## ----get TS from SciDB, eval=FALSE, include=TRUE-------------------------
#  samples1 <- read.csv("inst/extdata/deforestation_points1.csv", stringsAsFactors = FALSE)
#  samples2 <- read.csv("inst/extdata/deforestation_points2.csv", stringsAsFactors = FALSE)
#  cnames <- c("id", "longitude", "latitude", "start_date", "end_date", "label",
#              "linkcolumn", "class_name", "scene_id", "areameters", "view_date",
#              "julday")
#  samples1 <- samples1[cnames]
#  samples2 <- samples2[cnames]
#  con <- scidb::scidbconnect()
#  pixelSize <-scidbutil::calcPixelSize(4800, scidbutil::calcTileWidth())
#  samples1 <- scidbutil::getSdbDataFromPoints(samples.df = samples1,
#                                              arrayname = "mod13q1_512",
#                                              con = con, pixelSize = pixelSize)
#  samples2 <- scidbutil::getSdbDataFromPoints(samples.df = samples2,
#                                              arrayname = "mod13q1_512",
#                                              con = con, pixelSize = pixelSize)
#  devtools::use_data(samples1)
#  devtools::use_data(samples2)

