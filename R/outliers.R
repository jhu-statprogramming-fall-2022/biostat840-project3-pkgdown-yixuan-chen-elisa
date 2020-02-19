# functions for identifying outliers

#' Flag outliers based on tukey's rule
#'
#' Returns a logical vector where TRUE indicates outliers.
#'
#' @param x input values to check
#' @param k the iqr multiplier that determines the fence level. Increasing will
#' make outlier identification less strict (& vice-versa)
#' @param ignore_lwr If TRUE, don't use the lower fence for identifying outliers
#' @param apply_log If TRUE, log transform input values prior to applying tukey's
#' rule. Useful since distributions often have a log-normal shape (e.g., spending)
#' @param ingnore_zero If TRUE, will exclude zero values from IQR & flagging.
#' Note that zeroes will automatically be ignored if apply_log = TRUE
#'
#' @family functions for identifying outliers
#' @export
#' @examples
#' library(dplyr)
#' data(svy)
#' act <- group_by(svy$act, act) %>% mutate(
#'     is_outlier = outlier_tukey(days, ignore_zero = TRUE, apply_log = TRUE),
#'     days_cleaned = ifelse(is_outlier, NA, days)
#' ) %>% ungroup()
outlier_tukey <- function(
    x, k = 1.5, ignore_lwr = FALSE, apply_log = FALSE, ignore_zero = FALSE
) {
    if (ignore_zero) x <- ifelse(x == 0, NA, x)
    if (apply_log) x <- log(x)

    quartiles <- quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
    iqr <- diff(quartiles)
    bottom <- quartiles[1] - k * iqr
    top <- quartiles[2] + k * iqr

    if (ignore_lwr) {
        ifelse(is.na(x) | x < top, FALSE, TRUE)
    }
    ifelse(is.na(x) | (x < top & x > bottom), FALSE, TRUE)
}

#' @describeIn outlier_tukey get the largest non-outlier value for top-coding
#' @export
outlier_tukey_top <- function(x, k = 1.5, apply_log = FALSE, ignore_zero = FALSE) {
    if (ignore_zero) x <- ifelse(x == 0, NA, x)
    if (apply_log) x <- log(x)
    quartiles <- quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
    iqr <- diff(quartiles)
    exp(quartiles[2] + k * iqr)
}
