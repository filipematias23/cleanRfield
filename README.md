
## [cleanRfield](https://github.com/filipematias23/cleanRfield): A tool for cleaning and filtering data spatial points from crop yield maps in [R](https://www.r-project.org).

> This package is a compilation of functions to clean and filter observations from yield monitors or other agricultural spatial point data. Yield monitors are prone to error, and filtering the observations or removing observations from near field boundaries can improve estimates of whole-field yield, combine speed, grain moisture, or other parameters. In this package, users can easily select filters thresholding for one or more traits and prepare a smaller dataset to make decisions.

> This tutorial assumes that readers have a basic understanding of spatial data, including projections and coordinate reference systems. If you need a refresher on this topic, we recommend reading [this quick blog post for deciding between projected and unprojected data](https://spatiallychallenged.com/2018/11/01/selecting-a-projection-for-spatial-analysis/) and [this post for understanding the basics of coordinate reference systems](https://spatiallychallenged.com/2018/11/05/epsg-numbers-and-coordinate-reference-systems/). 

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filteRfield.jpg" width="70%" height="70%">
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
   * [10. Saving files](#P10)
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

[Menu](#menu)

<div id="P1" />

---------------------------------------------

#### 1. First steps

> **Calling necessary packages:**

```r
library(raster)
library(rgdal)
library(cleanRfield)
```

> Start this tutorial by downloading the example EX1 [here](https://drive.google.com/file/d/1FTdbrp-_SE81vUoQv4wBsqVGqkUUUaPR/view?usp=sharing) and the field boundary [here](https://drive.google.com/file/d/1pP41HiG2RxF7HOu_5fdj6Pg9DoTaLPcy/view?usp=sharing). This tutorial will use the function *`readOGR()`* from package **rgdal** to read and upload the data to RStudio (see provided code). 

> EX1 is a yield map from a soybean field, stored as a point shapefile. Yield monitor observations were originally collected in the north-central US using a combine yield monitor, and observations were geographically shifted to protect the landowner’s privacy. This data set include three attributes:
>   * Speed (miles per hour): speed of the combine at the time the observation was recorded
>   * Dry_Yield (bushels per acre): yield at that observation’s location as recorded by the yield monitor, adjusted to a 13% moisture basis
>   * Adj_Moist (percent): indicates what moisture level the original wet yield measurements were adjusted to when calculating dry yield

> The field boundary is a shapefile layer with three (3) polygons that delineate the boundaries of the sample field EX1. 

```r
### Sample 1 ###

par(mfrow=c(1,2))

EX1<-readOGR("EX1.shp")
plot(EX1, main="Data Point")

EX1.Shape<-readOGR("EX1_boundary.shp")
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

> Users can reduce the data size around the field boundaries. Function **`cropField`**. 

```r
# "Use cursor to select 4 points around of polygon (1) in the plots window."
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

[Menu](#menu)

<div id="P3" />

---------------------------------------------

#### 3. Sampling point data 

> Sampling random points in the data. Function **`sampleField`**. 

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

> Using data points to create raster files. Function **`rasterField`**. 

```r
# Check projection to observe '+units=':
projection(EX1)

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

[Menu](#menu)

<div id="P5" />

---------------------------------------------

#### 5. Building shape boundaries

> Making field boundaries automatically or manually. Function **`boundaryField`**. 

* **Automatic - a raster layer is necessary for drawing the boundary on an automatic and fast way (use function **`rasterField`** before).**

```r
EX1.P<-boundaryField(field = EX1.R$Dry_Yield)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter12.jpg" width="70%" height="70%">
</p>

* **Manually - make points around the field boundary and press ESC when it is done (use the paramter `draw = TRUE`).**

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
# Giving names to each field:
EX1.P1@data<-data.frame(Field=c(1))
EX1.P2@data<-data.frame(Field=c(2))
EX1.P3@data<-data.frame(Field=c(3))

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

> Making a buffering around the field using a new shapefile (**Value must be negative**). Function **`bufferField`**. 

* Only shapefile:

```r
# Check projection to observe '+units=':
projection(EX1.Shape)

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

> Filtering data using values criteria. Function **`filterField`**. 

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

> Filtering data using standard deviation values for different traits. Function **`sdField`**. 

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
library(raster)
library(rgdal)

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
                         .packages = c("raster","cleanRfield","rgdal")) %dopar% {
                               
                               # Uploading data and boundary
                               F.ex<-readOGR(paste("./field/",field[i],".shp",sep=""))
                               B.ex<-readOGR(paste("./boundary/",boundary[i],".shp",sep=""))
                               
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
                               return(list(NewField=F.ex, NewBoundary=B.ex))
                             }

stopCluster(cl)
names(Filtered_Field)<-field

# Output
Filtered_Field

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter25.jpg">
</p>

```r
# New filtered - EX2_center
plot(Filtered_Field$EX2_center$NewBoundary, main="EX2_center")
plot(Filtered_Field$EX2_center$NewField, add=T, col="gold4",pch=20,cex=0.5)

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter26.jpg" width="70%" height="70%">
</p>

```r
# New filtered - EX2_north
plot(Filtered_Field$EX2_north$NewBoundary, main="EX2_north")
plot(Filtered_Field$EX2_north$NewField, add=T, col="gold4",pch=20,cex=2)

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter27.jpg" width="70%" height="70%">
</p>

```r
# New filtered - EX2_south
plot(Filtered_Field$EX2_south$NewBoundary, main="EX2_south")
plot(Filtered_Field$EX2_south$NewField, add=T, col="gold4",pch=20,cex=1)

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter28.jpg" width="70%" height="70%">
</p>

```r
# Combined new data:
NewField<-rbind(Filtered_Field$EX2_center$NewField,
                Filtered_Field$EX2_north$NewField,
                Filtered_Field$EX2_south$NewField)

# Giving names to each field:
Filtered_Field$EX2_center$NewBoundary$ID<-field[1]
Filtered_Field$EX2_north$NewBoundary$ID<-field[2]
Filtered_Field$EX2_south$NewBoundary$ID<-field[3]

# Combining field on the same shape file:
NewBoundary<-rbind(Filtered_Field$EX2_center$NewBoundary,
                Filtered_Field$EX2_north$NewBoundary,
                Filtered_Field$EX2_south$NewBoundary)

plot(NewBoundary, main="EX2_full")
plot(NewField, add=T, col="gold4",pch=20,cex=0.5)

```

<p align="center">
  <img src="https://raw.githubusercontent.com/filipematias23/images/master/readme/filter29.jpg" width="70%" height="70%">
</p>

[Menu](#menu)

<div id="P10" />

---------------------------------------------

#### 10. Saving files

* The same function `writeOGR()` from **rgdal** package can save "SpatialPointsDataFrames" and "SpatialPolygonsDataFrame" as a shapefile.

```r
library(rgdal)

# New filtered data (SpatialPointsDataFrames):
writeOGR(EX1.B$newField, ".", "EX1.newField", driver="ESRI Shapefile")
EX1.newField <- readOGR("EX1.newField.shp") # Reading the saved data points.

# New boundary or shape (SpatialPolygonsDataFrame):
writeOGR(EX1.B$newShape, ".", "EX1.newShape", driver="ESRI Shapefile")
EX1.newShape <- readOGR("EX1.newShape.shp") # Reading the saved shapefile.

```

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
> * [Emma Matcham]()

<br />

### Acknowledgments

> * [Shawn Conley](https://coolbean.info/)
> * [University of Wisconsin - Madison](https://agronomy.wisc.edu/)

<br />

[Menu](#menu)
