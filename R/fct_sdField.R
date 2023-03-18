#' sdField
#' 
#' @title Filter spatial vector data based on standard deviation.
#' 
#' @description This function filters the original data based on standard deviation of traits.
#' 
#' @param field SpatVector. The field to be filtered.
#' @param shape a specific area inside the field to be filtered. If shape=NULL, all field data will be used for filtering.
#' @param trait a vector of the traits to be used as filter criteria.
#' @param value threshold value of standard deviation to filter the trait data below (must be numeric).
#' @param cex point size. Please check \code{help("points")}.
#' 
#' @importFrom terra crop plot
#' @importFrom graphics par 
#' @importFrom methods as is 
#' @importFrom stats sd
#' 
#'
#' @return A SpatVector filtered by standard deviation.
#' 
#'
#' @export
sdField <- function (field, shape = NULL, trait = NULL, value = 1, cex = 1) 
{
  Data <- values(field)
  if (is.null(trait)) {
    stop(paste("Choose one or more 'trait' for filtering in this list: ", 
               paste(colnames(Data), collapse = ", "), ".", sep = ""))
  }
  if (!all(trait %in% colnames(Data))) {
    stop(paste("'trait' is not in the list: ", paste(colnames(Data), 
                                                     collapse = ", "), ".", sep = ""))
  }
  if (!all(is.numeric(value))) {
    stop(paste("Choose one numeric value as a treshold/crop for each 'trait' in this list: ", 
               paste(trait, collapse = ", "), ".", sep = ""))
  }
  if (length(value) != length(trait)) {
    stop(paste("'value' must be the same length of 'trait': ", 
               length(trait), ".", sep = ""))
  }
  filtered <- field
  par(mfrow = c(1, length(trait) + 1))
  terra::plot(field, col = "bisque3", main = "Original", pch = 20, 
       cex = cex)
  if (!is.null(shape)) {
    filtered <- crop(x = filtered, y = shape)
    terra::plot(shape, col = "gold4", add = T, pch = 20, cex = cex)
  }
  for (i in 1:length(trait)) {
    Data <- values(filtered)
    vector <- Data[, colnames(Data) == trait[i]]
    mean1 <- mean(as.numeric(as.character(vector)), na.rm = T)
    sd1 <- sd(as.numeric(as.character(vector)), na.rm = T)
    print(paste("Filter ", i, ": cleaning data for the trait '", 
                trait[i], "' (mean=", round(mean1, 2), ") using values between '", 
                value[i], "' degrees of the standard deviation (sd=", 
                round(sd1, 2), ").", sep = ""))
    sel <- abs(vector - mean1) < c(sd1 * value[i])
    sel[is.na(sel)] <- FALSE
    title <- paste("Filter: \n", trait[i], " > ", round(c(mean1 - 
                                                            value[i] * sd1), 2), " and < ", round(c(mean1 + 
                                                                                                      value[i] * sd1), 2), sep = "")
    filtered <- filtered[sel, ]
    if (!is.null(shape)) {
      terra::plot(shape, main = title)
      terra::plot(filtered, col = "gold4", pch = 20, add = T, 
           cex = cex)
    }
    if (is.null(shape)) {
      terra::plot(filtered, col = "gold4", main = title, pch = 20, 
           cex = cex)
    }
  }
  par(mfrow = c(1, 1))
  return(filtered)
}
