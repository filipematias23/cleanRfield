% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fct_sdField.R
\name{sdField}
\alias{sdField}
\title{Selecting/filtering experimental data based on standard deviation.}
\usage{
sdField(field, shape = NULL, trait = NULL, value = 1, cex = 1)
}
\arguments{
\item{field}{object of class SpatialPointsDataFrame.}

\item{shape}{crop/select the object area using this shape as reference. If shape=NULL, 
all field data will be used for filtering.}

\item{trait}{vector with the trait to be used as filter criteria.}

\item{value}{sd referent value of cropping in the data (must be numeric).}

\item{cex}{point expansion/size. Please check \code{help("points")}.}
}
\value{
A image format stack.
}
\description{
This function allows to filter regions on the original data based on standard deviation.
}
\details{
sdField
}
