# functions for estimating sampling error

#' Calculate Standard Error of the Mean
#'
#' @param x vector: Input numeric vector to be summarized
#' @param na.rm logical: If TRUE, NA (missing) values will be ignored.
#' @references \url{http://en.wikipedia.org/wiki/Standard_error}
#' @family functions for estimating sampling error
#' @export
#' @examples
#' # generate some measurements & estimate std. error
#' x <- rlnorm(50, 3)
#' summary(x)
#' error_se_mean(x)
#'
#' # introduce some missing values
#' nas <- rbinom(50, 1, 0.1)
#' x <- ifelse(nas, NA_integer_, x)
#' summary(x)
#' error_se_mean(x) # doesn't work
#' error_se_mean(x, na.rm = TRUE)
error_se_mean <- function(x, na.rm = FALSE) {
    if (na.rm) x <- na.omit(x)
    sqrt(var(x) / length(x))
}

#' Calculate Standard Error of a Proportion
#'
#' @param pct numeric: Estimated proportion
#' @param N numeric: Number of Responses
#' @references \url{http://en.wikipedia.org/wiki/Standard_error}
#' @family functions for estimating sampling error
#' @export
#' @examples
#' # standard error for N=30, pct=33%/67%
#' x <- c(rep("Checked", 10), rep("Unchecked", 20))
#' N <- length(x)
#' pct <- prop.table(table(x))
#' error_se(pct, N)
error_se <- function(pct, N) {
    sqrt(pct * (1 - pct) / N)
}

#' Calculate Margin of Error at given confidence level
#'
#' @param std_error numeric: Estimated standard error
#' @param confidence numeric: Confidence level (0 < confidence < 1)
#' @references \url{http://en.wikipedia.org/wiki/Margin_of_error}
#' @family functions for estimating sampling error
#' @export
#' @examples
#' # maximum margin of error (proportion) for N=100: 9.8%
#' std_error <- error_se(0.5, 100)
#' error_me(std_error)
error_me <- function(std_error, confidence = 0.95) {
    prob <- confidence + (1 - confidence) / 2
    qnorm(prob) * std_error
}

# Error Propagation -------------------------------------------------------


