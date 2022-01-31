# SEE https://docs.google.com/document/d/1MTLiMpIHQDBAzehVz7lcnsgjwWU_duDtJoL3FfuVGR4/edit
# FOR THE ASSOCIATED WRITEUP

# Clear the workspace
rm(list = ls())

# Pacman checks and installs then loads any packages (makes repeat runs
# quicker—it won't install it if it's already there!)
install.packages("pacman")
pacman::p_load(haven, dplyr, Hmisc, lmtest, sandwich)

setwd("/Users/eoin/Documents/miscellanea/notes/opportunity_insights/project1")
atlas <- read_dta("atlas.dta")

NY <- 36
WESTCHESTER <- 119
MY_TRACT <- 001700

get_kfr_pooled_for_distribution <- function(atlas, percentile_distribution) {
  if (percentile_distribution == 25) {
    atlas$kfr_pooled_p25
  } else if (percentile_distribution == 75) {
    atlas$kfr_pooled_p75
  } else if (percentile_distribution == 100) {
    atlas$kfr_pooled_p100
  } else {
    stop("INVALID PERCENTILE_DISTRIBUTION. MUST BE 25, 75, OR 100")
  }
}


get_atlas_cleaned <- function(atlas, percentile_distribution) {
  if (percentile_distribution == 25) {
    filter(atlas, !is.na(kfr_pooled_p25), !is.na(count_pooled))
  } else if (percentile_distribution == 75) {
    filter(atlas, !is.na(kfr_pooled_p75), !is.na(count_pooled))
  } else if (percentile_distribution == 100) {
    filter(atlas, !is.na(kfr_pooled_p100), !is.na(count_pooled))
  } else {
    stop("INVALID PERCENTILE_DISTRIBUTION. MUST BE 25, 75, OR 100")
  }
}

get_weighted_mean <- function(atlas, percentile_distribution) {
  if (percentile_distribution == 25) {
    weighted.mean(atlas$kfr_pooled_p25, atlas$count_pooled)
  } else if (percentile_distribution == 75) {
    weighted.mean(atlas$kfr_pooled_p75, atlas$count_pooled)
  } else if (percentile_distribution == 100) {
    weighted.mean(atlas$kfr_pooled_p100, atlas$count_pooled)
  } else {
    stop("INVALID PERCENTILE_DISTRIBUTION. MUST BE 25, 75, OR 100")
  }
}

problem_3 <- function(percentile_distribution) {
  # Calculate average upward mobility for children born to parents at 25th percentile of
  # national income distribution, at tract, state, and country-level (the latter two
  # population-weighted).
  atlas_my_tract <- filter(atlas, state == NY, county == WESTCHESTER, tract == MY_TRACT)

  print("My tract in Yonkers's average upward mobility for parents at the Xth percentile")
  # (Will return 54516.66)
  print(get_kfr_pooled_for_distribution(atlas_my_tract, percentile_distribution))

  atlas_us_cleaned <- get_atlas_cleaned(atlas, percentile_distribution)
  atlas_ny_cleaned <- filter(atlas_us_cleaned, state == NY)
  print("Mean average upward mobility for parents at Xth percentile across census tracts in New York")
  # (Will return 37049.22)
  print(get_weighted_mean(atlas_ny_cleaned, percentile_distribution))

  print("Mean average upward mobility for parents at Xth percentile across census tracts in US")
  # (Will return 34311.68)
  print(get_weighted_mean(atlas_us_cleaned, percentile_distribution))
  # print(weighted.mean(atlas_us_cleaned$kfr_pooled_p25, atlas_us_cleaned$count_pooled))
}
# problem_3(25)

get_variance_westchester <- function(atlas_county, percentile_distribution) {
  if (percentile_distribution == 25) {
    wtd.var(atlas_county$kfr_pooled_p25, atlas_county$count_pooled)
  } else if (percentile_distribution == 75) {
    wtd.var(atlas_county$kfr_pooled_p75, atlas_county$count_pooled)
  } else if (percentile_distribution == 100) {
    wtd.var(atlas_county$kfr_pooled_p100, atlas_county$count_pooled)
  } else {
    stop("INVALID PERCENTILE_DISTRIBUTION. MUST BE 25, 75, OR 100")
  }
}

get_variance_ny <- function(atlas_ny, percentile_distribution) {
  if (percentile_distribution == 25) {
    wtd.var(atlas_ny$kfr_pooled_p25, atlas_ny$count_pooled)
  } else if (percentile_distribution == 75) {
    wtd.var(atlas_ny$kfr_pooled_p75, atlas_ny$count_pooled)
  } else if (percentile_distribution == 100) {
    wtd.var(atlas_ny$kfr_pooled_p100, atlas_ny$count_pooled)
  } else {
    stop("INVALID PERCENTILE_DISTRIBUTION. MUST BE 25, 75, OR 100")
  }
}

get_variance_us <- function(atlas_us, percentile_distribution) {
  if (percentile_distribution == 25) {
    wtd.var(atlas_us$kfr_pooled_p25, atlas_us$count_pooled)
  } else if (percentile_distribution == 75) {
    wtd.var(atlas_us$kfr_pooled_p75, atlas_us$count_pooled)
  } else if (percentile_distribution == 100) {
    wtd.var(atlas_us$kfr_pooled_p100, atlas_us$count_pooled)
  } else {
    stop("INVALID PERCENTILE_DISTRIBUTION. MUST BE 25, 75, OR 100")
  }
}

problem_4 <- function(percentile_distribution) {
  # Calculate standard deviation of population-weighted upward mobility in my home county
  # (WESTCHESTER). Compare to standard deviation across tracts in NY and at country level.
  atlas_cleaned <- get_atlas_cleaned(atlas, percentile_distribution)
  atlas_ny <- filter(atlas_cleaned, state == NY)
  atlas_county <- filter(atlas_cleaned, state == NY, county == WESTCHESTER)
  print("Standard deviation of upward mobility (parents at Xth percentile) in Westchester county:")
  variance_westchester <- get_variance_westchester(atlas_county, percentile_distribution)
  # (Will return: 25 -> 9119.9, 75 -> , 100 ->)
  print(sqrt(variance_westchester))

  print("Standard deviation of upward mobility (parents at Xth percentile) in New York state")
  variance_ny <- get_variance_ny(atlas_ny, percentile_distribution)
  # (Will return: 25 -> 9042., 75 -> , 100 -> )
  print(sqrt(variance_ny))

  print("Standard deviation of upward mobility (parents at Xth percentile) in the US")
  variance_us <- get_variance_us(atlas_cleaned, percentile_distribution)
  # (Will return: 25 -> , 75 -> , 100 -> )
  print(sqrt(variance_us))
}
# problem_4(25)

problem_5 <- function() {
  # Repeat questions 3 and 4 looking at children born to parents at the 75th
  # and 100th percentiles
  print("Problem 3 at 75th percentile distribution for parents")
  problem_3(75)
  print("============================================================")
  print("Problem 3 at 100th percentile distribution for parents")
  problem_3(100)
  print("============================================================")

  print("Problem 4 at 75th percentile distribution for parents")
  problem_4(75)
  print("============================================================")
  print("Problem 4 at 100th percentile distribution for parents")
  problem_4(100)
  print("============================================================")
}

# problem_5()

problem_6 <- function() {
  # Get outcomes at 25th and 75th distributions for each tract in county.
  # Use a linear regression to estimate this relationship.
  # Generate a scatter plot to visualize this.
  # Do places where children of low-income families do well also tend
  # to have better outcomes for high-income families?
  atlas_county <- filter(
    atlas,
    state == NY, county == WESTCHESTER,
    !is.na(kfr_pooled_p25), !is.na(kfr_pooled_p75),
  )
  my_tract <- filter(
    atlas_county, tract == MY_TRACT
  )

  plot(
    atlas_county$kfr_pooled_p25, atlas_county$kfr_pooled_p75,
    col = "blue",
    main = "Children's earnings based on parent's income, by census tract",
    xlab = "For parents at 25th percentile of national income distribution",
    ylab = "For parents at 75th percentile of national income distribution"
  )
  regression <- lm(kfr_pooled_p75 ~ kfr_pooled_p25, data = atlas_county)
  print(summary(regression))
  abline(regression)
  points(my_tract$kfr_pooled_p25, my_tract$kfr_pooled_p75, col = "red", bg = "red", pch = 19)
}
# problem_6()

problem_7 <- function() {
  # Examine whether the results in problem 6 are similar by race.
  # So plot all of those by race on the same scatterplot, and draw
  # multiple linear regressions, one for each race.
  atlas_county <- filter(
    atlas,
    state == NY, county == WESTCHESTER,
    # Keep this is.na(..) check because if there's no pooled
    # data, there won't be by-ethnicity data either. (Slight
    # optimization on a later filter).
    !is.na(kfr_pooled_p25), !is.na(kfr_pooled_p75),
  )
  my_tract <- filter(
    atlas_county, tract == MY_TRACT
  )

  # Make new dataframe with kfr_pooled_p25, kfr_pooled_p75, race
  # using the different pooled p25s together
  # ethnicities: kfr_white_p25, kfr_hisp_p25, kfr_black_p25, kfr_asian_p25
  # kfr_natam_p25
  atlas_black <- atlas_county %>%
    select(kfr_p25 = kfr_black_p25, kfr_p75 = kfr_black_p75) %>%
    mutate(ethnicity = "black")
  atlas_white <- atlas_county %>%
    select(kfr_p25 = kfr_white_p25, kfr_p75 = kfr_white_p75) %>%
    mutate(ethnicity = "white")
  atlas_hisp <- atlas_county %>%
    select(kfr_p25 = kfr_hisp_p25, kfr_p75 = kfr_hisp_p75) %>%
    mutate(ethnicity = "hispanic")
  atlas_asian <- atlas_county %>%
    select(kfr_p25 = kfr_asian_p25, kfr_p75 = kfr_asian_p75) %>%
    mutate(ethnicity = "asian")
  atlas_natam <- atlas_county %>%
    select(kfr_p25 = kfr_natam_p25, kfr_p75 = kfr_natam_p75) %>%
    mutate(ethnicity = "natam")

  atlas_combined_county <- union(atlas_black, atlas_white) %>%
    union(atlas_hisp) %>%
    union(atlas_asian) %>%
    union(atlas_natam) %>%
    filter(!is.na(kfr_p25), !is.na(kfr_p75))

  # NOTE: You can modify the variables below to get plots by race.
  # Just find and replace all the atlas_ values with atlas_combined_county,
  # and uncomment col/legend to get a color-grouped trace for it.
  # color_factor <- factor(atlas_combined_county$ethnicity)
  plot(
    atlas_hisp$kfr_p25, atlas_hisp$kfr_p75,
    main = "Children's earnings based on parent's income, by census tract",
    xlab = "For parents at 25th percentile of national income distribution",
    ylab = "For parents at 75th percentile of national income distribution",
    col = "blue",
    # col = color_factor
  )
  # legend(
  #   "topleft",
  #   legend = color_factor,
  #   pch = 19,
  #   lwd = 01,
  #   text.width = 25000,
  #   col = color_factor
  # )
  regression <- lm(kfr_p75 ~ kfr_p25, data = atlas_hisp)
  abline(regression)
}
# problem_7()

problem_8 <- function() {
  # Try to find covariates which might help explain some of the patterns.
  # Like housing prices, income inequality, fraction of children with single
  # parents, job density, etc. For 3 of these, report estimated correlation
  # coefficients along with 95% confidence intervals.
  # frac_coll_plus2010
  # singleparent_share2010
  # traveltime15_2010
  # jobs_highpay_5mi_2015
  # popdensity2010
  # nonwhite_share2010
  atlas_county <- filter(
    atlas,
    state == NY, county == WESTCHESTER,
    !is.na(kfr_pooled_p25), !is.na(kfr_pooled_p75),
  )
  regression <- lm(kfr_pooled_p75 ~ kfr_pooled_p25 + frac_coll_plus2010, data = atlas_county)
  # print(summary(regression))

  print(cor(atlas_county$kfr_pooled_p25, atlas_county$frac_coll_plus2010))
  new_regression <- lm(kfr_pooled_p25 ~ frac_coll_plus2010 + singleparent_share2010 + traveltime15_2010 + jobs_highpay_5mi_2015 + popdensity2010 + nonwhite_share2010, data = atlas_county)
  print(coeftest(new_regression, vcov = vcovHC(new_regression, type = "HC1")))
}
# problem_8()

problem_9 <- function() {
  # Formulate hypothesis for variation in upward mobility for children
  # who grew up in census tracts near my home.
  # First, identify the relevant census tracts.
  # Then, inspect the covariates nearby and do a linear model with the
  # covariates. See which are related (just do a lot and look which are
  # strongest).
  # Then formulate hypothesis!

  # All the tracts that directly surround the one I grew up in, 001700:
  # 002000, 002104, 001800, 002203, 002300, 001600, 000802,
  relevant_tracts <- c(002000, 002104, 001800, 002203, 002300, 001600, 000802, MY_TRACT)
  atlas_tracts <- atlas %>% filter(tract %in% relevant_tracts)

  regression <- lm(
    kfr_pooled_p75 ~ kfr_pooled_p25 +
      mean_commutetime2000 + frac_coll_plus2010 + foreign_share2010 +
      popdensity2000 + poor_share2010 + gsmn_math_g3_2013 +
      singleparent_share2010 + traveltime15_2010 + ann_avg_job_growth_2004_2013,
    data = atlas_tracts
  )
  print(coeftest(regression, vcov = vcovHC(regression, type = "HC1")))
}
problem_9()