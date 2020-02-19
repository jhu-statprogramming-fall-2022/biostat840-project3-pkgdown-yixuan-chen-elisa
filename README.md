
# sastats

A Southwick package for useful statistics calculations (particularly with regard to surveys)

## Installation

From the R console:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/sastats")
```

## Usage

Will include vignettes:

- Outliers (e.g., `?outlier_tukey()`)
- Sampling Errors (e.g., `error_se_mean()`)
- (maybe) Survey Weighting

## TODO

- add outlier vignette (probably pretty much copy from B4W)
- short vignette on error estimation
- survey weighting function (and sample data), probably with short vignette

## Development

See the [R packages book](http://r-pkgs.had.co.nz/) for a guide to package development. The software environment was specified using [package renv](https://rstudio.github.io/renv/index.html). Use `renv::restore()` to build the project library.
