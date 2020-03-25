# functions for survey weighting

#' Estimate rake weights for input survey data & population distributions
#'
#' This is a thin wrapper for \code{\link[anesrake]{anesrake}}. If return_stats =
#' TRUE, it returns a list with (1) a survey dataset and (2) the anesrake() object.
#' Otherwise, it prints a summary and returns just the survey dataset with a
#' weight variable appended.
#'
#' @param svy a survey data frame
#' @param pop a list that holds population distributions for the weighting
#' variables.
#' @param idvar name of varible that holds unique id
#' @param weightvar name of output weight variable
#' @param return_stats If TRUE, the function will instead return a list with 2
#' elements: (1) the survey data frame with a new weight variable, and (2) the
#' object returned directly by anesrake(). This is helpful if you want to later
#' pull elements such as design effect for confidence interval calculations.
#' @param print_name header to print in summary (useful for log output)
#' @param ... other arguments passed to anesrake()
#' @export
#' @examples
#' data(svy, pop)
#' svy <- svy$person
#'
#' # determine target weight values
#' # the population is determined by a survey dataset which is itself weighted
#' wtvars <- c("age_weight", "income_weight", "race_weight")
#' pop_target <- sapply(wtvars, function(x) weights::wpct(pop[[x]], pop$stwt))
#'
#' # compare distributions for survey and population
#' pop_target
#' sapply(wtvars, function(x) weights::wpct(svy[[x]]))
#'
#' # run weighting
#' svy_wts <- rake_weight(svy, pop_target, "Vrid")
#' svy <- svy_wts$svy
#' sapply(wtvars, function(x) weights::wpct(svy[[x]], svy$weight))
#' summary(svy_wts$wts)
rake_weight <- function(
    svy, pop, idvar, weightvar = "weight", return_stats = TRUE, print_name = "", ...
) {
    # anesrake doesn't like tibbles (i.e., the tidyverse version of a data frame)
    svy <- data.frame(svy)

    # run weighting
    wts <- anesrake::anesrake(pop, svy, caseid = svy[[idvar]], ...)
    svy[[weightvar]] <- wts$weightvec

    if (return_stats) {
        list("svy" = svy, "wts" = wts)
    } else {
        cat("\nWeight Summary for", print_name, "-----------------------------\n\n")
        print(summary(wts))
        svy
    }
}
