#' bufferField
#' 
#' @title Create a buffer shapefile within the target geometry 
#' 
#' @description This function produces a buffer within the target geometry by a specified value.  
#'
#' @param shape SpatVector. The target geometry to be buffered. Object of class.
#' @param value value of the buffer - measured in mapunits. Must be numeric and negative.
#' @param field SpatVector. If input, field cropped by target geometry included in output. If field=NULL, only the buffer will be generated.
#' @param cex point size. Please check \code{help("points")}.
#' 
#' @importFrom terra buffer crs
#' @importFrom graphics par 
#' @importFrom methods as is 
#' 
#' @return If field=NULL, the buffer SpatVector is returned. If field provided, list with two elements is returned:
#' \itemize{
#' \item \code{newShape} is the buffer SpatVector.
#' \item \code{newField} is the field cropped using the buffered shape, also a SpatVector.
#' } 
#'
#' @export
bufferField <- function (shape, value = c(-1), field = NULL, cex = 1) 
{
  if (!all(is.numeric(value))) {
    stop("'value' must be numeric.")
  }
  options(warn = -1)
  shapeB <- buffer(shape, value)
  crs(shapeB) <- crs(shape)
  options(warn = 0)
  title <- paste0("Filter on shape: \nBuffer = ", value)
  if (is.null(field)) {
    par(mfrow = c(1, 1))
    terra::plot(shape, main = title)
    terra::plot(shapeB, add = T)
    Out = shapeB
  }
  if (!is.null(field)) {
    par(mfrow = c(1, 2))
    terra::plot(shape, main = title)
    terra::plot(shapeB, add = T)
    filtered <- crop(x = field, y = shapeB)
    title <- paste0("Filter on data: \nBuffer = ", value)
    terra::plot(field, col = "bisque3", main = title, pch = 20, 
         cex = cex)
    terra::plot(filtered, col = "gold4", add = T, pch = 20, cex = cex)
    Out = list(newShape = shapeB, newField = filtered)
  }
  par(mfrow = c(1, 1))
  return(Out)
}
