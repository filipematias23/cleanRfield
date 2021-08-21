#' rasterField
#' 
#' @title Making raster from original data
#' 
#' @description This function allows to make raster layers from original data.
#' 
#' @param field object of class SpatialPointsDataFrame.
#' @param res resolution to make the raster layer.
#' @param trait vector with the trait to be used as filter criteria.
#' @param shape crop/select the object area using this shape as reference. If shape=NULL, 
#'  the user will need to draw one or more polygon(s).
#' @param cex point expansion/size. Please check \code{help("points")}.
#' 
#' @importFrom raster plot projection crop rasterize raster extent stack
#' @importFrom grDevices grey
#' @importFrom methods as is
#' 
#'
#' @return A image format stack.
#' 
#'
#' @export
rasterField<-function(field, res = 1, trait = NULL, shape=NULL,cex=1){
  print(paste("Field class is ",class(field)[1],sep = ""))
  if(!is.null(shape)){
    par(mfrow=c(1,2))
    plot(field,col="bisque3",main="Original",pch=20,cex=cex)
    plot(shape,col="gold4",add=T,pch=20,cex=cex)
    field <- crop(x = field, y = shape)
  }
  Data<-field@data
  if(is.null(trait)){
    stop(paste("Choose one or more 'trait' for filtering in this list: ",paste(colnames(Data),collapse = ", "),".",sep=""))
  }
  r<-raster(extent(field),res=res)
  Out = rasterize(x = field, y = r, trait, fun = mean)
  raster::projection(Out)<-raster::projection(field)
  if(length(trait)==1){
    raster::plot(Out[[1]], col = grey(100:1/100))
    if(!is.null(shape)){
    plot(shape,add=T)
  }
  }
  if(length(trait)!=1){
    raster::plot(Out[[trait]], col = grey(100:1/100))
    if(!is.null(shape)){
    plot(shape,add=T)
  }
  }
  par(mfrow=c(1,1))
  return(stack(Out))
}
