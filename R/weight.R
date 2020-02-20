# functions for survey weighting

#' Estimate rake weights for input survey data & population distributions
#'
#' This is a thin wrapper for \code{\link[anesrake]{anesrake}}. It prints a
#' summary and returns the survey dataset with a rake_wt variable appended.
#'
#' @param svy a survey data frame
#' @param pop a list that holds population distributions for the weighting
#' variables.
#' @param print_name header to print in summary (useful for log output)
#' @param idvar name of varible that holds unique id
#' @param weightvar name of output weight variable
#' @param cap cap argument of anesrake()
#' @param force1 force1 argument of anesrake()
#' @param ... other arguments passed to anesrake()
#' @export
#' @examples
#' library(weights)
#' data(svy, pop)
#' svy <- svy$person
#'
#' # determine target weight values
#' # the population is determined by a survey dataset which is itself weighted
#' wtvars <- c("age_weight", "income_weight", "race_weight")
#' pop_target <- sapply(wtvars, function(x) wpct(pop[[x]], pop$stwt))
#'
#' # compare distributions for survey and population
#' pop_target
#' sapply(wtvars, function(x) wpct(svy[[x]]))
#'
#' # run weighting
#' svy <- rake_weight(svy, pop_target, "Vrid")
#' sapply(wtvars, function(x) wpct(svy[[x]], svy$weight))
rake_weight <- function(
    svy, pop, idvar, weightvar = "weight", print_name = "",
    cap = 20, force1 = TRUE, ...
) {
    # anesrake doesn't like tibbles (i.e., the tidyverse version of a data frame)
    svy <- data.frame(svy)

    # run weighting
    wts <- anesrake::anesrake(
        pop, svy, caseid = svy[[idvar]], force1 = force1, cap = cap, ...
    )

    # print summary
    cat("\nWeight Summary for", print_name, "-----------------------------\n\n")
    print(summary(wts))

    # return output
    svy[[weightvar]] <- wts$weightvec
    svy
}
