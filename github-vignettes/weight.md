
<!-- .md is generated from .Rmd. Please edit that file -->

# Overview

Rake weighting in R is fairly straightforward using [package
anesrake](). The key aspect is getting the two input datasets into the
right format:

  - The **target population dataset** needs to be a named list (one
    element per demographic variable) of target distributions. The
    `weights::wpct()` function helps with this.

  - The **survey dataset** needs to be a data frame with a unique ID
    variable (e.g., Vrid), and one variable for each demographic
    measure.

Importantly, demographic variables must be stored either as factors (or
numerics) and these much match between the two datasets. This is
probably confusing, but the examples below should help illustrate. There
is also an AS/HS implementation on Github:
[rakewt-ashs](https://github.com/southwick-associates/rakewt-ashs).

#### Sample Data

``` r
library(dplyr)
library(sastats)

data(svy, pop)
svy <- select(svy$person, -weight)

# survey to be weighted
glimpse(svy)
#> Observations: 1,252
#> Variables: 4
#> $ Vrid          <chr> "98", "99", "100", "101", "102", "103", "105", "106",...
#> $ age_weight    <fct> 35-54, 35-54, NA, 35-54, 35-54, 18-34, 18-34, 35-54, ...
#> $ income_weight <fct> 0-25K, 0-25K, NA, 25-35K, 50-75K, 25-35K, 50-75K, 35-...
#> $ race_weight   <fct> White, Not white or Hispanic, NA, White, Not white or...

# target population (outdoor recreationists) from a genpop survey
glimpse(pop)
#> Observations: 877
#> Variables: 4
#> $ age_weight    <fct> 18-34, 18-34, 18-34, 18-34, 18-34, 35-54, 35-54, 35-5...
#> $ income_weight <fct> 75-100K, 35-50K, 0-25K, 150K+, 0-25K, 25-35K, 75-100K...
#> $ race_weight   <fct> White, White, Hispanic, White, White, White, White, W...
#> $ stwt          <dbl> 0.8927761, 0.8927761, 1.1913576, 1.1056643, 0.8073446...
```

## Population Distributions

The easiest way to see the format needed for the target population is to
run `weights::wpct()` on a demographic variable. In this example, we are
defining the target population (outdoor recreationists) using another
general population survey dataset. The genpop distribution for age can
be readily pulled from the pop dataset, although we need to ensure we
use the `stwt` variable from that survey:

``` r
weights::wpct(pop$age_weight, pop$stwt)
#>     18-34     35-54       55+ 
#> 0.3514503 0.3486601 0.2998896
```

The `weights::wpct()` function returns a vector though, and we need a
list (and one which includes all the demographic variables of interest):

``` r
wtvars <- setdiff(names(pop), "stwt")
pop_target <- sapply(wtvars, function(x) weights::wpct(pop[[x]], pop$stwt))
pop_target
#> $age_weight
#>     18-34     35-54       55+ 
#> 0.3514503 0.3486601 0.2998896 
#> 
#> $income_weight
#>      0-25K     25-35K     35-50K     50-75K    75-100K   100-150K      150K+ 
#> 0.17353726 0.09405487 0.14064324 0.18922885 0.15252025 0.16103245 0.08898309 
#> 
#> $race_weight
#>                 White              Hispanic Not white or Hispanic 
#>            0.73559778            0.17719770            0.08720452
```

This also provides a convenient method to compare to the survey dataset
to be weighted:

``` r
sapply(wtvars, function(x) weights::wpct(svy[[x]]))
#> $age_weight
#>     18-34     35-54       55+ 
#> 0.2766497 0.2944162 0.4289340 
#> 
#> $income_weight
#>      0-25K     25-35K     35-50K     50-75K    75-100K   100-150K      150K+ 
#> 0.15071973 0.12785775 0.14309907 0.20491109 0.15071973 0.15410669 0.06858594 
#> 
#> $race_weight
#>                 White              Hispanic Not white or Hispanic 
#>            0.82387807            0.09652837            0.07959356
```
