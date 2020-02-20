
<!-- .md is generated from .Rmd. Please edit that file -->

# Overview

Package sastats includes a few convenience functions for estimating
survey sampling errors. These are simple computations, and the functions
are just thin wrappers for a bit of code. Relevant measures:

  - standard error of the mean
  - standard error of a proportion
  - margin of error

Note that these calculations don’t include a “design effect” factor
(relevant for weights here) and they probably should. The [package
survey](https://cran.r-project.org/web/packages/survey/index.html) has
been around for a while and it can be used to estimate design effects.

#### Sample Data

``` r
library(dplyr)
library(sastats)
data(svy)

activity <- left_join(svy$act, select(svy$person, Vrid, weight), by = "Vrid")
glimpse(activity)
#> Observations: 11,268
#> Variables: 5
#> $ Vrid   <chr> "98", "99", "100", "101", "102", "103", "105", "106", "107",...
#> $ act    <chr> "trail", "trail", "trail", "trail", "trail", "trail", "trail...
#> $ part   <chr> "Unchecked", "Unchecked", "Unchecked", "Unchecked", "Uncheck...
#> $ days   <dbl> NA, NA, NA, NA, NA, NA, NA, NA, 15, 10, NA, 2, NA, NA, 10, N...
#> $ weight <dbl> 0.9596845, 1.0899973, 1.0000000, 0.8747500, 0.9641894, 0.924...
```

## SE Mean

Looking at days of participation:

``` r
days <- activity %>%
    group_by(act) %>% 
    summarise(
        avgdays = weighted.mean(days, weight, na.rm = TRUE),
        se = error_se_mean(days, na.rm = TRUE)
)
days
#> # A tibble: 9 x 3
#>   act      avgdays    se
#>   <chr>      <dbl> <dbl>
#> 1 bike       30.4  2.97 
#> 2 camp       10.9  1.28 
#> 3 fish       10.6  1.49 
#> 4 hunt        8.93 1.41 
#> 5 picnic     18.6  1.35 
#> 6 snow        9.60 0.856
#> 7 trail      26.9  2.58 
#> 8 water      11.8  1.24 
#> 9 wildlife   26.9  2.96
```

## SE Proportion

Looking at participation rate:

``` r
rate <- activity %>%
    group_by(act, part) %>%
    summarise(n = n(), wtn = sum(weight)) %>%
    mutate(
        n = sum(n), 
        rate = wtn / sum(wtn),
        se = error_se_prop(rate, n)
    ) %>%
    filter(part == "Checked")
rate
#> # A tibble: 9 x 6
#> # Groups:   act [9]
#>   act      part        n   wtn  rate      se
#>   <chr>    <chr>   <int> <dbl> <dbl>   <dbl>
#> 1 bike     Checked  1252  381. 0.304 0.0130 
#> 2 camp     Checked  1252  469. 0.375 0.0137 
#> 3 fish     Checked  1252  323. 0.258 0.0124 
#> 4 hunt     Checked  1252  173. 0.138 0.00976
#> 5 picnic   Checked  1252  870. 0.695 0.0130 
#> 6 snow     Checked  1252  309. 0.247 0.0122 
#> 7 trail    Checked  1252  452. 0.361 0.0136 
#> 8 water    Checked  1252  377. 0.301 0.0130 
#> 9 wildlife Checked  1252  484. 0.386 0.0138
```

## Margin of Error

These are useful for reporting confidence intervals.

``` r
mutate(rate, me = error_me(se))
#> # A tibble: 9 x 7
#> # Groups:   act [9]
#>   act      part        n   wtn  rate      se     me
#>   <chr>    <chr>   <int> <dbl> <dbl>   <dbl>  <dbl>
#> 1 bike     Checked  1252  381. 0.304 0.0130  0.0255
#> 2 camp     Checked  1252  469. 0.375 0.0137  0.0268
#> 3 fish     Checked  1252  323. 0.258 0.0124  0.0242
#> 4 hunt     Checked  1252  173. 0.138 0.00976 0.0191
#> 5 picnic   Checked  1252  870. 0.695 0.0130  0.0255
#> 6 snow     Checked  1252  309. 0.247 0.0122  0.0239
#> 7 trail    Checked  1252  452. 0.361 0.0136  0.0266
#> 8 water    Checked  1252  377. 0.301 0.0130  0.0254
#> 9 wildlife Checked  1252  484. 0.386 0.0138  0.0270

mutate(days, me = error_me(se))
#> # A tibble: 9 x 4
#>   act      avgdays    se    me
#>   <chr>      <dbl> <dbl> <dbl>
#> 1 bike       30.4  2.97   5.83
#> 2 camp       10.9  1.28   2.50
#> 3 fish       10.6  1.49   2.92
#> 4 hunt        8.93 1.41   2.76
#> 5 picnic     18.6  1.35   2.64
#> 6 snow        9.60 0.856  1.68
#> 7 trail      26.9  2.58   5.05
#> 8 water      11.8  1.24   2.44
#> 9 wildlife   26.9  2.96   5.81
```
