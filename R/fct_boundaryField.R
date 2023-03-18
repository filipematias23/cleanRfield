#' boundaryField
#' 
#' @title Create a boundary shapefile from raster data
#' 
#' @description This function produces a simplified boundary shapefile from raster data.  
#' 
#' @param field SpatRaster. Field to be converted to boundary shapefile.
#' @param draw use TRUE to draw field boundaries.
#' @param col line color.
#' @param cex point size. Please check \code{help("points")}.
#' @param threshold area (m^2) of small polygons, below which will be removed.
#' @param tolerance boundary simplification - minimum distance between nodes in units of the crs (i.e. degrees for long/lat)
#' 
#' @importFrom units set_units
#' @importFrom terra simplifyGeom fillHoles aggregate as.polygons plot draw crs
#' @importFrom smoothr drop_crumbs
#' @importFrom grDevices grey
#' @importFrom methods as is
#'
#' @return A simplified boundary as SpatVector.
#' 
#'
#' @export
boundaryField <- function (field, draw = FALSE, col = "red", cex = 1, threshold = 1000, tolerance = 0.0002) 
{
  print(paste("Field class is ", class(field)[1], sep = ""))
  if (!draw) {
    if (!class(field) %in% c("SpatRaster")) {
      stop("For automatic boundary identification, 'boundaryField()' function requires a raster object. Please, use the function 'rasterField()' first or use 'draw=T' for drawing the boundary.")
    }
    par(mfrow = c(1, 2))
    area_thresh <- units::set_units(threshold, m^2)
    shape <- simplifyGeom(smoothr::drop_crumbs(fillHoles(aggregate(as.polygons(field),fun=mean)), threshold = area_thresh),
                          tolerance = tolerance)
  }
  if (draw) {
    par(mfrow = c(1, 3))
    print("Draw field 'boundary' and press 'ESC' when done.")
    if (class(field) %in% c("SpatRaster")) {
      terra::plot(field, axes = FALSE, box = FALSE, col = grey(100:1/100), 
           main = "Draw field 'boundary' and press 'ESC' when done")
    }
    if (!class(field) %in% c("SpatRaster")) {
      terra::plot(field, col = "bisque3", cex = cex, main = "Draw field 'boundary' and press 'ESC' when done")
    }
    shape <- draw(x="polygon", col = col, lwd = 1)
  }
  crs(shape) <- crs(field)
  
  if (class(field) %in% c("SpatRaster")) {
    terra::plot(field, col = grey(100:1/100), main = "Original")
  }
  if (!class(field) %in% c("SpatRaster")) {
    terra::plot(field, col = "gold4", main = "Original", cex = cex)
  }
  terra::plot(shape, add = T)
  terra::plot(shape, main = "Shapefile")
  par(mfrow = c(1, 1))
  return(shape)
}
