% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fars_functions.R
\name{fars_read_years}
\alias{fars_read_years}
\title{Read data by years}
\usage{
fars_read_years(years)
}
\arguments{
\item{years}{a list of integer as years to load}
}
\value{
a /code{list} of /code{data.frame} each containing one year data.
}
\description{
load fars data of a list of year
The fucntion warns if invalid year are requested and return a NULL for that entry of the list.
}
\examples{
 fars_read_years(c(2015,2014))
}
