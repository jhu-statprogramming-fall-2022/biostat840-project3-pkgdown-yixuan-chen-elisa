
# sastats

A Southwick package for useful statistics calculations (particularly with regard to surveys)

## Installation

From the R console:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/sastats")
```

## Usage

See the vignettes:

- [Identifying Outliers](github-vignettes/outliers.md)
- [Survey Sampling Errors](github-vignettes/errors.md)
- [Survey Rake Weighting](github-vignettes/weight.md)

Note that this package doesn't implement [error propagation](https://en.wikipedia.org/wiki/Propagation_of_uncertainty). The [errors](https://github.com/r-quantities/errors) package looks promising in this regard, although I haven't tried it yet.

## Development

See the [R packages book](http://r-pkgs.had.co.nz/) for a guide to package development. The software environment was specified using [package renv](https://rstudio.github.io/renv/index.html). Use `renv::restore()` to build the project library.
