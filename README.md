
# sastats

A Southwick package for useful statistics calculations (particularly with regard to surveys)

## Installation

Install from github:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/sastats")
```

## Usage

Currently, there are just a few functions for calculating survey sample error:

```r
# You can view examples for each function
?error_se       # standard error of a proportion
?error_se_mean  # standard error of mean
?error_me       # margin of error (for confidence intervals)
```
