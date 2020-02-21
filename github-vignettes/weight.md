
<!-- .md is generated from .Rmd. Please edit that file -->

# Overview

Rake weighting in R is fairly straightforward using
`anesrake::anesrake()`, for which `sastats::rake_weight()` is a thin
wrapper. The key aspect of the process is getting the two input datasets
into the right format:

  - The **target population dataset** needs to be a named list (one
    element per demographic variable) of target distributions. The
    `weights::wpct()` function helps with this.

  - The **survey dataset** needs to be a data frame with a unique ID
    variable (e.g., Vrid), and one variable for each demographic
    measure.

Importantly, demographic variables must be stored either as factors or
numerics and the category coding much match between the two datasets.
You can also see production examples for
[B4W-19-10](https://github.com/southwick-associates/B4W-19-01/blob/master/code/svy/6-weight.R)
and AS/HS:
[rakewt-ashs](https://github.com/southwick-associates/rakewt-ashs).

### Example Data

For demonstration, package sastats includes survey and population
datasets which include several demographic variables:

``` r
library(dplyr)
library(sastats)

data(svy, pop)
svy <- select(svy$person, -weight)

# survey to be weighted
glimpse(svy)
#> Observations: 1,252
#> Variables: 5
#> $ Vrid          <chr> "98", "99", "100", "101", "102", "103", "105", "106",...
#> $ sex           <fct> Female, Female, NA, Male, Female, Male, Male, Female,...
#> $ age_weight    <fct> 35-54, 35-54, NA, 35-54, 35-54, 18-34, 18-34, 35-54, ...
#> $ income_weight <fct> 0-25K, 0-25K, NA, 25-35K, 50-75K, 25-35K, 50-75K, 35-...
#> $ race_weight   <fct> White, Not white or Hispanic, NA, White, Not white or...

# target population (outdoor recreationists) from a genpop survey
glimpse(pop)
#> Observations: 877
#> Variables: 5
#> $ sex           <fct> Female, Female, Female, Male, Female, Female, Female,...
#> $ age_weight    <fct> 18-34, 18-34, 18-34, 18-34, 18-34, 35-54, 35-54, 35-5...
#> $ income_weight <fct> 75-100K, 35-50K, 0-25K, 150K+, 0-25K, 25-35K, 75-100K...
#> $ race_weight   <fct> White, White, Hispanic, White, White, White, White, W...
#> $ stwt          <dbl> 0.8927761, 0.8927761, 1.1913576, 1.1056643, 0.8073446...
```

Importantly, the demographic variables have been encoded in the same way
between the 2 datasets (as factors in this case):

``` r
wtvars <- setdiff(names(svy), "Vrid")
sapply(wtvars, function(x) all(levels(svy[[x]]) == levels(pop[[x]])))
#>           sex    age_weight income_weight   race_weight 
#>          TRUE          TRUE          TRUE          TRUE
```

## Population Distributions

The easiest way to see the format needed for the target population is to
run `weights::wpct()` on a demographic variable:

``` r
weights::wpct(svy$age_weight)
#>     18-34     35-54       55+ 
#> 0.2766497 0.2944162 0.4289340
```

For our example, we are defining the target population (outdoor
recreationists) using another general population survey dataset. In this
case, we need to ensure we use the `stwt` variable from that survey
since it was itself weighted:

``` r
weights::wpct(pop$age_weight, pop$stwt)
#>     18-34     35-54       55+ 
#> 0.3514503 0.3486601 0.2998896
```

The `weights::wpct()` function returns a vector, but we need a list of
vectors (one element per demographic variables of interest). A
straightforward method involves looping over the demographic variables
with `sapply()`:

``` r
pop_target <- sapply(wtvars, function(x) weights::wpct(pop[[x]], pop[["stwt"]]))
pop_target
#> $sex
#>    Male  Female 
#> 0.51747 0.48253 
#> 
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

If we weren’t using a reference population dataset, we would need to get
the target distributions into a list in some other way. For example, by
hand:

``` r
partial_target <- list(
    "sex" = c("Male" = 0.517, "Female" = 0.483),
    "age_weight" = c("18-34" = 0.351, "35-54" = 0.349, "55+" = 0.300)
    # etc.
)
partial_target
#> $sex
#>   Male Female 
#>  0.517  0.483 
#> 
#> $age_weight
#> 18-34 35-54   55+ 
#> 0.351 0.349 0.300
```

Using `weights::wpct()` also of course provides a convenient method for
comparison with the survey dataset to be weighted:

``` r
sapply(wtvars, function(x) weights::wpct(svy[[x]]))
#> $sex
#>      Male    Female 
#> 0.4318374 0.5681626 
#> 
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

## Rake Weighting

We can now run the rake weighting procedure. By default, `rake_weight()`
returns a list of 2 elements: (1) the survey dataset with the weight
variable appended, and (2) the `anesrake()` return object, which
includes a bunch of useful summary statistics (including “design
effect”, which may be useful for estimating confidence intervals).

``` r
svy_wts <- rake_weight(svy, pop_target, "Vrid")
#> [1] "Raking converged in 21 iterations"

svy <- svy_wts$svy
summary(svy$weight)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>  0.3568  0.7408  0.9245  1.0000  1.1662  2.6893

wt_summary <- summary(svy_wts$wts)
deff <- wt_summary$general.design.effect
deff
#> [1] 1.186242

wt_summary
#> $convergence
#> [1] "Complete convergence was achieved after 21 iterations"
#> 
#> $base.weights
#> [1] "No Base Weights Were Used"
#> 
#> $raking.variables
#> [1] "sex"           "age_weight"    "income_weight" "race_weight"  
#> 
#> $weight.summary
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>  0.3568  0.7408  0.9245  1.0000  1.1662  2.6893 
#> 
#> $selection.method
#> [1] "variable selection conducted using _pctlim_ - discrepancies selected using _total_."
#> 
#> $general.design.effect
#> [1] 1.186242
#> 
#> $sex
#>         Target Unweighted N Unweighted %     Wtd N   Wtd % Change in %
#> Male   0.51747          510    0.4318374  611.2812 0.51747  0.08563258
#> Female 0.48253          671    0.5681626  570.0070 0.48253 -0.08563258
#> Total  1.00000         1181    1.0000000 1181.2882 1.00000  0.17126517
#>        Resid. Disc. Orig. Disc.
#> Male   0.000000e+00  0.08563258
#> Female 5.551115e-17 -0.08563258
#> Total  5.551115e-17  0.17126517
#> 
#> $age_weight
#>          Target Unweighted N Unweighted %     Wtd N     Wtd % Change in %
#> 18-34 0.3514503          327    0.2766497  415.4143 0.3514503  0.07480056
#> 35-54 0.3486601          348    0.2944162  412.1162 0.3486601  0.05424384
#> 55+   0.2998896          507    0.4289340  354.4695 0.2998896 -0.12904440
#> Total 1.0000000         1182    1.0000000 1182.0000 1.0000000  0.25808881
#>       Resid. Disc. Orig. Disc.
#> 18-34 0.000000e+00  0.07480056
#> 35-54 0.000000e+00  0.05424384
#> 55+   5.551115e-17 -0.12904440
#> Total 5.551115e-17  0.25808881
#> 
#> $income_weight
#>              Target Unweighted N Unweighted %     Wtd N      Wtd %  Change in %
#> 0-25K    0.17353726          178   0.15071973  204.9975 0.17353726  0.022817533
#> 25-35K   0.09405487          151   0.12785775  111.1059 0.09405487 -0.033802878
#> 35-50K   0.14064324          169   0.14309907  166.1402 0.14064324 -0.002455831
#> 50-75K   0.18922885          242   0.20491109  223.5338 0.18922885 -0.015682244
#> 75-100K  0.15252025          178   0.15071973  180.1704 0.15252025  0.001800522
#> 100-150K 0.16103245          182   0.15410669  190.2257 0.16103245  0.006925756
#> 150K+    0.08898309           81   0.06858594  105.1147 0.08898309  0.020397142
#> Total    1.00000000         1181   1.00000000 1181.2882 1.00000000  0.103881906
#>           Resid. Disc.  Orig. Disc.
#> 0-25K    -5.551115e-17  0.022817533
#> 25-35K    0.000000e+00 -0.033802878
#> 35-50K    2.775558e-17 -0.002455831
#> 50-75K    0.000000e+00 -0.015682244
#> 75-100K  -2.775558e-17  0.001800522
#> 100-150K  0.000000e+00  0.006925756
#> 150K+     0.000000e+00  0.020397142
#> Total     1.110223e-16  0.103881906
#> 
#> $race_weight
#>                           Target Unweighted N Unweighted %     Wtd N      Wtd %
#> White                 0.73559778          973   0.82387807  868.9530 0.73559778
#> Hispanic              0.17719770          114   0.09652837  209.3216 0.17719770
#> Not white or Hispanic 0.08720452           94   0.07959356  103.0137 0.08720452
#> Total                 1.00000000         1181   1.00000000 1181.2882 1.00000000
#>                        Change in %  Resid. Disc.  Orig. Disc.
#> White                 -0.088280289 -1.110223e-16 -0.088280289
#> Hispanic               0.080669338  2.775558e-17  0.080669338
#> Not white or Hispanic  0.007610952  0.000000e+00  0.007610952
#> Total                  0.176560579  1.387779e-16  0.176560579
```
