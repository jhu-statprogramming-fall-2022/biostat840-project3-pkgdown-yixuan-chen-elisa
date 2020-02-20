## code to prepare `svy` dataset goes here

library(dplyr)

# get survey data
svy <- readRDS("../../B4W-19-01/data/interim/svy-demo.rds")
svy <- lapply(svy, as_tibble)
flags <- readRDS("../../B4W-19-01/data/interim/svy-flag.rds")$flag_totals

# drop SPSS legacy attributes (which produce annoying warnings on joins)
attributes(svy$person$Vrid) <- NULL
attributes(svy$act$Vrid) <- NULL
attributes(flags$Vrid) <- NULL

# exclude suspicious respondents
suspicious <- filter(flags, flag >= 4)
svy <- lapply(svy, function(df) anti_join(df, suspicious, by = "Vrid"))

# reduce the scope of the data a bit
svy$person <- select(svy$person, Vrid, age_weight:race_weight)
svy$act <- filter(svy$act, is_targeted) %>%
    select(Vrid, act, part, days)
svy$basin <- NULL

usethis::use_data(svy)
