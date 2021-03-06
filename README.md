
<!-- README.md is generated from README.Rmd. Please edit that file -->

# saeonobsr <img src="saeon_hex.png" align="right" alt="" width="240" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/GMoncrieff/saeonobsr/workflows/R-CMD-check/badge.svg)](https://github.com/GMoncrieff/saeonobsr/actions)
<!-- badges: end -->

saeonobsr provides functions to query and download selected datasets
from the SAEON observations database.

Two functions are made available to users:

`viewDatasets()`

which lists available datasets with the option to limit results to
within a region of interest. The result can be filtered and passed to

`getDatasets()`

which downloads the selected datasets and optionally limits results to
within a specific timeframe

## Installation

You can install the latest version of saeonobsr from
[GitHub](https://github.com/GMoncrieff/saeonobsr) with:

``` r
# install.packages("devtools")
devtools::install_github("GMoncrieff/saeonobsr")
```

## Authorisation

To use saeonobsr you need to first register an account [SAEON
observations database](http://observations.saeon.ac.za/). Once
registered you need to login and retrieve an API token from
<https://observations.saeon.ac.za/account/token>. This token will be
valid for 1 month.

## Quickstart

Before starting set your API access token using

``` r
Sys.setenv(OBSDB_KEY = "xxx")
```

The code below lists all datasets available for the Cape Peninsula,
South Africa, and downloads daily minimum temperature data for a single
site

``` r
library(saeonobsr)
library(ggplot2)
library(dplyr)
library(sf)

#create spatial bounds
#done using geojson.io
region <- '{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "Polygon",
       "coordinates": [[[
              18.25927734375,
              -34.363843538830665
            ],[
              18.571014404296875,
              -34.363843538830665
            ],[
              18.571014404296875,
              -33.87839688404626
            ],[
              18.25927734375,
              -33.87839688404626
            ],[
              18.25927734375,
              -34.363843538830665
            ]]]}}]
}'
#create sf object
bounds <- st_read(region,quiet = TRUE)

#get a list of available datasets
#then filter to a selected site and observation type
datasets <- viewDatasets(extent=bounds,spatial = FALSE) %>%
      filter(siteName == 'Constantiaberg') %>%
      filter(description == 'Air Temperature - Daily Minimum - Degrees Celsius')

#retrieve the selected datasets for 2019
start <- '2019-01-01'
end <- '2019-12-31'
obs <- getDatasets(datasets,startDate=start,endDate=end)
#> [1] "received dataset with id 62f6bee3-4be5-4d2d-5011-08da455c794d"
head(obs)
#> # A tibble: 6 ?? 10
#>   instrument  sensor date  latitude longitude value phenomenon offering variable
#>   <chr>       <chr>  <chr>    <dbl>     <dbl> <dbl> <chr>      <chr>    <chr>   
#> 1 Constantia??? Const??? 2019???    -34.1      18.4 11.1  Air Tempe??? Daily M??? Air Tem???
#> 2 Constantia??? Const??? 2019???    -34.1      18.4  8.93 Air Tempe??? Daily M??? Air Tem???
#> 3 Constantia??? Const??? 2019???    -34.1      18.4  8.77 Air Tempe??? Daily M??? Air Tem???
#> 4 Constantia??? Const??? 2019???    -34.1      18.4 10.5  Air Tempe??? Daily M??? Air Tem???
#> 5 Constantia??? Const??? 2019???    -34.1      18.4 11.6  Air Tempe??? Daily M??? Air Tem???
#> 6 Constantia??? Const??? 2019???    -34.1      18.4 10.1  Air Tempe??? Daily M??? Air Tem???
#> # ??? with 1 more variable: unit <chr>

#visualize
plot <- obs %>% ggplot() +
  geom_line(aes(y = value, x = as.Date(date))) +
  ggtitle("Daily minimum air temperature for Constantiaberg Peak") +
  xlab("Date") +
  ylab(expression("Air Temperature " ( degree*C)))

plot
```

<img src="man/figures/README-example-1.png" width="100%" />
