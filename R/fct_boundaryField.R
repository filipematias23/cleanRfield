#' boundaryField
#' 
#' @title Making raster from original data
#' 
#' @description This function allows to make shapefile boundary from raster layers.
#' 
#' @param field object of class 'raster'.
#' @param draw use TRUE for drawing field boundaries.
#' @param col line color.
#' @param cex point expansion/size. Please check \code{help("points")}.
#' 
#' @importFrom raster plot projection drawPoly crop aggregate rasterToPolygons
#' @importFrom sp SpatialPolygonsDataFrame
#' @importFrom grDevices grey
#' @importFrom methods as is
#' 
#'
#' @return shapefile boundary SpatialPolygonsDataFrame.
#' 
#'
#' @export
boundaryField<-function(field,draw=FALSE,col="red",cex=1)
{
  print(paste("Field class is ",class(field)[1],sep = ""))
  if(!draw){
    if(!class(field)%in%c("raster","RasterLayer","RasterStack","stack","RasterBrick","brick")){
      stop("For automatic boundary identification, 'boundaryField()' function requires a raster object. Please, use the function 'rasterField()' first or use 'draw=T' for drawing the boundary.")
    }
    par(mfrow = c(1, 2))
    shape<-aggregate(rasterToPolygons(field))
  }
  if(draw){
    par(mfrow = c(1, 3))
    print("Draw the field 'boundary' and press 'ESC' when it is done.")
    if(class(field)%in%c("raster","RasterLayer","stack","RasterStack","RasterBrick","brick")){
      raster::plot(field, axes = FALSE, box = FALSE, col = grey(100:1/100), main="Use this image \nto draw field 'boundary' \nand press 'ESC' \nwhen it is done")
    }
    if(!class(field)%in%c("raster","RasterLayer","stack","RasterStack","RasterBrick","brick")){
      sp::plot(field,col="bisque3",cex=cex,main="Use this image \nto draw field 'boundary' \nand press 'ESC' \nwhen it is done")
    }
    shape<- drawPoly(sp = T,col = col,lwd = 1)
  }
  shape <- SpatialPolygonsDataFrame(shape,data = data.frame(row.names = 1))
  raster::projection(shape) <- raster::projection(field)
  if(class(field)%in%c("raster","RasterLayer","stack","RasterStack","RasterBrick","brick")){
    raster::plot(field, col = grey(100:1/100), main="Original")
  }
  if(!class(field)%in%c("raster","RasterLayer","stack","RasterStack","RasterBrick","brick")){
    sp::plot(field, col = "gold4", main="Original",cex=cex)
  }
  sp::plot(shape, add=T)
  sp::plot(shape, main="Shapefile")
  par(mfrow = c(1, 1))
  return(shape)
}
