#' rasterField
#' 
#' @title Make a raster from shapefile data
#' 
#' @description This function makes raster layers from shapefile data.
#' 
#' @param field SpatVector. The shapefile to be converted to raster.
#' @param res resolution to make the raster layer.
#' @param trait vector with the traits to be converted to raster.
#' @param shape a specific area inside the field to be converted to raster. If shape=NULL, all field data will be converted.
#' @param cex point size. Please check \code{help("points")}.
#' 
#' @importFrom terra plot crs crop rasterize rast ext
#' @importFrom grDevices grey
#' @importFrom methods as is
#' 
#'
#' @return A raster stack in form SpatRaster.
#' 
#'
#' @export
rasterField <- function (field, res = 1, trait = NULL, shape = NULL, cex = 1) 
{
  print(paste("Field class is ", class(field)[1], sep = ""))
  if (!is.null(shape)) {
    par(mfrow = c(1, 2))
    terra::plot(field, col = "bisque3", main = "Original", pch = 20, 
         cex = cex)
    terra::plot(shape, col = "gold4", add = T, pch = 20, cex = cex)
    field <- terra::crop(x = field, y = shape)
  }
  Data <- values(field)
  if (is.null(trait)) {
    stop(paste("Choose one or more 'trait' for filtering in this list: ", 
               paste(colnames(Data), collapse = ", "), ".", sep = ""))
  }
  r <- terra::rast(ext(field), resolution = res)
  Out <- NULL
  for (t in trait){
    Out1 = terra::rasterize(x = field, y = r, t, fun = mean)
    crs(Out1) <- crs(field)
    Out <- c(Out, Out1)
  }
  Out <- rast(Out)
  set.names(Out, trait)
  terra::plot(Out, col = grey(100:1/100))
    if (!is.null(shape)) {
      terra::plot(shape, add = T)
    }
  
  par(mfrow = c(1, 1))
  return(Out)
}
