Create Clean Data
================
Christopher Prener, Ph.D.
(April 26, 2022)

## Introduction

This notebook creates a clean crime table covering the years 1946-2017
for the City of St. Louis. It uses a combination of data from the FBI to
produce these estimates. Data prior to 1985 was obtained by entering
values from the `.pdf` files included in `data/raw/pdf/` - these are the
historic, yearly reports produced by the FBI. From 1985-2014, the data
were compiled for an earlier project (will be updating this workflow to
use original data sources at a later date). From 2015 onward, there are
individual raw data files downloaded from the FBI for each city in
Missouri.

These are combined with historic population data to produce yearly
trends for counts and per capita rates for what are known as “index
crimes.” These are sometimes called Part 1 crimes and are subdivided as
follows:

> index crimes… are broken into two categories: violent and property
> crimes. Aggravated assault, forcible rape, murder, and robbery are
> classified as violent while arson, burglary, larceny-theft, and motor
> vehicle theft are classified as property crimes.
> ([Wikipedia](https://en.wikipedia.org/wiki/Uniform_Crime_Reports))

Beginning in 1980, the FBI began releasing their data with population
counts. Prior to this point, population was not included. Data from the
[Missouri Census Data Center](http://mcdc.missouri.edu), which is
available for decennial census years from 1900 to 2000, was used for
years prior to 1980. A model that assumes linear population change was
used to estimate population for each year - a decade where 100,000
people were lost in total population would therefore be modeled as
having lost 10,000 people each year. All rates included are per 100,000
residents.

In addition to missing the original data for 1985-2014, arson data is
missing for those years. Arson was not added as an index crime until
1979. To keep values standard, property crime rates are not calculated
for years prior to 1979. Instead, `theftRate` and `theftTotal` values
are produced for all years (1949 and later - 1946-1948 had incomplete
larceny data) that encompasses burglary, larceny, and theft of a motor
vehicle. For years when arson data is available, `propertyRate` and
`propertyTotal` values are also calculated.

For violent crime, rape data was not available until 1958. `violentRate`
and `violentTotal` values are therefore available for the years 1958
onward. A `murderRate` value is available for all years, and additional
rates can be calculated by dividing the count of crimes per year by the
total population, and then multiplying that by 100,000.

## Dependencies

### Packages

This notebook requires a number of `tidyverse` packages plus `here` and
`janitor` for data import and wrangling:

``` r
# tidyverse packages
library(dplyr)        # data wrangling
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(readr)        # data import
library(readxl)       # data import
library(stringr)      # string tools
library(tidyr)        # data wrangling

# other packages
library(here)         # file paths
```

    ## here() starts at /Users/prenercg/GitHub/PrenerLab/STL_CRIME_Trends

``` r
library(janitor)      # data wrangling
```

    ## 
    ## Attaching package: 'janitor'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     chisq.test, fisher.test

### Functions

To standardize the data cleaning process, a total of six functions have
been written. They do not have any additional dependencies beyond those
listed above:

``` r
# calculate totals for crime categories
source(here("source", "violentTotal.R"))
source(here("source", "theftTotal.R"))
source(here("source", "propertyTotal.R"))

# cleaning contemporary (2015 onward) FBI releases
source(here("source", "contemp.R"))

# calculation population change 1946-1980
source(here("source", "popCalc.R"))
```

## Load Data

This notebook requires a number of different data sets:

## Standardize Names and Data

### 1946-1984

The `stLouis46` data were digitized manually using the preferred
variable names, thus the only work that remains for these years is to
calculate totals for violent crimes, thefts, and property crimes:

``` r
stLouis46 %>%
  violentTotal() %>%
  theftTotal() %>%
  propertyTotal() -> stLouis46
```

### 1985-2014

For the `stLouis85` data, we need to rename columns and reduce the rape
counts from two columns to one:

``` r
stLouis85 %>% 
  clean_names() %>%
  select(-months, -violent_crime_total, -property_crime_total) %>%
  rename(
    murder = murder_and_nonnegligent_manslaughter,
    rape = legacy_rape_1,
    rape2 = revised_rape_2,
    agAssault = aggravated_assault,
    larceny = larceny_theft,
    mvLarceny = motor_vehicle_theft
  ) %>%
  mutate(rape = ifelse(is.na(rape) == TRUE, rape2, rape)) %>%
  select(-rape2) %>%
  mutate(arson = as.numeric(arson)) -> stLouis85
```

Once we have these data tidied, we can calculate new violent and
property crime totals:

``` r
stLouis85 %>%
  violentTotal() %>%
  theftTotal() %>%
  propertyTotal() -> stLouis85 
```

The arson data is currently missing for this time period.

### 2015-2017

The data for these years are cleaned in two stages - we clean up names
so that each table can be combined together with the others, and then
calculate crime totals on the single, combined table.

#### 2015 Names

For `stLouis15`, we first need to subset the data so that we only have
data on St. Louis and clean up column names:

``` r
stLouis15 %>% 
  contempNames(year = 2015) %>%
  mutate(year = 2015) %>%
  contempSubset(year = 2015) -> stLouis15
```

#### 2016 Names

The same needs to be done for 2016:

``` r
stLouis16 %>% 
  contempNames(year = 2016) %>%
  mutate(year = 2016) %>%
  contempSubset(year = 2016) -> stLouis16
```

#### 2017 Names

And for 2017:

``` r
stLouis17 %>% 
  contempNames(year = 2017) %>%
  mutate(year = 2017) %>%
  contempSubset(year = 2017) -> stLouis17
```

#### 2018 Names

And for 2017:

``` r
stLouis18 %>% 
  contempNames(year = 2018) %>%
  mutate(year = 2018) %>%
  contempSubset(year = 2018) %>%
  rename(arson = arson2) -> stLouis18
```

#### 2019 Names

And for 2019:

``` r
stLouis19 %>% 
  contempNames(year = 2019) %>%
  mutate(year = 2019) %>%
  contempSubset(year = 2019) %>%
  rename(arson = arson2) -> stLouis19
```

### 2020 and 2021

The data for 2020 and 2021 will be entered manually:

``` r
stLouis20 %>%
  filter(city == "St. Louis") %>%
  mutate(population = case_when(
    year == 2020 ~ 301578,
    year == 2021 ~ 293310
  )) %>%
  mutate(murder = ifelse(year == 2021, 199, murder)) %>%
  rename(
    agAssault = aggravated_assault,
    larceny = larceny_theft,
    mvLarceny = motor_vehicle_theft
  ) %>%
  select(year, population, murder, rape, robbery, agAssault, burglary,
         larceny, mvLarceny, arson) -> stLouis20
```

### Combine

Once we have these datas’ names standardized, we can bind them together
and remove the intermediate objects:

``` r
# bind tables
stLouis15 <- bind_rows(stLouis15, stLouis16, stLouis17, stLouis18, stLouis19, stLouis20)

# remove intermediate objects
rm(stLouis16, stLouis17, stLouis18, stLouis19, stLouis20)
```

### Crime Counts

With the data combined, we can calculate totals for violent crime,
theft, and property crimes:

``` r
stLouis15 %>%
  violentTotal() %>%
  theftTotal() %>%
  propertyTotal() -> stLouis15
```

## Combine

With all columns standardized, we can bind all of the data together and
again remove intermediate objects:

``` r
# bind tables
stLouis <- bind_rows(stLouis46, stLouis85, stLouis15)

# remove intermediate objects
rm(stLouis46, stLouis85, stLouis15)
```

## Create Population Estimates

Since years prior to 1980 lack population estimates, we need to produce
yearly population estimates. To start, we’ll clean-up the Missouri
historical census data so that we only have data for St. Louis for
decennial census years 1930 through 1980. We also reshape the data to
long to facilitate additional cleaning:

``` r
stLouisPop %>%
  filter(fipco == "29510") %>%
  select(-c(fipco, areaname)) %>%
  gather(key = "year", value = "population") %>%
  mutate(year = as.numeric(year)) %>%
  filter(year > 1930 & year < 1990) -> stLouisPop
```

With the data clean, we calculate linear population change estimates for
each year between decennial census years. We then combine them all
together and insert them into the crime table before removing the
intermediate population objects:

``` r
# calculate yearly population estimates
pop40 <- popCalc(stLouisPop, start = 1940, end = 1950)
pop50 <- popCalc(stLouisPop, start = 1950, end = 1960)
pop60 <- popCalc(stLouisPop, start = 1960, end = 1970)
pop70 <- popCalc(stLouisPop, start = 1970, end = 1980)

# combine with crime data
bind_rows(pop40, pop50, pop60, pop70) %>%
  distinct(year, population) %>%
  filter(year >= 1946) %>%
  left_join(stLouis, ., by = "year") %>%
  mutate(population.x = ifelse(is.na(population.y) == FALSE, population.y, population.x)) %>%
  select(-population.y) %>%
  rename(population = population.x) -> stLouis

# remove intermediate objects
rm(pop40, pop50, pop60, pop70, popYears, stLouisPop)
```

    ## Warning in rm(pop40, pop50, pop60, pop70, popYears, stLouisPop): object
    ## 'popYears' not found

## Create Per Capita Rates

We are now able to calculate crime rates for murder, violent crime,
property crime (only for a few years at this point), and thefts:

``` r
stLouis %>%
  mutate(murderRate = (murder/population)*100000) %>%
  mutate(agAssaultRate = (agAssault/population)*100000) %>%
  mutate(violentRate = (violentTotal/population)*100000) %>%
  # mutate(propertyRate = (propertyTotal/population)*100000) %>%
  mutate(theftRate = (theftTotal/population)*100000) %>%
  select(year, population, violentTotal, violentRate, murder, murderRate,
         rape, robbery, agAssault, agAssaultRate, propertyTotal, 
         theftTotal, theftRate, everything()) -> stLouis
```

## Write Data

Finally, data are written to `data/clean` for plotting and
dissemination.

``` r
write_csv(stLouis, here("data", "clean", "STL_CRIME_Trends.csv"))
```
