
<!-- README.md is generated from README.Rmd. Please edit that file -->

# riskintrodata

The ‘riskintrodata’ package is designed to provide a set of functions
and datasets  
that support the management of data used to estimate the risk of
introducing an animal  
disease into a specific geographical region.

It includes tools for reading and validating both geographic and tabular
datasets  
commonly used in the context of animal disease risk estimation.

## Motivation

The primary motivation for creating ‘riskintrodata’ is to isolate and
centralize the datasets and data import functions required by the
‘riskintro’ application  
into a dedicated package. This separation simplifies testing, improves
clarity,  
and makes it easier to document the datasets used in the application in
a structured way.

Additionally, the ‘riskintrodata’ package is designed to simplify
package management.  
It helps reduce the complexity of handling the numerous packages
required by the  
‘riskintro’ application. By centralizing essential datasets and their
associated  
import functions, ‘riskintrodata’ minimizes package dependencies.

## Installation

You can install the development version of riskintrodata like so:

``` r
pak::pak("ardata-fr/riskintrodata")
```
