#' filterField
#' 
#' @title Selecting/filtering experimental data based on different criteria.
#' 
#' @description This function allows to filter regions on the original data.
#' 
#' @param field object of class SpatialPointsDataFrame.
#' @param shape crop/select the object area using this shape as reference. If shape=NULL, 
#'  all field data will be used for filtering. 
#' @param trait vector with the trait to be used as filter criteria.
#' @param value referent value of cropping in the data (must be numeric).
#' @param cropAbove if TRUE all values above the 'value' will be selected to the new data.
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
filterField<-function( field, shape=NULL, trait=NULL, value=NULL, cropAbove=NULL,cex=1){

Data<-field@data

if(is.null(trait)){
  stop(paste("Choose one or more 'trait' for filtering in this list: ",paste(colnames(Data),collapse = ", "),".",sep=""))
}
if(!all(trait%in%colnames(Data))){
  stop(paste("'trait' is not in the list: ", paste(colnames(Data),collapse = ", "),".",sep=""))
}
if(!all(is.numeric(value))){
  stop(paste("Choose one numeric value as a treshold/crop for each 'trait' in this list: ",paste(trait,collapse = ", "),".",sep=""))
}
if(length(value)!=length(trait)){
  stop(paste("'value' must be the same length of 'trait': ",length(trait),".",sep=""))
}
if(!is.logical(cropAbove)){
  stop("'cropAbove' must be logical(TRUE or FALSE)")
}
if(length(cropAbove)!=length(trait)){
  stop(paste("'cropAbove' must be TRUE or FALSE and with the same length of 'trait': ",length(trait),".",sep=""))
}
filtered<-field
par(mfrow = c(1,length(trait)+1))
plot(field,col="bisque3",main="Original",pch=20,cex=cex)
if(!is.null(shape)){
  filtered <- crop(x = filtered, y = shape)
  plot(shape,col="gold4",add=T,pch=20)
}
for(i in 1:length(trait)){
  print(paste("Filter ",i,": cleaning for the trait '",trait[i],"' using the value '",value[i],"' and cropAbove=",cropAbove[i],".",sep=""))
  Data<-filtered@data
  vector<-Data[,colnames(Data)==trait[i]]
  if(value[i]>max(vector,na.rm = T)|value[i]<min(vector,na.rm = T)){
    stop(paste("Choose a 'value' for filtering the trait '",trait,"' between ",min(vector,na.rm = T)," and ",max(vector,na.rm = T),".",sep=""))
  }
  if(cropAbove[i]){
    sel<-vector>value[i]
    sel[is.na(sel)]<-FALSE
    title<-paste(" > ",value[i],sep="")
  }
  if(!cropAbove[i]){
    sel<-vector<value[i]
    sel[is.na(sel)]<-FALSE
    title<-paste(" < ",value[i],sep="")
  }
  filtered <- filtered[sel,]
  if(!is.null(shape)){
    plot(shape,main=paste("Filter: ",trait[i],title,sep=""))
    plot(filtered,col="gold4",pch=20,add=T,cex=cex)
  }
  if(is.null(shape)){
    plot(filtered,col="gold4",main=paste("Filter: ",trait[i],title,sep=""),pch=20,cex=cex)
    }
}
par(mfrow = c(1, 1))
return(filtered)
}





  


