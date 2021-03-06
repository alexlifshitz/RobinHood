% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RobinHood.R
\name{RobinHood}
\alias{RobinHood}
\title{RobinHood Account Authentication}
\usage{
RobinHood(username, password)
}
\arguments{
\item{username}{user name or email}

\item{password}{password}
}
\description{
This function returns an object of S3 class RobinHood and establishes a connection to a RobinHood account.
It is a required input for every other function in the package.
}
\examples{
\dontrun{
RH <- RobinHood("username", "password")
}
}
