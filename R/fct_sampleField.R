#' sampleField
#' 
#' @title Sample data points within specified field.
#' 
#' @description This function samples a specified SpatVector, reducing the data size.
#' 
#' @param field SpatVector. The field to be sampled.
#' @param shape a specific area inside the field to be sampled. If shape=NULL, all field data will be sampled.
#' @param size the proportion of original data to be sampled (must be values between 0 and 1).
#' @param cex point size. Please check \code{help("points")}.
#' 
#' @importFrom terra crop plot
#' @importFrom graphics par
#' @importFrom methods as is 
#' 
#'
#' @return the sampled field is returned in form SpatVector.
#' 
#'
#' @export
sampleField <- function (field, shape = NULL, size = 0.1, cex = 1) 
{
  print(paste("Field class is ", class(field)[1], sep = ""))
  if (size > 1 | size < 0) {
    stop("'size' must be a value between 0.0 and 1.0")
  }
  par(mfrow = c(1, 2))
  terra::plot(field, col = "bisque3", main = "Original", pch = 20, 
       cex = cex)
  if (!is.null(shape)) {
    field <- crop(x = field, y = shape)
    terra::plot(shape, col = "gold4", add = T, pch = 20, cex = cex)
  }
  Out <- field[sample(1:dim(field)[1], dim(field)[1] * size), 
  ]
  terra::plot(Out, col = "gold4", main = "Reduced", pch = 20, cex = cex)
  if (!is.null(shape)) {
    terra::plot(shape, add = T)
  }
  par(mfrow = c(1, 1))
  return(Out)
}
