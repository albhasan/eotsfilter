#---- MODIS ----



# Plot a MOD13Q1 time series according to ist data reliability
#
# @param x      A time-ordered data frame
# @param cols   A character vector containing the name of columns 3 ("timeIndex", "value", "reliability")
# @param pname  A string for the graph title
# plotTSrel2 <- function(x, cols, title){
#   xlim <- c(min(unlist(x[cols[1]])), max(unlist(x[cols[1]])))
#   ylim <- c(min(x$ndvinorm), max(x$ndvinorm))
#   graphics::plot(x = NA, xlim = xlim, ylim = ylim, ylab = cols[2])
#   for(i in 2:nrow(x)){
#     acolors <- c("green", "gray", "yellow", "blue", "red", "black")
#     if(x$reliability[i-1] == -1){
#       acol = acolors[5]
#     }else{
#       acol = acolors[x$reliability[i]]
#     }
#     graphics::lines(
#       x = c(x[i-1, "timeIndex"], x[i, "timeIndex"]),
#       y = c(x[i-1, "ndvinorm"], x[i, "ndvinorm"]),
#       col = acol
#     )
#   }
# }



# DEPRECATED (moved to scidbutil) -  Add readable quality data to a MOD13Q1 time series according to its data quality
#
# @param x A data frame containing the column c("quality")
# @return A data frame with additional columns.
.addMod13Q1quality <- function(x){
  # get the codes
  x <- .mod13q1quality2codes(x)
  # convet codes to factors
  x$MODLAND_QA <- as.factor(x$MODLAND_QA)
  levels(x$MODLAND_QA)[levels(x$MODLAND_QA)=="00"] <- "VI produced, good quality"
  levels(x$MODLAND_QA)[levels(x$MODLAND_QA)=="01"] <- "VI produced, but check other QA"
  levels(x$MODLAND_QA)[levels(x$MODLAND_QA)=="10"] <- "Pixel produced, but most probably cloudy"
  levels(x$MODLAND_QA)[levels(x$MODLAND_QA)=="11"] <- "Pixel not produced due to other reasons than clouds"
  x$VI_useful <- as.factor(x$VI_useful)
  levels(x$VI_useful)[levels(x$VI_useful)=="0000"] <- "Highest quality"
  levels(x$VI_useful)[levels(x$VI_useful)=="0001"] <- "Lower quality"
  levels(x$VI_useful)[levels(x$VI_useful)=="0010"] <- "Decreasing quality"
  levels(x$VI_useful)[levels(x$VI_useful)=="0100"] <- "Decreasing quality"
  levels(x$VI_useful)[levels(x$VI_useful)=="1000"] <- "Decreasing quality"
  levels(x$VI_useful)[levels(x$VI_useful)=="1001"] <- "Decreasing quality"
  levels(x$VI_useful)[levels(x$VI_useful)=="1010"] <- "Decreasing quality"
  levels(x$VI_useful)[levels(x$VI_useful)=="1100"] <- "Lowest quality"
  levels(x$VI_useful)[levels(x$VI_useful)=="1101"] <- "Quality so low that it is not useful"
  levels(x$VI_useful)[levels(x$VI_useful)=="1110"] <- "L1B data faulty"
  levels(x$VI_useful)[levels(x$VI_useful)=="1111"] <- "Not useful for any other reason/not processed"
  x$AerQuantity <- as.factor(x$AerQuantity)
  levels(x$AerQuantity)[levels(x$AerQuantity)=="00"] <- "Climatology"
  levels(x$AerQuantity)[levels(x$AerQuantity)=="01"] <- "Low"
  levels(x$AerQuantity)[levels(x$AerQuantity)=="10"] <- "Average"
  levels(x$AerQuantity)[levels(x$AerQuantity)=="11"] <- "High"
  x$AdjCloud <- sapply(x$AdjCloud, .tn2bool)
  x$AtmBRDF <- sapply(x$AtmBRDF, .tn2bool)
  x$MixCloud <- sapply(x$MixCloud, .tn2bool)
  x$LandWater <- as.factor(x$LandWater)
  levels(x$LandWater)[levels(x$LandWater)=="000"] <- "Shallow ocean"
  levels(x$LandWater)[levels(x$LandWater)=="001"] <- "Land (Nothing else but land)"
  levels(x$LandWater)[levels(x$LandWater)=="010"] <- "Ocean coastlines and lake shorelines"
  levels(x$LandWater)[levels(x$LandWater)=="011"] <- "Shallow inland water"
  levels(x$LandWater)[levels(x$LandWater)=="100"] <- "Ephemeral water"
  levels(x$LandWater)[levels(x$LandWater)=="101"] <- "Deep inland water"
  levels(x$LandWater)[levels(x$LandWater)=="110"] <- "Moderate or continental ocean"
  levels(x$LandWater)[levels(x$LandWater)=="111"] <- "Deep ocean"
  x$snowice <- sapply(x$snowice, .tn2bool)
  x$shadow <- sapply(x$shadow, .tn2bool)
  return(x)
}



# DEPRECATED (moved to scidbutil) - Cast MOD13Q1 quality data to codes
#
# @param x A data frame containing the column c("quality")
# @return A data frame with additional columns.
# @notes: See TABLE 2: MOD13Q1 VI Quality at https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod13q1
.mod13q1quality2codes <- function(x){
  rqa <- .invertString(R.utils::intToBin(x$quality))
  #
  x$MODLAND_QA <-  substr(rqa, 1, 2)
  x$VI_useful  <-  substr(rqa, 3, 6)
  x$AerQuantity <- substr(rqa, 7, 8)
  x$AdjCloud <-    substr(rqa, 9, 9)
  x$AtmBRDF <-     substr(rqa, 10, 10)
  x$MixCloud <-    substr(rqa, 11, 11)
  x$LandWater <-   substr(rqa, 12, 14)
  x$snowice <-     substr(rqa, 15, 15)
  x$shadow <-      substr(rqa, 16, 16)
  #
  # x$MODLAND_QA <-  .substrRight(rqa, 1, 2)
  # x$VI_useful  <-  .substrRight(rqa, 3, 6)
  # x$AerQuantity <- .substrRight(rqa, 7, 8)
  # x$AdjCloud <-    .substrRight(rqa, 9, 9)
  # x$AtmBRDF <-     .substrRight(rqa, 10, 10)
  # x$MixCloud <-    .substrRight(rqa, 11, 11)
  # x$LandWater <-   .substrRight(rqa, 12, 14)
  # x$snowice <-     .substrRight(rqa, 15, 15)
  # x$shadow <-      .substrRight(rqa, 16, 16)
  return(x)
}


#---- UTIL ----






# Get characters out of a string from the right to the left
# x       A character
# start   A numeric
# end     A numeric
.substrRight <- function(x, start, end){
  return(substr(x, nchar(x) - end + 1, nchar(x) - start + 1))
}





# Invert strings
#
# @param x            A vector made of strings
# @return Character   A vector where the characters of each string are inverted
.invertString <- function(x){
  sapply(lapply(strsplit(x, NULL), rev), paste, collapse="")
}



# Cast a string to logical
#
# @param val  A character. It an take the values "0" or "1"
# @return     A logical. False if val is "0" and True if val is "1"
.tn2bool <- function(val){
  if(val == "0") return(FALSE)
  if(val == "1") return(TRUE)
  return(NA)
}



#---- DEPRECATED ----



# # DEPRECATED: Plot a MOD13Q1 time series according to ist data reliability
# #
# # @param x      A time-ordered data frame
# # @param cols   A character vector containing the name of columns 3 ("timeIndex", "value", "reliability")
# # @param pname  A string for the graph title
# .plotTSrel <- function(x, cols, title){
#   # TODO: add legend! - annotation_custom - rasterGrob
#   nc <- ncol(x)
#   x$good <-     x[, cols[2]]
#   x$marginal <- x[, cols[2]]
#   x$snowice <-  x[, cols[2]]
#   x$cloudy <-   x[, cols[2]]
#   x$fillnodata <- x[, cols[2]]
#   x$good      [x[cols[3]] != 0] <- NA
#   x$marginal  [x[cols[3]] != 1] <- NA
#   x$snowice   [x[cols[3]] != 2] <- NA
#   x$cloudy    [x[cols[3]] != 3] <- NA
#   x$fillnodata[x[cols[3]] != -1] <- NA
#
#   xcol <- x[cols[1]]
#   ycol <- x[cols[2]]
#   b <- ggplot2::ggplot(x, aes(x = xcol, y = ycol))
#   b + ggplot2::geom_line(linetype = 2, size = 0.1) +
#     ggplot2::geom_line(data = x, aes(x = xcol, y = good),       size = 1, colour = "green") +
#     ggplot2::geom_line(data = x, aes(x = xcol, y = marginal),   size = 1, colour = "gray") +
#     ggplot2::geom_line(data = x, aes(x = xcol, y = snowice),    size = 1, colour = "yellow") +
#     ggplot2::geom_line(data = x, aes(x = xcol, y = cloudy),     size = 1, colour = "blue") +
#     ggplot2::geom_line(data = x, aes(x = xcol, y = fillnodata), size = 1, colour = "red") +
#     ggplot2::labs(title = title) +
#     ggplot2::labs(x = cols[1]) +
#     ggplot2::labs(y = cols[2])
# }
