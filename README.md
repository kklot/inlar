
<!-- README.md is generated from README.Rmd. Please edit that file -->

# inlar

<!-- badges: start -->
<!-- badges: end -->

The goal of inlar is to ease output processing of INLA’s outputs by
putting them in `tibble` format.

## Installation

You can install the released version of inlar here.

``` r
#' remotes::install_github("kklot/inlar")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(tidyverse)
library(INLA)
library(inlar) # load after INLA
```

``` r
## Posterior sample
r = inla(y ~ 1,
  data = data.frame(y = rnorm(2)),
  control.compute = list(config = TRUE)
)

samples = inla.posterior.sample(2, r)

samples |>
  as_tibble("hyperpar")
#> # A tibble: 2 × 3
#>   sample_id term                                    value
#>       <dbl> <chr>                                   <dbl>
#> 1         1 Precision for the Gaussian observations 2.30 
#> 2         2 Precision for the Gaussian observations 0.677

samples |>
  as_tibble("latent")
#> # A tibble: 6 × 4
#>   sample_id term        term_id   value
#>       <dbl> <chr>         <dbl>   <dbl>
#> 1         1 Predictor         1 -1.25  
#> 2         1 Predictor         2 -1.25  
#> 3         1 (Intercept)       1 -1.24  
#> 4         2 Predictor         1  0.0512
#> 5         2 Predictor         2  0.0503
#> 6         2 (Intercept)       1  0.0511

samples |>
  as_tibble("logdens")
#> # A tibble: 2 × 4
#>   sid   hyperpar latent joint
#>   <chr>    <dbl>  <dbl> <dbl>
#> 1 1       -3.37    6.79  3.42
#> 2 2       -0.380   9.26  8.88
```
