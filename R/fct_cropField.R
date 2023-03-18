#' cropField
#' 
#' @title Crop a specified field from original data
#' 
#' @description This function crops selected regions from the original data using an existing shapefile or user-drawn polygon.
#' 
#' @param field SpatVector.
#' @param shape a specified shape for cropping. If shape=NULL, the user will be prompted to draw one or more polygon(s).
#' @param nPolygon number of polygons.
#' @param nPoint number of points per polygon (4 >= nPoint <= 50).
#' @param cex point size. Please check \code{help("points")}.
#' 
#' @importFrom terra plot crop erase lines
#' @importFrom graphics par locator 
#' @importFrom methods as
#'
#' @return A list with three elements:
#' \itemize{
#' \item \code{shape} is the specified cropped geometry, in format \code{SpatVector}.
#' \item \code{cropField} is the original object area without the cropped shape, in format \code{SpatVector}.
#' \item \code{selectedField} the cropped data (contained within the cropped shape), in format \code{SpatVector}.
#' }
#' 
#'
#' @export
cropField = function (field, shape = NULL, nPolygon = 1, nPoint = 4, cex = 1) 
{
  print(paste("Field class is ", class(field)[1], sep = ""))
  if (nPoint < 4 | nPoint > 50) {
    stop("nPoint must be >= 4 and <= 50")
  }
  par(mfrow = c(1, 3))
  terra::plot(field, col = "bisque3", main = "Original", pch = 20, 
       cex = cex)
  if (is.null(shape)) {
    for (np in 1:nPolygon) {
      print(paste("Select ", nPoint, " points around polygon #", 
                  np, " in the plots space.", sep = ""))
      c1 <- NULL
      for (i in 1:nPoint) {
        c1.1 <- locator(type = "p", n = 1, col = np, 
                        pch = 19)
        c1 <- rbind(c1, c(c1.1$x, c1.1$y))
      }
      c1 <- rbind(c1, c1[1, ])
      colnames(c1) <- c("x", "y")
      lines(c1, col = np, type = "l", lty = 2, lwd = 3)
      p1 <- vect(c1, type="polygons")
      if (np == 1) {
        shape <- p1
      }
      if (np != 1) {
        shape <- rbind(shape, p1)
      }
    }
  }
  r <- crop(x = field, y = shape)
  r1 <- erase(x = field, y = shape)
  terra::plot(r, add = T, col = "gold4", pch = 20, cex = cex)
  terra::plot(shape, add = T, pch = 20)
  terra::plot(r1, col = "bisque3", main = "cropField", pch = 20,
    cex = cex)
  terra::plot(r, col = "gold4", main = "selectedField", pch = 20,
    cex = cex)
  terra::lines(shape)

  Out <- list(shape = shape, cropField = r1, selectedField = r)
  par(mfrow = c(1, 1))
  return(Out)
}
