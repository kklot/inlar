
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
library(inlar) 
```

``` r
r = inla(y ~ 1 + f(x, model = 'iid'),
  data = data.frame(y = rnorm(2), x = rnorm(2)),
  control.compute = list(config = TRUE),
  control.predictor = list(compute = TRUE, link = 1)
)

## Summary
r |> as_tibble(type = 'summary', 'random')
#>   var         id      mean       sd      q025       q50     q975
#> 1   x -1.2041507  1.179839 1.086982 -1.009805  1.179572 3.368767
#> 2   x  0.1868074 -1.179848 1.086982 -3.370180 -1.179828 1.008306
r |> as_tibble(type = 'summary', 'linear.predictor')
#> # A tibble: 2 × 8
#>   subj_id       mean     sd   q025    q50   q975      y      x
#>   <chr>        <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
#> 1 Predictor.1 -0.208 0.0175 -0.240 -0.208 -0.174 -0.209  0.187
#> 2 Predictor.2  2.15  0.0175  2.12   2.15   2.18   2.15  -1.20

## Marginals
r |> as_tibble(type = 'marginals', 'random')
#> # A tibble: 150 × 4
#>    var      id      x           y
#>    <chr> <dbl>  <dbl>       <dbl>
#>  1 x         1 -10.5  0.000000940
#>  2 x         1 -10.1  0.0000171  
#>  3 x         1 -10.1  0.0000179  
#>  4 x         1  -9.67 0.0000249  
#>  5 x         1  -8.16 0.0000668  
#>  6 x         1  -7.81 0.0000850  
#>  7 x         1  -5.82 0.000333   
#>  8 x         1  -5.70 0.000362   
#>  9 x         1  -4.75 0.000731   
#> 10 x         1  -4.66 0.000784   
#> # … with 140 more rows
r |> as_tibble(type = 'marginals', 'linear.predictor')
#> # A tibble: 150 × 3
#>       id      x        y
#>    <dbl>  <dbl>    <dbl>
#>  1     1 -0.414 0.000211
#>  2     1 -0.407 0.00425 
#>  3     1 -0.407 0.00428 
#>  4     1 -0.405 0.00459 
#>  5     1 -0.389 0.00653 
#>  6     1 -0.372 0.00924 
#>  7     1 -0.350 0.0162  
#>  8     1 -0.331 0.0281  
#>  9     1 -0.328 0.0308  
#> 10     1 -0.311 0.0525  
#> # … with 140 more rows

## Posterior sample
samples = inla.posterior.sample(2, r)

samples |> as_tibble("hyperpar")
#> # A tibble: 4 × 3
#>   sample_id term                                        value
#>       <dbl> <chr>                                       <dbl>
#> 1         1 Precision for the Gaussian observations  3267.   
#> 2         1 Precision for x                             0.649
#> 3         2 Precision for the Gaussian observations 38780.   
#> 4         2 Precision for x                             0.598
samples |> as_tibble("latent")
#> # A tibble: 10 × 4
#>    sample_id term        term_id  value
#>        <dbl> <chr>         <dbl>  <dbl>
#>  1         1 Predictor         1 -0.244
#>  2         1 Predictor         2  2.13 
#>  3         1 x                 1  1.15 
#>  4         1 x                 2 -1.22 
#>  5         1 (Intercept)       1  0.976
#>  6         2 Predictor         1 -0.205
#>  7         2 Predictor         2  2.16 
#>  8         2 x                 1  1.43 
#>  9         2 x                 2 -0.939
#> 10         2 (Intercept)       1  0.734
samples |> as_tibble("logdens")
#> # A tibble: 2 × 4
#>   sid   hyperpar latent joint
#>   <chr>    <dbl>  <dbl> <dbl>
#> 1 1        -10.9   11.9  1.06
#> 2 2        -12.6   15.5  2.92
```
