## code to prepare `pop` dataset goes here

library(dplyr)

pop <- readRDS("../../B4W-19-01/data/interim/oia-co.rds") %>%
    filter(in_co_pop) %>%
    select(sex, age_weight:race_weight, stwt)

usethis::use_data(pop, overwrite = TRUE)
