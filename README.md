# Title: 
sastats 

# Author: 
Dan Kary, Yixuan Chen 

# Description: 
The package provides several useful statistics calculations including identifying
outliers, calculating survey sampling error and survey rake weighting.

# Exported Functions:
error_me, error_se_mean, error_se_prop,
outlier_mean_compare, outlier_pct, outlier_plot, outlier_tukey,
outlier_tukey_top, rake_weight 

# Example: 
library(dplyr) 
data(svy)
outlier_plot(svy$act, days, act) 
outlier_plot(svy$act, days, act, apply_log = TRUE)

# Github and website information

Github link: <https://github.com/southwick-associates/sastats>
deployed website: <https://jhu-statprogramming-fall-2022.github.io/biostat840-project3-pkgdown-yixuan-chen-elisa>

pkgdown website:
- modify the entire appearance of the website by setting bootswatch to lux
- change fonts used for majority of text, headings and code
- change the color for syntax highlighting in code box
- customize the navigation bar
- customize the side bar


# sastats

A Southwick package for useful statistics calculations (particularly
with regard to surveys)

## Installation

From the R console:

``` r
install.packages("remotes")
remotes::install_github("southwick-associates/sastats")
```

## Usage

See the vignettes:

-   [Identifying Outliers](github-vignettes/outliers.md)
-   [Survey Sampling Errors](github-vignettes/errors.md)
-   [Survey Rake Weighting](github-vignettes/weight.md)

Note that this package doesn't implement [error
propagation](https://en.wikipedia.org/wiki/Propagation_of_uncertainty).
The [errors](https://github.com/r-quantities/errors) package looks
promising in this regard, although I haven't tried it yet.

## Development

See the [R packages book](http://r-pkgs.had.co.nz/) for a guide to
package development. The software environment was specified using
[package renv](https://rstudio.github.io/renv/index.html). Use
`renv::restore()` to build the project library.
