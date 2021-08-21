#' bufferField
#' 
#' @title Selecting/filtering experimental data based on shapefile buffering.
#' 
#' @description This function allows to filter regions on the original data based on shapefile reduction using different buffer values.
#' 
#' @param field object of class SpatialPointsDataFrame. If field=NULL, 
#'  only the new shapefile will be generated.
#' @param shape crop/select the object area using this shape as reference. 
#' @param value referent value to be used as a buffer for  the shapefile (must be numeric and negative).
#' @param cex point expansion/size. Please check \code{help("points")}.
#' 
#' @importFrom raster crop buffer
#' @importFrom sp plot
#' @importFrom graphics par 
#' @importFrom methods as is 
#' 
#' @return A list with two elements
#' \itemize{
#' \item \code{newShape} is the \code{Shape} format \code{SpatialPolygonsDataFrame}.
#' \item \code{newField} is the field filtered based on the shape.
#' } 
#'
#' @export
bufferField<-function(shape,value=c(-1),field=NULL,cex=1){
  
  if(!all(is.numeric(value))){
    stop("'value' must be numeric.")
  }
  options(warn=-1)
  shapeB<-buffer(shape,value)
  raster::projection(shapeB)<-raster::projection(shape)
  options(warn=0)
  title<-paste("Filter on shape: \nBuffer = ",value,sep="")
  if(is.null(field)){
    par(mfrow = c(1,1))
    plot(shape,main=title)
    plot(shapeB,add=T)
    Out=shapeB
  }
  if(!is.null(field)){
    par(mfrow = c(1,2))
    plot(shape,main=title)
    plot(shapeB,add=T)
    filtered <- crop(x = field, y = shapeB)
    title<-paste("Filter on data: \nBuffer = ",value,sep="")
    plot(field,col="bisque3",main=title,pch=20,cex=cex)
    plot(filtered,col="gold4",add=T,pch=20,cex=cex)
    Out=list(newField=filtered,newShape=shapeB)
  }
  par(mfrow = c(1, 1))
  return(Out)
}
