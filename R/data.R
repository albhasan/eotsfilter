#' Time series of deforested points in the Amazon forest
#'
#' A dataset containing samples of deforestation in the Amazon forest. The
#' samples are joined to DETER data in order to get the deforestation date.
#' Additionally, the samples are joined to their corresponding time series of
#' MODIS MOD13Q1 data
#' forest.
#'
#' @format A list of 337 elements.
#' \describe{
#'   \item{sample}{A data frame with 1 row and 14 variables. It contains the
#'   sample point data.
#'     \describe{
#'       \item{id}{sample id}
#'       \item{longitude}{sample WGS84 longitude}
#'       \item{latitude}{sample WGS84 latitude}
#'       \item{start_date}{sample start date}
#'       \item{end_date}{sample start date}
#'       \item{label}{class to which the time time series mathches iduring the period given by the start and end dates}
#'       \item{linkcolumn}{DETER link column}
#'       \item{class_name}{DETER class name}
#'       \item{scene_id}{DETER scene id}
#'       \item{areameters}{DETER areameters}
#'       \item{view_date}{DETER date when deforestation was detected}
#'       \item{julday}{DETER day of the year of deforestation detection}
#'       \item{col_id}{SciDB column ID in the MODIS MOD13Q1 array}
#'       \item{row_id}{SciDB row ID in the MODIS MOD13Q1 array}
#'     }
#'   }
#'   \item{time_series}{A data frame with 363 rows and 15 variables. It contains
#'   the time series of MOD13Q1 data of the sample point.
#'     \describe{
#'       \item{col_id}{SciDB column ID in the MODIS MOD13Q1 array}
#'       \item{row_id}{SciDB row ID in the MODIS MOD13Q1 array}
#'       \item{time_id}{SciDB time ID in the MODIS MOD13Q1 array}
#'       \item{ndvi}{MOD13Q1 Normalized Difference Vegetation Index}
#'       \item{evi}{MOD13Q1 Enhanced Vegetation Index}
#'       \item{quality}{MOD13Q1 quality detailed}
#'       \item{red}{MOD13Q1 red reflectance (Band 1)}
#'       \item{nir}{MOD13Q1 Near Infra Red reflectance (Band 2)}
#'       \item{blue}{MOD13Q1 blue reflectance (Band 3)}
#'       \item{mir}{MOD13Q1 Middle Infra Red reflectance (Band 7)}
#'       \item{view_zenith}{MOD13Q1 view zenith angle}
#'       \item{sun_zenith}{MOD13Q1 sun zenith angle}
#'       \item{relative_azimuth}{MOD13Q1 relative azimuth angle}
#'       \item{day_of_year}{MOD13Q1 julian day of year}
#'       \item{reliability}{MOD13Q1 pixel reliability summary QA}
#'     }
#'   }
#' }
#' @source \url{https://github.com/e-sensing/sits/blob/master/inst/extdata/samples/deforestation_points_226_64.csv}
"samples1"



#' Time series of deforested points in the Amazon forest
#'
#' A dataset containing samples of deforestation in the Amazon forest. The
#' samples are joined to DETER data in order to get the deforestation date.
#' Additionally, the samples are joined to their corresponding time series of
#' MODIS MOD13Q1 data
#' forest.
#'
#' @format A list of 100 elements
#' \describe{
#'   \item{sample}{A data frame with 1 row and 14 variables. It contains the
#'   sample point data.
#'     \describe{
#'       \item{id}{sample id}
#'       \item{longitude}{sample WGS84 longitude}
#'       \item{latitude}{sample WGS84 latitude}
#'       \item{start_date}{sample start date}
#'       \item{end_date}{sample start date}
#'       \item{label}{class to which the time time series mathches iduring the period given by the start and end dates}
#'       \item{linkcolumn}{DETER link column}
#'       \item{class_name}{DETER class name}
#'       \item{scene_id}{DETER scene id}
#'       \item{areameters}{DETER areameters}
#'       \item{view_date}{DETER date when deforestation was detected}
#'       \item{julday}{DETER day of the year of deforestation detection}
#'       \item{col_id}{SciDB column ID in the MODIS MOD13Q1 array}
#'       \item{row_id}{SciDB row ID in the MODIS MOD13Q1 array}
#'     }
#'   }
#'   \item{time_series}{A data frame with 363 rows and 15 variables. It contains
#'   the time series of MOD13Q1 data of the sample point.
#'     \describe{
#'       \item{col_id}{SciDB column ID in the MODIS MOD13Q1 array}
#'       \item{row_id}{SciDB row ID in the MODIS MOD13Q1 array}
#'       \item{time_id}{SciDB time ID in the MODIS MOD13Q1 array}
#'       \item{ndvi}{MOD13Q1 Normalized Difference Vegetation Index}
#'       \item{evi}{MOD13Q1 Enhanced Vegetation Index}
#'       \item{quality}{MOD13Q1 quality detailed}
#'       \item{red}{MOD13Q1 red reflectance (Band 1)}
#'       \item{nir}{MOD13Q1 Near Infra Red reflectance (Band 2)}
#'       \item{blue}{MOD13Q1 blue reflectance (Band 3)}
#'       \item{mir}{MOD13Q1 Middle Infra Red reflectance (Band 7)}
#'       \item{view_zenith}{MOD13Q1 view zenith angle}
#'       \item{sun_zenith}{MOD13Q1 sun zenith angle}
#'       \item{relative_azimuth}{MOD13Q1 relative azimuth angle}
#'       \item{day_of_year}{MOD13Q1 julian day of year}
#'       \item{reliability}{MOD13Q1 pixel reliability summary QA}
#'     }
#'   }
#' }
"samples2"
