rm(list=ls())
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
# devtools::install_github("filipematias23/cleanRfield")

###################
### cleanRfield ###
###################

library(cleanRfield)
library(terra)

### Opening Sample Field 1 ### 
par(mfrow=c(1,2)) 
EX1<-vect("EX1/EX1.shp")
plot(EX1, main="Data Point") 

EX1.Shape<-vect("EX1_boundary/EX1_boundary.shp")
plot(EX1.Shape, main="Field Boundary") 
par(mfrow=c(1,1)) 

# "Use cursor to select 4 points around of polygon (1) in the plots window." 
EX1.C<-cropField(field = EX1, nPolygon = 1, nPoint = 4) 

plot(EX1.C$shape,main="Drawing Shape") 

# Using the shape drawn above to crop data: 
EX1.C<-cropField(field = EX1, shape = EX1.C$shape) 

# All data will be selected using the full boundary as shape: 
EX1.C1<-cropField(field = EX1, shape = EX1.Shape)  

#Open an extra plot window  
x11()  
# "Use cursor to select 4 points around of polygon (1) in the plots window." 
EX1.C<-cropField(field = EX1, nPolygon = 1, nPoint = 4) 

# Sampling 5%: 
EX1.S<-sampleField(field = EX1, size = 0.05)  

# Sampling 10% under a small shape: 
EX1.S<-sampleField(field = EX1,shape = EX1.C$shape, size = 0.1)  

# Sampling 10% under a full shape: 
EX1.S<-sampleField(field = EX1,shape = EX1.Shape, size = 0.1)  

# Check projection to observe 'LENGTHUNIT': 
crs(EX1)

# Unprojected Data (non or NA): use resolution around 0.00008 to create a raster for "Dry_Yield": 
EX1.R<-rasterField(field = EX1, 
                   trait = c("Dry_Yield"), 
                   res = 0.00008) 

# Projected Data (e.g., +units=m or +units=us-ft): use resolution around 5 to 20 to create a raster for "Dry_Yield": 
EX1.R<-rasterField(field = EX1, 
                   trait = c("Dry_Yield"), 
                   res = .0002)                    

# Making raster only for the small shape: 
EX1.R<-rasterField(field = EX1, 
                   shape = EX1.C$shape, 
                   trait = c("Dry_Yield"), 
                   res = 0.00008) # Attention: for projected data use res=20 (e.g., +units=m or +units=us-ft). 

# Multilayer raster for two or more traits: 
EX1.R<-rasterField(field = EX1, 
                   trait = c("Dry_Yield","Speed"), 
                   res = 0.00008) # Attention: for projected data use res=20 (e.g., +units=m or +units=us-ft). 

# Different raster color visualizations: 
library(RColorBrewer) 
par(mfrow=c(2,3)) 
plot(EX1.R$Dry_Yield) 
plot(EX1.R$Dry_Yield,col = heat.colors(10)) 
plot(EX1.R$Dry_Yield,col = topo.colors(10)) 
plot(EX1.R$Dry_Yield,col = brewer.pal(11, "RdYlGn")) 
plot(EX1.R$Dry_Yield,col = brewer.pal(9, "BuGn")) 
plot(EX1.R$Dry_Yield,col = brewer.pal(9, "Greens")) 
par(mfrow=c(1,1)) 

# Making shapefile of field boundary
EX1.P<-boundaryField(field = EX1.R$Dry_Yield, tolerance = 0.0004) # Yield data did not capture borders of field  
EX1.P<-boundaryField(field = EX1.R$Speed) # Speed data has defined field borders, we use default tolerance

EX1.P<-boundaryField(field = EX1, draw = TRUE) 

# Upper field: 
EX1.P1<-boundaryField(field = EX1, draw = T) # Manually 

# Middle field: 
EX1.P2<-boundaryField(field = EX1, draw = T) 

# Lower field: 
EX1.P3<-boundaryField(field = EX1, draw = T)

# Combining field on the same shapefile: 
EX1.P<-rbind(EX1.P1,EX1.P2,EX1.P3) 
plot(EX1.P) 

# Check projection to observe 'LENGTHUNIT': 
crs(EX1)

# Unprojected Data (e.g., non or NA): buffer of -15 meters:
EX1.B<-bufferField(shape = EX1.Shape,value = -15) 

# Projected Data (e.g., +units=m or +units=us-ft): buffer of -50 meters: 
EX1.B<-bufferField(shape = EX1.Shape, value = -50) 

# Buffer of (Unprojected Data) and -5 (Projected Data): 
EX1.B<-bufferField(shape = EX1.Shape, 
                   field = EX1, 
                   value = -15) # Attention: for projected data use 'value=-5' (e.g., +units=m or +units=us-ft). 

par(mfrow=c(1,2)) 
hist(EX1$Dry_Yield) 
hist(EX1$Speed) 
par(mfrow=c(1,1)) 

# Filtering data for Dry_Yield>50 and Dry_Yield<70: 
EX1.F<-filterField(field = EX1, 
                   trait = c("Dry_Yield","Dry_Yield"), 
                   value = c(50,70), 
                   cropAbove = c(T,F)) 

# Filtering data for Dry_Yield>50 and Dry_Yield<70 (only for the data on the small shapefile): 

EX1.F<-filterField(field = EX1, 
                   shape = EX1.C$shape, 
                   trait = c("Dry_Yield","Dry_Yield"), 
                   value = c(50,70), 
                   cropAbove = c(T,F)) 

# Filtering data for Dry_Yield>70 and Speed<5 (using the buffer shapefile): 

EX1.F<-filterField(field = EX1, 
                   shape = EX1.B$newShape, 
                   trait = c("Dry_Yield","Speed"), 
                   value = c(70,5), 
                   cropAbove = c(T,F)) 

# Filtering data for Dry_Yield sd<0.2: 

EX1.SD<-sdField(field = EX1, 
                trait = c("Dry_Yield"), 
                value = 0.2) 

# Filtering data for Dry_Yield sd<0.5 and Dry_Yield sd<0.2: 

EX1.SD<-sdField(field = EX1, 
                trait = c("Dry_Yield","Dry_Yield"), 
                value = c(0.5,0.2)) 

# Filtering data for Dry_Yield sd<0.5 and Speed sd<0.2 (only for the data on the small shapefile): 

EX1.SD<-sdField(field = EX1, 
                shape = EX1.C$shape, 
                trait = c("Dry_Yield","Speed"), 
                value = c(0.5,0.2)) 

# Filtering data for Dry_Yield sd<0.5 and Speed sd<0.2 (using the buffer shapefile): 

EX1.SD<-sdField(field = EX1, 
                shape = EX1.B$newShape, 
                trait = c("Dry_Yield","Speed"), 
                value = c(0.5,0.2)) 

################ 
### Parallel ### 
################ 

# Required packages 
library(parallel) 
library(foreach) 
library(doParallel) 

# Files names (folder directory: "./field/" and "./boundary/") 
field<-unique(do.call(rbind,strsplit(list.files("./field/"),split = "[.]"))[,1]) 
boundary<-unique(do.call(rbind,strsplit(list.files("./boundary/"),split = "[.]"))[,1]) 

# General filter information: 
buffer=-50 # Boundary buffer of 50 feet 
trait = c("Dry_Yield","Speed") # Filtered traits 
filter.value = c(50,7) # cropping filter values  
cropAbove = c(T,T) # All values above the filter.value 
sd.value = c(1,1) # All values between sd=1 

# Number of cores 
n.core<-3 

# Starting parallel 
cl <- makeCluster(n.core, output = "") 
registerDoParallel(cl) 
Filtered_Field <-foreach(i = 1:length(field),  
                         .packages = c("terra","cleanRfield")) %dopar% { 
                           
                           # Uploading data and boundary 
                           F.ex<-vect(paste("./field/",field[i],".shp",sep="")) 
                           B.ex<-vect(paste("./boundary/",boundary[i],".shp",sep="")) 
                           
                           # Filtering the borders by buffering the boundary shape file: 
                           B.ex<-bufferField(shape = B.ex,value = buffer)
                           
                           # Filtering data based on observed traits values: 
                           F.ex<-filterField(field = F.ex, 
                                             shape = B.ex, 
                                             trait = trait, 
                                             value = filter.value, 
                                             cropAbove = cropAbove)
              
                           # Filtering data based on standard deviation values: 
                           F.ex<-sdField(field = F.ex, 
                                         shape = B.ex, 
                                         trait = trait, 
                                         value = sd.value) 
                           
                           # New filtered data and boundary files:
                           return(list(NewField=wrap(F.ex), NewBoundary=wrap(B.ex))) 
                         } 

stopCluster(cl) 
names(Filtered_Field)<-field 

# Output 
Filtered_Field = lapply(unlist(Filtered_Field), unwrap)

# New filtered - EX2_center 
plot(Filtered_Field$EX2_center.NewBoundary, main="EX2_center") 
plot(Filtered_Field$EX2_center.NewField, add=T, col="gold4",pch=20,cex=0.5) 


# New filtered - EX2_north 
plot(Filtered_Field$EX2_north.NewBoundary, main="EX2_north") 
plot(Filtered_Field$EX2_north.NewField, add=T, col="gold4",pch=20,cex=2) 


# New filtered - EX2_south 
plot(Filtered_Field$EX2_south.NewBoundary, main="EX2_south") 
plot(Filtered_Field$EX2_south.NewField, add=T, col="gold4",pch=20,cex=1) 


# Combined new data: 
NewField<-rbind(Filtered_Field$EX2_center.NewField, 
                Filtered_Field$EX2_north.NewField, 
                Filtered_Field$EX2_south.NewField) 

# Giving names to each field: 
Filtered_Field$EX2_center.NewBoundary$ID<-field[1] 
Filtered_Field$EX2_north.NewBoundary$ID<-field[2] 
Filtered_Field$EX2_south.NewBoundary$ID<-field[3] 

# Combining field on the same shape file: 
NewBoundary<-rbind(Filtered_Field$EX2_center.NewBoundary, 
                   Filtered_Field$EX2_north.NewBoundary, 
                   Filtered_Field$EX2_south.NewBoundary) 

plot(NewBoundary, main="EX2_full") 
plot(NewField, add=T, col="gold4",pch=20,cex=0.5) 

# Make a very basic plot where brighter colors denote higher yield 
terra::plot(EX1, "Dry_Yield")
            
#Adjusting breaks changes the number of categories in the legend 
terra::plot(EX1, "Dry_Yield", breaks=6)  

#convert the object EX1 into an sf object named EX1sf 
library(sf) 
EX1sf<-st_as_sf(EX1)  

#plot the data using geom_sf and the ggplot2 default color gradient 
library(ggplot2) 
ggplot()+ 
  geom_sf(data=EX1sf, aes(color= Dry_Yield))+  
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

#or make a figure using fewer of the ggplot2 display defaults 
EX1.F10<-filterField(field = EX1,  #filtering with Dry_Yield>10 to create a different example for plotting data 
                     trait = "Dry_Yield", 
                     value = 10, 
                     cropAbove = T)  
EX1sf10<-st_as_sf(EX1.F10) #converting the object EX1.F10 into an sf object 
ggplot() +  
  geom_sf(data = EX1sf10, aes(color = Dry_Yield), size = 0.01) + #made the individual points smaller 
  scale_color_gradient(low = "yellow2", high = "green4") + #created a different color gradient 
  ggtitle("Field EX1.F10 Filtered Yield") + #added a main figure title 
  labs(color='Dry Yield (bu/acre)') + #changed legend title 
  theme_void() #removed grid background from figure 

writeVector(EX1.B$newField, "EX1.newField.shp", filetype="ESRI Shapefile") 
EX1.newField <- vect("EX1.newField.shp") # Reading the saved data points. 

# reading in the .csv file 
DF<-read.csv("EX3.csv") 
colnames(DF) #checking that the latitude is the first column and longitude is the second column 

# creating the coordinates object using the latitude and longitude columns 
DF$xy <- lapply(c('Long','Lat'), c())
DF$xy = c(df$Long,df$Lat)
xy <- DF[,c(1,2)] 

# creating a new spatial points data frame from the data in DF 
SpatialDF <- vect(DF, geom=c('Long','Lat'), crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
crs(SpatialDF)

#### additional packages needed for interpolation & mapping #### 
library(gstat) # used to make the idw model 
library(sp) # used to prepare the raster grid with spsample function 
library(tmap) # used for visualization 

#### preparing the yield data #### 
EX1 <- vect("EX1/EX1.shp") # EX1.shp download link is in tutorial section 1 
EX1.Shape <- vect("EX1_boundary/EX1_boundary.shp") #EX1_boundary.shp download link is in tutorial section 1  

# filtering data to remove biologically unlikely soybean yield observations and NA values 
EX1.F <- filterField(field = EX1, 
                     trait = c("Dry_Yield","Dry_Yield"), 
                     value = c(10,100), 
                     cropAbove = c(T,F))  

# transforming the filtered data so that it is a projected CRS 
EX1_merc <- spTransform(as_Spatial(st_as_sf(EX1.F)), CRS=CRS("+proj=merc +ellps=GRS80")) 
EX1_merc # looking at summary output to check projection 

#transforming the boundary too-- this will be used later for visualization 
EX1.Shape_merc <- spTransform(as_Spatial(st_as_sf(EX1.Shape)), CRS=CRS("+proj=merc +ellps=GRS80")) 
EX1.Shape_merc #looking at summary output to check projection 

#### preparing an empty grid #### 
G <- as.data.frame(spsample(EX1_merc,"regular", n=50000)) #n = total number of grid cells 
names(G) <- c("X", "Y") 
coordinates(G) <- c("X", "Y") 
gridded(G) <- TRUE  # create SpatialPixel object 
fullgrid(G) <- TRUE  # create SpatialGrid object 
proj4string(G) <- proj4string(EX1_merc) # using the projection from EX1_merc to project the grid G 
proj4string(G) # checking that G is projected 

#### running IDW using the yield data and empty grid #### 
Yield.idw <- gstat::idw(Dry_Yield ~ 1, EX1_merc, newdata=G, idp=2.0) 

#### visualizing IDW interpolation #### 
r.idw <- raster::raster(Yield.idw) # convert the IDW model to a RasterStack 
r.masked <- raster::mask(r.idw, EX1.Shape_merc) # mask the raster to the field boundary 

yieldmap.idw <- tm_shape(r.masked) + #make the map using functions from the tmap library 
  tm_raster(n=10,palette = "YlGn",  
            title="Dry Yield") +  
  tm_legend(legend.outside=TRUE) 
yieldmap.idw #view the map 

#### additional packages needed for interpolation & mapping #### 
library(gstat) # used to make the idw model 
library(sf)
library(sp) # used to prepare the raster grid with spsample function 
library(tmap) # used for visualization 

#### preparing the yield data #### 
EX1 <- vect("EX1/EX1.shp") # EX1.shp download link is in tutorial section 1 
EX1.Shape <- vect("EX1_boundary/EX1_boundary.shp") #EX1_boundary.shp download link is in tutorial section 1  

# filtering data to remove biologically unlikely soybean yield observations and NA values 
EX1.F <- filterField(field = EX1, 
                     trait = c("Dry_Yield","Dry_Yield"), 
                     value = c(10,100), 
                     cropAbove = c(T,F))  

# transforming the filtered data so that it is a projected CRS 
EX1_merc <- spTransform(as_Spatial(st_as_sf(EX1.F)), CRS=CRS("+proj=merc +ellps=GRS80")) 
EX1_merc # looking at summary output to check projection 

#transforming the boundary too-- this will be used later for visualization 
EX1.Shape_merc <- spTransform(as_Spatial(st_as_sf(EX1.Shape)), CRS=CRS("+proj=merc +ellps=GRS80")) 
EX1.Shape_merc #looking at summary output to check projection 

#### make a variogram to assess spatial relationships between yield observations #### 
v_overall <- variogram(Dry_Yield~1, data = EX1_merc)  
plot(v_overall) # visually estimate sill, model shape, range, and nugget 
vmodel_overall <- vgm(psill=150, model="Sph", nugget=100, range=400) # estimate variogram model 
fittedmodel_overall <- fit.variogram(v_overall, model=vmodel_overall) # fit variogram model    
fittedmodel_overall #print the fitted model to see how it compares to your initial estimate 
plot(v_overall, model=fittedmodel_overall)  


# let's see if the spatial autocorrelation is the same in all directions-- is the data anisotrophic? 
gs_object <- gstat(formula=Dry_Yield~ 1, data=EX1_merc) 
v_directional <- variogram(gs_object, alpha=c(0,45,90,135)) 
vmodel_directional <- vgm(model='Sph' , anis=c(0, 0.5)) 
fittedmodel_directional <- fit.variogram(v_directional, model=vmodel_directional) 
plot(v_directional, model=fittedmodel_directional, as.table=TRUE) 


#### sample 20% of yield observations #### 
EX1_merc_10pct<-sampleField(field = EX1_merc, size = 0.2)  

#### update the empty grid and gstat object #### 
# prepare a similar, but smaller, empty grid than the IDW example code 
G             <- as.data.frame(spsample(EX1_merc, "regular", n=10000)) 
names(G)       <- c("X", "Y") 
coordinates(G) <- c("X", "Y") 
gridded(G)     <- TRUE  # Create SpatialPixel object 
fullgrid(G)    <- TRUE  # Create SpatialGrid object 
proj4string(G) <- proj4string(EX1_merc)  
proj4string(G) #checking that G is projected 

# now update the gstat object from before so that it includes the fitted 
# model, not the estimated model from earlier in the kriging workflow 
gs_object <- gstat(formula=Dry_Yield~ 1, 
                   data=as_Spatial(st_as_sf(EX1_merc_10pct)), model=fittedmodel_overall) 

#### run the kriging procedure using the gstat object and empty grid #### 
kriged_surface <- predict(gs_object, model=fittedmodel_overall, newdata=G)  

summary(kriged_surface) 


#### visualizing kriged map #### 
kriged_raster <- raster::raster(kriged_surface) 
kriged_masked <- raster::mask(kriged_raster, EX1.Shape_merc) 

tm_shape(kriged_masked) +  
  tm_raster(n=10,palette = "YlGn",  
            title="Dry Yield") +  
  tm_legend(legend.outside=TRUE)
