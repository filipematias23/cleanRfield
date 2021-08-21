#' sampleField
#' 
#' @title Sampling experimental data points.
#' 
#' @description This function allows to reduce the original data size.
#' 
#' @param field object of class SpatialPointsDataFrame.
#' @param shape crop/select the object area using this shape as reference. If shape=NULL, 
#'  the user will need to draw one or more polygon(s).
#' @param size reduction proportion of original data (must be values between 0 and 1).
#' @param cex point expansion/size. Please check \code{help("points")}.
#' 
#' @importFrom raster crop
#' @importFrom sp plot
#' @importFrom graphics par
#' @importFrom methods as is 
#' 
#'
#' @return A image format stack.
#' 
#'
#' @export
sampleField<-function(field,shape=NULL,size=0.1,cex=1){
  
  print(paste("Field class is ",class(field)[1],sep = ""))
  
  if(size>1|size<0){
    stop("'size' must be a value between 0.0 and 1.0")
  }
  par(mfrow = c(1, 2))
  
  plot(field,col="bisque3",main="Original",pch=20,cex=cex)
  
  if(!is.null(shape)){
    field <- crop(x = field, y = shape)
    plot(shape,col="gold4",add=T,pch=20,cex=cex)
  }
  
  Out <- field[sample(1:dim(field)[1], dim(field)[1]*size),]
  
  plot(Out,col="gold4",main="Reduced",pch=20,cex=cex)
  
   if(!is.null(shape)){
    plot(shape,add=T)
  }
  
  par(mfrow = c(1, 1))
  return(Out)
}
