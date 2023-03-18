#' filterField
#' 
#' @title Filter spatial vector data based on value
#' 
#' @description This function filters spatial vector data based on trait value.
#' 
#' @param field SpatVector. The field to be filtered.
#' @param shape a specific area inside the field to be filtered. If shape=NULL, all field data will be used for filtering. 
#' @param trait a vector of the traits to be used as filter criteria.
#' @param value threshold value to filter the trait data (must be numeric).
#' @param cropAbove if TRUE all data above the 'value' will be retained. if FALSE all data below the 'value' will be retained.
#' @param cex point size. Please check \code{help("points")}.
#' 
#' @importFrom terra crop plot
#' @importFrom graphics par 
#' @importFrom methods as is 
#' 
#'
#' @return the filtered SpatVector.
#' 
#'
#' @export
filterField = function (field, shape = NULL, trait = NULL, value = NULL, cropAbove = NULL, 
          cex = 1) 
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
  if (!is.logical(cropAbove)) {
    stop("'cropAbove' must be logical(TRUE or FALSE)")
  }
  if (length(cropAbove) != length(trait)) {
    stop(paste("'cropAbove' must be TRUE or FALSE and with the same length of 'trait': ", 
               length(trait), ".", sep = ""))
  }
  filtered <- field
  par(mfrow = c(1, length(trait) + 1))
  terra::plot(field, col = "bisque3", main = "Original", pch = 20, 
       cex = cex)
  if (!is.null(shape)) {
    filtered <- terra::crop(x = filtered, y = shape)
    terra::plot(shape, col = "gold4", add = T, pch = 20)
  }
  for (i in 1:length(trait)) {
    print(paste("Filter ", i, ": cleaning for the trait '", 
                trait[i], "' using the value '", value[i], "' and cropAbove=", 
                cropAbove[i], ".", sep = ""))
    Data <- values(filtered)
    vector <- Data[, colnames(Data) == trait[i]]
    if (value[i] > max(vector, na.rm = T) | value[i] < min(vector, 
                                                           na.rm = T)) {
      stop(paste("Choose a 'value' for filtering the trait '", 
                 trait, "' between ", min(vector, na.rm = T), 
                 " and ", max(vector, na.rm = T), ".", sep = ""))
    }
    if (cropAbove[i]) {
      sel <- vector > value[i]
      sel[is.na(sel)] <- FALSE
      title <- paste(" > ", value[i], sep = "")
    }
    if (!cropAbove[i]) {
      sel <- vector < value[i]
      sel[is.na(sel)] <- FALSE
      title <- paste(" < ", value[i], sep = "")
    }
    filtered <- filtered[sel, ]
    if (!is.null(shape)) {
      terra::plot(shape, main = paste("Filter: ", trait[i], title, 
                               sep = ""))
      terra::plot(filtered, col = "gold4", pch = 20, add = T, 
           cex = cex)
    }
    if (is.null(shape)) {
      terra::plot(filtered, col = "gold4", main = paste("Filter: ", 
                                                 trait[i], title, sep = ""), pch = 20, cex = cex)
    }
  }
  par(mfrow = c(1, 1))
  return(filtered)
}
