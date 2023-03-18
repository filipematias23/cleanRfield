
## [cleanRfield](https://github.com/filipematias23/cleanRfield): A tool for cleaning and filtering data spatial points from crop yield maps in [R](https://www.r-project.org).

> This package is a compilation of functions to clean and filter observations from yield monitors or other agricultural spatial point data. Yield monitors are prone to error, and filtering the observations or removing observations from near field boundaries can improve estimates of whole-field yield, combine speed, grain moisture, or other parameters of interest. In this package, users can easily select filters for one or more traits and prepare a smaller dataset to make decisions.

> This tutorial assumes that readers have a basic understanding of spatial data, including projections and coordinate reference systems. If you need a refresher on this topic, we recommend reading [this blog post for deciding between projected and unprojected data](https://spatiallychallenged.com/2018/11/01/selecting-a-projection-for-spatial-analysis/) and [this post for understanding the basics of coordinate reference systems](https://spatiallychallenged.com/2018/11/05/epsg-numbers-and-coordinate-reference-systems/). 

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/CleanRField_large.jpg" width="40%" height="40%">
</p>

<div id="menu" />

---------------------------------------------

## Resources
  
   * [Installation](#Instal)
   * [1. First steps](#P1)
   * [2. Cropping or selecting regions](#P2)
   * [3. Sampling point data](#P3)
   * [4. Making rasters](#P4)
   * [5. Building shape boundaries](#P5)
   * [6. Buffering the field boundaries](#P6)
   * [7. Filtering using data values](#P7)
   * [8. Filtering using standard deviation values](#P8)
   * [9. Evaluating multiple fields on parallel](#P9)
   * [10. Making Maps](#P10)
   * [11. Saving files](#P11)
   * [12. Working with .csv or .txt files](#P12)
   * [13. Interpolating yield maps](#P13)
   * [Contact](#PC)

<div id="Instal" />

---------------------------------------------

> Install [R](https://www.r-project.org/) and [RStudio](https://rstudio.com/).

<br />

> Now install R/cleanRfield using the `install_github()` function from [devtools](https://github.com/hadley/devtools) package. If necessary, use the argument [*type="source"*](https://www.rdocumentation.org/packages/ghit/versions/0.2.18/topics/install_github).

```r
install.packages("devtools")
devtools::install_github("filipematias23/cleanRfield")
```

<br />

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/cleanRfield_R.jpg">
</p>

<br />

[Menu](#menu)

<div id="P1" />

---------------------------------------------

#### 1. First steps

> **Calling necessary packages:**

```r
library(terra)
library(cleanRfield)
```

> Start this tutorial by downloading the example EX1 [here](https://drive.google.com/file/d/1FTdbrp-_SE81vUoQv4wBsqVGqkUUUaPR/view?usp=sharing) and the field boundary [here](https://drive.google.com/file/d/1pP41HiG2RxF7HOu_5fdj6Pg9DoTaLPcy/view?usp=sharing). This tutorial will use the function *`vect()`* from package **terra** to read and upload the data to RStudio (see provided code). 

> EX1 is a yield map from a soybean field, stored as a point shapefile. Yield monitor observations were originally collected in the north-central US using a combine yield monitor, and observations were geographically shifted to protect the landowner’s privacy. This data set include three attributes:
>   * Speed (miles per hour): speed of the combine at the time the observation was recorded
>   * Dry_Yield (bushels per acre): yield at that observation’s location as recorded by the yield monitor, adjusted to a 13% moisture basis
>   * Adj_Moist (percent): indicates what moisture level the original wet yield measurements were adjusted to when calculating dry yield

> The field boundary is a shapefile layer with three (3) polygons that delineate the boundaries of the sample field EX1. 

```r
### Opening Sample Field 1 ###

par(mfrow=c(1,2))

EX1<-vect("EX1.shp")
plot(EX1, main="Data Point")

EX1.Shape<-vect("EX1_boundary.shp")
plot(EX1.Shape, main="Field Boundary")

par(mfrow=c(1,1))
```
<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter1.jpg" width="70%" height="70%">
</p>

[Menu](#menu)

<div id="P2" />

---------------------------------------------
#### 2. Cropping or selecting targeted field 

> Users can subset the data by drawing boundaries around a field or subset of fields. Function **`cropField`**. Depending on your computer and the size of your data set, this step may take a few seconds. 

```r
# "Use cursor to select 4 points around polygon (1) in the plots window."
EX1.C<-cropField(field = EX1, nPolygon = 1, nPoint = 4)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter2.jpg" width="70%" height="70%">
</p>

```r
plot(EX1.C$shape,main="Drawing Shape")
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter3.jpg" width="70%" height="70%">
</p>

```r
# Using the shape drawn above to crop data:
EX1.C<-cropField(field = EX1, shape = EX1.C$shape) 
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter4.jpg" width="70%" height="70%">
</p>

```r
# All data will be selected using the full boundary as shape:
EX1.C1<-cropField(field = EX1, shape = EX1.Shape) 
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter5.jpg" width="70%" height="70%">
</p>

> The newest version of RStudio (2021.09.2) has updated the plot viewing pane. If you are using the newest RStudio, you may need run an additional line of code to open the point-and-click cropping functionality in a pop-out window instea of the integrated plot viewing pane. 

```r
#Open an extra plot window 
x11() 
# "Use cursor to select 4 points around polygon (1) in the plots window."
EX1.C<-cropField(field = EX1, nPolygon = 1, nPoint = 4)
```

[Menu](#menu)

<div id="P3" />

---------------------------------------------

#### 3. Sampling point data 

> Users can sample random points in the data. Function **`sampleField`**. 

```r
# Sampling 5%:
EX1.S<-sampleField(field = EX1, size = 0.05) 
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter6.jpg" width="70%" height="70%">
</p>

```r
# Sampling 10% under a small shape:
EX1.S<-sampleField(field = EX1,shape = EX1.C$shape, size = 0.1) 
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter7.jpg" width="70%" height="70%">
</p>

```r
# Sampling 10% under a full shape:
EX1.S<-sampleField(field = EX1,shape = EX1.Shape, size = 0.1) 
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter8.jpg" width="70%" height="70%">
</p>

[Menu](#menu)

<div id="P4" />

---------------------------------------------

#### 4. Making rasters 

> Function **`rasterField`**.Data points can be used to create raster files. Use either the provided code for unprojected data or projected data-- you will not need to run both sets of code. Any positive number can be chosen as the resolution, but choosing too high of a resolution will result in a raster file that oversimplifies the shape of the field, and choosing too low of a resolution can cause the runtime to be to long and/or cause the parts of the field between combine passes to be excluded from the final field shape. 

```r
# Check projection to observe 'LENGTHUNIT': 
crs(EX1)

# Unprojected Data (non or NA): use resolution around 0.00008 to create a raster for "Dry_Yield":
EX1.R<-rasterField(field = EX1,
                   trait = c("Dry_Yield"),
                   res = 0.00008)
                   
# Projected Data (e.g., +units=m or +units=us-ft): use resolution around 5 to 20 to create a raster for "Dry_Yield":
EX1.R<-rasterField(field = EX1,
                   trait = c("Dry_Yield"),
                   res = 20)                   
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter9.jpg" width="70%" height="70%">
</p>

```r
# Making raster only for the small shape:
EX1.R<-rasterField(field = EX1,
                    shape = EX1.C$shape,
                    trait = c("Dry_Yield"),
                    res = 0.00008) # Attention: for projected data use res=20 (e.g., +units=m or +units=us-ft).
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter10.jpg" width="70%" height="70%">
</p>

```r
# Multilayer raster for two or more traits:
EX1.R<-rasterField(field = EX1,
                   trait = c("Dry_Yield","Speed"),
                   res = 0.00008) # Attention: for projected data use res=20 (e.g., +units=m or +units=us-ft).
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter11.jpg" width="70%" height="70%">
</p>

```r
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
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter11col.jpeg">
</p>

[Menu](#menu)

<div id="P5" />

---------------------------------------------

#### 5. Building shape boundaries

> Users can manually draw field boundaries or use the raster layer to draw field boundaries automatically. Function **`boundaryField`**. 

* **Automatic - a raster layer is necessary for drawing the boundary automatically, which is the fastest method (use function **`rasterField`** before). Increasing the tolerance parameter simplifies the geometry of complex boundaries.**

```r
EX1.P<-boundaryField(field = EX1.R$Dry_Yield, tolerance = 0.0004) # Yield data did not capture borders of field  
EX1.P<-boundaryField(field = EX1.R$Speed) # Speed data has defined field borders, we use default tolerance
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter12.jpg" width="70%" height="70%">
</p>

* **Manually - use your cursor to make points around the field boundary and press ESC when it is done (use the parameter `draw = TRUE`).**

```r
EX1.P<-boundaryField(field = EX1, draw = TRUE)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter13.jpg" width="70%" height="70%">
</p>

* **Drawing 3 different fields (Manually):**

```r
# Upper field:
EX1.P1<-boundaryField(field = EX1, draw = T) # Manually
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter13a.jpg" width="70%" height="70%">
</p>

```r
# Middle field:
EX1.P2<-boundaryField(field = EX1, draw = T)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter13b.jpg" width="70%" height="70%">
</p>

```r
# Lower field:
EX1.P3<-boundaryField(field = EX1, draw = T)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter13c.jpg" width="70%" height="70%">
</p>

* **Combining fields on the same shapefile:**

```r
# Combining field on the same shapefile:
EX1.P<-rbind(EX1.P1,EX1.P2,EX1.P3)
plot(EX1.P)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter13d.jpg" width="70%" height="70%">
</p>

[Menu](#menu)

<div id="P6" />

---------------------------------------------

#### 6. Buffering the field boundaries

> Users can make a buffer around the field boundarys using a new shapefile (**Value must be negative**). Function **`bufferField`**. 
> Like in section 4, use either the provided code for unprojected data or projected data-- you will not need to run both sets of code. 

* Only shapefile:

```r
# Check projection to observe 'LENGTHUNIT': 
crs(EX1)

# Unprojected Data (e.g., non or NA): buffer of -0.0001:
EX1.B<-bufferField(shape = EX1.Shape,value = -0.0001)
                   
# Projected Data (e.g., +units=m or +units=us-ft): buffer of -5:
EX1.B<-bufferField(shape = EX1.Shape, value = -5)

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter14.jpg" width="70%" height="70%">
</p>

* Making buffering and automatic filtering at the same time (Shapefile + Data).

```r
# Buffer of -0.0002 (Unprojected Data) and -5 (Projected Data):
EX1.B<-bufferField(shape = EX1.Shape,
                   field = EX1,
                   value = -0.0002) # Attention: for projected data use 'value=-5' (e.g., +units=m or +units=us-ft).
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter15.jpg" width="70%" height="70%">
</p>

[Menu](#menu)

<div id="P7" />

---------------------------------------------

#### 7. Filtering using data values

> Users can filter spatial point data using values criteria. Function **`filterField`**. 

* Observing traits histograms:

```r
par(mfrow=c(1,2))
hist(EX1$Dry_Yield)
hist(EX1$Speed)
par(mfrow=c(1,1))
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter16.jpg" width="70%" height="70%">
</p>

```r
# Filtering data for Dry_Yield>60:

EX1.F<-filterField(field = EX1,
                  trait = "Dry_Yield",
                  value = 60,
                  cropAbove = T)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter17.jpg" width="70%" height="70%">
</p>

```r
# Filtering data for Dry_Yield>50 and Dry_Yield<70:

EX1.F<-filterField(field = EX1,
                  trait = c("Dry_Yield","Dry_Yield"),
                  value = c(50,70),
                  cropAbove = c(T,F))
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter18.jpg" width="70%" height="70%">
</p>

```r
# Filtering data for Dry_Yield>50 and Dry_Yield<70 (only for the data on the small shapefile):

EX1.F<-filterField(field = EX1,
                  shape = EX1.C$shape,
                  trait = c("Dry_Yield","Dry_Yield"),
                  value = c(50,70),
                  cropAbove = c(T,F))
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter19.jpg" width="70%" height="70%">
</p>

```r
# Filtering data for Dry_Yield>70 and Speed<5 (using the buffer shapefile):

EX1.F<-filterField(field = EX1,
                   shape = EX1.B$newShape,
                   trait = c("Dry_Yield","Speed"),
                   value = c(70,5),
                   cropAbove = c(T,F))
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter20.jpg" width="70%" height="70%">
</p>

[Menu](#menu)

<div id="P8" />

---------------------------------------------

#### 8. Filtering using standard deviation values  

> Filtering data can also be performed using standard deviation values for different traits. Function **`sdField`**. 

```r
# Filtering data for Dry_Yield sd<0.2:

EX1.SD<-sdField(field = EX1,
                trait = c("Dry_Yield"),
                value = 0.2)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter21.jpg" width="70%" height="70%">
</p>

```r
# Filtering data for Dry_Yield sd<0.5 and Dry_Yield sd<0.2:

EX1.SD<-sdField(field = EX1,
                trait = c("Dry_Yield","Dry_Yield"),
                value = c(0.5,0.2))
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter22.jpg" width="70%" height="70%">
</p>

```r
# Filtering data for Dry_Yield sd<0.5 and Speed sd<0.2 (only for the data on the small shapefile):

EX1.SD<-sdField(field = EX1,
                shape = EX1.C$shape,
                trait = c("Dry_Yield","Speed"),
                value = c(0.5,0.2))
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter23.jpg" width="70%" height="70%">
</p>

```r
# Filtering data for Dry_Yield sd<0.5 and Speed sd<0.2 (using the buffer shapefile):

EX1.SD<-sdField(field = EX1,
                shape = EX1.B$newShape,
                trait = c("Dry_Yield","Speed"),
                value = c(0.5,0.2))
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter24.jpg" width="70%" height="70%">
</p>

[Menu](#menu)

<div id="P9" />

---------------------------------------------

#### 9. Evaluating multiple field on parallel

> Download and unzip the projected data example below here [Parallel_Example.zip](https://drive.google.com/file/d/1-SywugJWDkbIrgalyUpe6wyRh0zRBGBN/view?usp=sharing).

```r
################
### Parallel ###
################

# General packages 
library(cleanRfield)
library(terra)

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
Filtered_Field <-lapply(unlist(Filtered_Field), unwrap)
Flltered_Field

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter25.jpg">
</p>

```r
# New filtered - EX2_center
plot(Filtered_Field$EX2_center.NewBoundary, main="EX2_center") 
plot(Filtered_Field$EX2_center.NewField, add=T, col="gold4",pch=20,cex=0.5) 

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter26.jpg" width="70%" height="70%">
</p>

```r
# New filtered - EX2_north
plot(Filtered_Field$EX2_north.NewBoundary, main="EX2_north") 
plot(Filtered_Field$EX2_north.NewField, add=T, col="gold4",pch=20,cex=2) 

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter27.jpg" width="70%" height="70%">
</p>

```r
# New filtered - EX2_south
plot(Filtered_Field$EX2_south.NewBoundary, main="EX2_south") 
plot(Filtered_Field$EX2_south.NewField, add=T, col="gold4",pch=20,cex=1) 

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter28.jpg" width="70%" height="70%">
</p>

```r
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

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter29.jpg" width="70%" height="70%">
</p>

[Menu](#menu)

<div id="P10" />

---------------------------------------------

#### 10. Making Maps

* This example code uses the function `spplot()` from the **sp** package to visualze "SpatialPointsDataFrames" in the plot viewing pane in R studio. The demonstrated code is useful for visualizing data before or after filtering using **cleanRfield**.

```r
# Make a very basic plot where brighter colors denote higher yield
terra::plot(EX1, "Dry_Yield")

#Adjusting cuts changes the number of categories in the legend
terra::plot(EX1, "Dry_Yield", breaks=6)  
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter30.jpg" width="50%" height="50%">
</p>

* If you prefer making visualizations using the package **ggplot2** , we recommend converting the data from "SpatialPointsDataFrames" to "sf" objects. 

```r 
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

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/figure31.jpeg" width="80%" height="80%">
</p>


[Menu](#menu)

<div id="P11" />

---------------------------------------------

#### 11. Saving files

* This example code uses the function `writeVector()` from the **terra** package to save "SpatVecor".

```r
library(terra)

# New filtered data (SpatVector):
writeVector(EX1.B$newField, "EX1.newField.shp", filetype="ESRI Shapefile") 
EX1.newField <- vect("EX1.newField.shp") # Reading the saved data points. 
```
[Menu](#menu)

<div id="P12" />

---------------------------------------------

#### 12. Working with .csv and .txt files

> If your data is stored as .csv or other file types, you can still utilizer cleanRfield by reading the data into a data frame in R before converting the data frame to a Spatial Points Data frame. This example uses a .csv file as the data source, but any data frame object in R that has coordinates can be converted to a spatial points data frame using this method regardless of data source file type. This data is in latitude and longitude (unprojected data). You will need to use a different CRS in the proj4string section if your data is projected. See the example code below and learn more about SpatialPoints in [the documentation for the package sp](https://cran.r-project.org/web/packages/sp/sp.pdf). 

Download the example: [EX3.csv](https://drive.google.com/file/d/1lIpsKyU-Xzcd0Hg-j7eo4J14NF4iy0wS/view?usp=sharing)

```r
library(terra)

# reading in the .csv file
DF<-read.csv("EX3.csv")
colnames(DF) #checking that the latitude is the first column and longitude is the second column

# creating the coordinates object using the latitude and longigude columns
xy <- DF[,c(1,2)]

# creating a new spatial points data frame from the data in DF
SpatialDF <- vect(DF, geom=c('Long','Lat'), crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
crs(SpatialDF)
```

[Menu](#menu)

<div id="P13" />

---------------------------------------------
#### 13. Interpolating yield maps

> Users may want to interpolate their yield observations to create a raster data set for visualization or further data analysis. Below, we have provided some example code for interpolating yield maps using either inverse distance weighting (IDW) or ordinary kriging. In general, we recommend IDW due to its faster processing time for large data sets. 

> In this example code, we use the same example data (EX1) as in tutorial section 1. You may also need to install the package **tmap** before proceeding with the provided code. 

> The next code section provides an example for running IDW in R. Users will load the required pacakges, load and filter yield data, transform filtered data and the field boundary file, prepare an empty grid, run the IDW interpolation, and finally make a map to visualize the interpolation. Transformation is a step included in this workflow since the EX1 shapefile is not in a projected CRS, and transforming into a projected CRS helps align the yield map observations to the empty grid. Preparing the empty grid is necessary to determine the extent and resolution of the interpolation.

```r
#### packages to run basic filtering with cleanRfield ####
library(terra)
library(cleanRfield)

#### additional packages needed for interpolation & mapping ####
library(gstat) # used to make the idw model
library(sf) # used to convert spatial objects
library(sp) # used to prepare the raster grid with spsample function
library(tmap) # used for visualization

#### preparing the yield data ####
EX1 <- vect("EX1.shp") # EX1.shp download link is in tutorial section 1 
EX1.Shape <- vect("EX1_boundary.shp") #EX1_boundary.shp download link is in tutorial section 1  

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
G <- as.data.frame(spsample(EX1_merc, "regular", n=50000)) #n = total number of grid cells
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

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter_N_1.jpeg" width="70%" height="70%">
</p>

> The following codes sections provides an example for interpolating via ordinary kriging in R. This workflow begins very similarly to the IDW interpolation workflow until we begin creating variogram models

```r
#### packages to run basic filtering with cleanRfield ####
library(terra)
library(cleanRfield)

#### additional packages needed for interpolation & mapping ####
library(gstat) # used to make the idw model
library(sf) # used to convert spatial objects
library(sp) # used to prepare the raster grid with spsample function
library(tmap) # used for visualization

#### preparing the yield data ####
EX1 <- vect("EX1.shp") # EX1.shp download link is in tutorial section 1 
EX1.Shape <- vect("EX1_boundary.shp") #EX1_boundary.shp download link is in tutorial section 1  

# filtering data to remove biologically unlikely soybean yield observations and NA values
EX1.F <- filterField(field = EX1,
                     trait = c("Dry_Yield","Dry_Yield"),
                     value = c(10,100),
                     cropAbove = c(T,F)) 

# transforming the filtered data so that it is a projected CRS
EX1_merc <- spTransform(as_Spatial(st_as_sf(EX1.F)), CRS=CRS("+proj=merc +ellps=GRS80")) 
EX1_merc # looking at summary output to check projection 

# transforming the boundary too-- this will be used later for visualization
EX1.Shape_merc <- spTransform(as_Spatial(st_as_sf(EX1.Shape)), CRS=CRS("+proj=merc +ellps=GRS80")) 
EX1.Shape_merc #looking at summary output to check projection 

#### make a variogram to assess spatial relationships between yield observations ####
v_overall <- variogram(Dry_Yield~1, data = EX1_merc) 
plot(v_overall) # visually estimate sill, model shape, range, and nugget
vmodel_overall <- vgm(psill=150, model="Sph", nugget=100, range=400) # estimate variogram model
fittedmodel_overall <- fit.variogram(v_overall, model=vmodel_overall) # fit variogram model   
fittedmodel_overall #print the fitted model to see how it compares to your initial estimate
plot(v_overall, model=fittedmodel_overall) 

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter_N_2.jpeg" width="60%" height="60%">
</p>

> The example variogram above had a range of ~509m, which indicates that yield observations that are <509m apart are spatially correlated. If you want to learn more about variograms, try [this blog post from GIS Geography](https://gisgeography.com/semi-variogram-nugget-range-sill/). Next, we will check that the data is not anisotrophic by developing 4 separate directional variograms. 

```r 
# let's see if the spatial autocorrelation is the same in all directions-- is the data anisotrophic?
gs_object <- gstat(formula=Dry_Yield~ 1, data=EX1_merc)
v_directional <- variogram(gs_object, alpha=c(0,45,90,135))
vmodel_directional <- vgm(model='Sph' , anis=c(0, 0.5))
fittedmodel_directional <- fit.variogram(v_directional, model=vmodel_directional)
plot(v_directional, model=fittedmodel_directional, as.table=TRUE)

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter_N_3.jpeg" width="70%" height="70%">
</p>

> There is not a commonly applied statistical test for anisotrophy, so this decision is a judgement call that each person will make a little differently. For distances <250m, these models are  pretty similar. the data is not perfectly stationary, but in our judgement, it is not so anisotrophic that kriging would be inappropriate. If you perform directional variograms and there are very substantial differences between the models, we do not recommend kriging for interpolation. Instead, try another interpolation method that doesn't assume stationarity

> Kriging takes a long time to compute, so in this example we will randomly sample 20% the yield observations before kriging to save time. Depending on your computer and your use for the kriged map, you may want to sample even fewer points, or krige using all observations. In this example we also used a lower resolution empty grid than in the IDW example to save computational time. 

```r
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
                   data=EX1_merc_10pct, model=fittedmodel_overall)

#### run the kriging procedure using the gstat object and empty grid ####
kriged_surface <- predict(gs_object, model=fittedmodel_overall, newdata=G) 

summary(kriged_surface)

```

> There's a reason most point-and-click softwares highly recommend not kriging yield maps. Even with just 20% of the observations, that took almost 5 min to run on my laptop. Running 50% of the observations takes me over 25 min. Fortunately, once the kriged surface is made, visualization is quick. 

```r
#### visualizing kriged map ####
kriged_raster <- raster::raster(kriged_surface)
kriged_masked <- raster::mask(kriged_raster, EX1.Shape_merc)

tm_shape(kriged_masked) + 
  tm_raster(n=10,palette = "YlGn", 
            title="Dry Yield") + 
  tm_legend(legend.outside=TRUE)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter_N_4.jpeg" width="70%" height="70%">
</p>

> Regardless of interpolation method chosen, we highly recommend assessing the fit of your model using cross-validation and other methods. We do not provide code for assessing goodness of fit in this tutorial, but you can provide more information on this process from a variety of GIS tutorials. We find [Manuel Gimond's tutorial](https://mgimond.github.io/Spatial/interpolation-in-r.html) to be particularly helpful.


[Menu](#menu)

<div id="PC" />

---------------------------------------------

### Forum for questions 

> This discussion group provides an online source of information about the cleanRfield package. Report a bug and ask a question at: 
* [https://groups.google.com/g/cleanRfield](https://groups.google.com/g/cleanRfield) 

<br />

### Licenses

> The R/cleanRfield package as a whole is distributed under [GPL-2 (GNU General Public License version 2)](https://www.gnu.org/licenses/gpl-2.0.en.html).

<br />

### Citation

> coming soon...

<br />

### Author

> * [Filipe Inacio Matias](https://github.com/filipematias23)
> * [Emma Matcham](https://mobile.twitter.com/egmatcham)
> * [Hunter Smith](https://www.linkedin.com/in/hunterdanielsmith/)

<br />

### Acknowledgments

> * [Shawn Conley](https://coolbean.info/)
> * [North Dakota State University](https://www.ndsu.edu/agriculture/academics/academic-units/plant-sciences)
> * [University of Wisconsin - Madison](https://agronomy.wisc.edu/)

<br />

[Menu](#menu)
