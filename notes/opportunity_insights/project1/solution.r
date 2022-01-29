# Clear the workspace
rm(list = ls())

# Pacman checks and installs then loads any packages (makes repeat runs
# quicker—it won't install it if it's already there!)
install.packages("pacman")
pacman::p_load(haven, dplyr)

setwd("/Users/eoin/Documents/miscellanea/notes/opportunity_insights/project1")
atlas <- read_dta("atlas.dta")

NY <- 36
WESTCHESTER <- 119
MY_TRACT <- 001700

problem_3 <- function() {
  atlas_my_tract <- filter(atlas, state == NY, county == WESTCHESTER, tract == MY_TRACT)

  print("My tract in Yonkers's average upward mobility for parents at the 25th percentile")
  # (Will return 54516.66)
  print(atlas_my_tract$kfr_pooled_p25)

  atlas_ny_cleaned <- filter(atlas, state == NY, !is.na(kfr_pooled_p25), !is.na(count_pooled))
  print("Mean average upward mobility for parents at 25th percentile across census tracts in New York")
  # (Will return 37049.22)
  print(weighted.mean(atlas_ny_cleaned$kfr_pooled_p25, atlas_ny_cleaned$count_pooled, na.rm = TRUE))

  atlas_us_cleaned <- filter(atlas, !is.na(count_pooled), !is.na(kfr_pooled_p25))
  print("Mean average upward mobility for parents at 25th percentile across census tracts in US")
  # (Will return 34311.68)
  print(weighted.mean(atlas_us_cleaned$kfr_pooled_p25, atlas_us_cleaned$count_pooled))
}
problem_3()