
<!-- .md is generated from .Rmd. Please edit that file -->

# Overview

Package sastats includes a few convenience functions for estimating
standard errors. This is typically in the context of survey sampling
error. These are very simple computations, and the functions are just
thin wrappers for a bit of code.

Using sample survey data:

``` r
library(dplyr)
library(sastats)
data(svy)
activity <- svy$act
glimpse(activity)
#> Observations: 11,268
#> Variables: 4
#> $ Vrid <chr> "98", "99", "100", "101", "102", "103", "105", "106", "107", "...
#> $ act  <chr> "trail", "trail", "trail", "trail", "trail", "trail", "trail",...
#> $ part <chr> "Unchecked", "Unchecked", "Unchecked", "Unchecked", "Unchecked...
#> $ days <dbl> NA, NA, NA, NA, NA, NA, NA, NA, 15, 10, NA, 2, NA, NA, 10, NA,...
```

## Mean

``` r
activity %>%
    group_by(act) %>% 
    summarise(
        avgdays = mean(days, na.rm = TRUE),
        se = error_se_mean(days, na.rm = TRUE)
)
#> # A tibble: 9 x 3
#>   act      avgdays    se
#>   <chr>      <dbl> <dbl>
#> 1 bike       31.6  2.97 
#> 2 camp       11.2  1.28 
#> 3 fish       11.6  1.49 
#> 4 hunt        9.37 1.41 
#> 5 picnic     17.5  1.35 
#> 6 snow        9.99 0.856
#> 7 trail      28.4  2.58 
#> 8 water      12.4  1.24 
#> 9 wildlife   30.5  2.96
```

#### Computation

``` r
error_se_mean
#> function (x, na.rm = FALSE) 
#> {
#>     if (na.rm) 
#>         x <- na.omit(x)
#>     sqrt(var(x)/length(x))
#> }
#> <bytecode: 0x0000000016269118>
#> <environment: namespace:sastats>
```
