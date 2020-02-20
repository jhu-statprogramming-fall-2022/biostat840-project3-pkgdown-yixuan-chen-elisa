
<!-- .md is generated from .Rmd. Please edit that file -->

# Overview

Outliers should be considered with continuous survey variables. There
are no hard and fast rules for outlier identification, but [Tukey’s
Test](https://en.wikipedia.org/wiki/Outlier#Tukey%27s_fences) provides
one method that is easy to apply in a standard way.

## Visualize

Visualizing the data is a first step for examining outliers. To
demonstrate, package sastats includes a survey dataset with annual
participation days for several outdoor recreation activities:

``` r
library(dplyr)
library(sastats)

data(svy)
activities <- svy$act

glimpse(activities)
#> Observations: 11,268
#> Variables: 4
#> $ Vrid <chr> "98", "99", "100", "101", "102", "103", "105", "106", "107", "...
#> $ act  <chr> "trail", "trail", "trail", "trail", "trail", "trail", "trail",...
#> $ part <chr> "Unchecked", "Unchecked", "Unchecked", "Unchecked", "Unchecked...
#> $ days <dbl> NA, NA, NA, NA, NA, NA, NA, NA, 15, 10, NA, 2, NA, NA, 10, NA,...
```

We can use `sastats::outlier_plot()` which is a wrapper for
`ggplot2::geom_boxplot()`. However, the distributions are highly skewed
and difficult to view. Additionally, the postion of the whiskers
suggests that we would be flagging many reasonable values as outliers
(e.g., those above 20 or so for fishing).

``` r
outlier_plot(activities, days, act, ignore_zero = TRUE)
```

![](outliers_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

An argument is included to allow us to log transform the y-axis. This
makes for more normal distributions, and likely provides a more
reasonable criteria for outlier identification.

``` r
outlier_plot(activities, days, act, apply_log = TRUE)
```

![](outliers_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

## Flag Outliers

We can use `outlier_tukey()` to flag those values observed to be
outliers:

``` r
activities <- activities %>%
    group_by(act) %>% 
    mutate(
        is_outlier = outlier_tukey(days, apply_log = TRUE), 
        days_cleaned = ifelse(is_outlier, NA, days) 
    ) %>% 
    ungroup()

outlier_plot(activities, days, act, apply_log = TRUE, show_outliers = TRUE)
```

![](outliers_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

We have a couple more summary functions to show the effects of outliers
removal:

``` r
outlier_pct(activities, act)
#> # A tibble: 9 x 4
#> # Groups:   act [9]
#>   act      is_outlier     n pct_outliers
#>   <chr>    <lgl>      <int>        <dbl>
#> 1 bike     TRUE           4        0.319
#> 2 camp     TRUE           8        0.639
#> 3 fish     TRUE           9        0.719
#> 4 hunt     TRUE           3        0.240
#> 5 picnic   TRUE          26        2.08 
#> 6 snow     TRUE           4        0.319
#> 7 trail    TRUE           7        0.559
#> 8 water    TRUE           9        0.719
#> 9 wildlife TRUE          24        1.92

outlier_mean_compare(activities, days, days_cleaned)
#> # A tibble: 1 x 2
#>    days days_cleaned
#>   <dbl>        <dbl>
#> 1  19.1         15.8
```

### Topcode
