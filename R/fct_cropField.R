#' cropField
#' 
#' @title Selecting/cropping experimental field from original data
#' 
#' @description This function allows to crop or select regions on the original data.
#' 
#' @param field object of class SpatialPointsDataFrame.
#' @param shape crop/select the object area using this shape as reference. If shape=NULL, 
#'  the user will need to draw one or more polygon(s).
#' @param nPolygon number of polygons.
#' @param nPoint number of points necessary to select field boundaries or area per polygon (4 >= nPoint <= 50).
#' @param cex point expansion/size. Please check \code{help("points")}.
#' 
#' @importFrom raster projection crop as.data.frame
#' @importFrom graphics lines par points locator 
#' @importFrom sp Polygons plot Polygon SpatialPolygonsDataFrame SpatialPolygons   
#' @importFrom rgeos gDifference
#' @importFrom methods as
#' 
#'
#' @return A list with three elements
#' \itemize{
#' \item \code{shape} is the \code{Shape} format \code{SpatialPolygonsDataFrame}.
#' \item \code{cropField} is the original object area without the region/area in the shape.
#' \item \code{selectedField} is the region/area in the shape.  
#' }
#' 
#'
#' @export
cropField<-function(field, shape=NULL, nPolygon=1, nPoint=4, cex=1)
{
  print(paste("Field class is ",class(field)[1],sep = ""))
  
  if (nPoint < 4 | nPoint > 50) {
    stop("nPoint must be >= 4 and <= 50")
  }
  par(mfrow = c(1, 3))
  plot(field,col="bisque3",main="Original",pch=20,cex=cex)
  
  if(is.null(shape)){
  for (np in 1:nPolygon) {
      print(paste("Select ", nPoint, " points around of polygon (", 
                  np, ") in the plots space.", sep = ""))
      c1 <- NULL
      for (i in 1:nPoint) {
        c1.1 <- locator(type = "p", n = 1, col = np, 
                        pch = 19)
        c1 <- rbind(c1, c(c1.1$x, c1.1$y))
      }
      c1 <- rbind(c1, c1[1, ])
      colnames(c1) <- c("x", "y")
      lines(c1, col = np, type = "l", lty = 2, lwd = 3)
      p1 <- Polygons(list(Polygon(c1)), "x")
      f1 <- SpatialPolygonsDataFrame(SpatialPolygons(list(p1)), 
                                     data.frame(z = 1, row.names = c("x")))
      raster::projection(f1) <- raster::projection(field)
      if (np == 1) {
        shape <- f1
      }
      if (np != 1) {
        shape <- rbind(shape, f1)
      }
  }
  }
    r <- crop(x = field, y = shape)
    r1 <- gDifference(field,r)
    plot(r, add=T, col="gold4", pch=20,cex=cex)
    plot(shape, add=T,pch=20)
    if(!is.null(r1)){
      plot(r1, col="bisque3", main="cropField",pch=20,cex=cex)
    }
    if(is.null(r1)){
      plot(shape, main="shape",pch=20)
    }
    plot(r, col="gold4",main="selectedField",pch=20,cex=cex)
  if(!is.null(shape)){
    plot(shape,add=T)
  }
    shape@data <- data.frame(polygonID = as.character(seq(1,nPolygon)))
    Out <- list(
      shape = shape, 
      cropField = r1,
      selectedField = r)
  par(mfrow = c(1, 1))
  return(Out)
}
