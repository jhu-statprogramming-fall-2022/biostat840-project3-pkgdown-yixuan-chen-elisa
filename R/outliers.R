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
#' @param ignore_zero If TRUE, will exclude zero values from IQR & flagging.
#' Note that zeroes will automatically be ignored if apply_log = TRUE
#'
#' @family functions for identifying outliers
#' @export
#' @examples
#' library(dplyr)
#' data(svy)
#' activity <- group_by(svy$act, act) %>% mutate(
#'     is_outlier = outlier_tukey(days, ignore_zero = TRUE, apply_log = TRUE),
#'     days_cleaned = ifelse(is_outlier, NA, days)
#' ) %>% ungroup()
#'
#' # summarize
#' outlier_pct(activity, act)
#' outlier_plot(activity, days, act)
#' filter(activity, days > 0) %>% outlier_plot(days, act, apply_log = TRUE)
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

# Summarizing -------------------------------------------------------------

#' Identify the percentage of values flagged as outliers
#'
#' @param df data frame with outliers identified with df$is_outlier
#' @param ... optional grouping variables (use unquoted names)
#' @family functions for identifying outliers
#' @export
#' @examples
#' # see ?outlier_tukey
outlier_pct <- function(df, ...) {
    grps <- enquos(...)
    df %>%
        group_by(!!! grps, .data$is_outlier) %>%
        summarise(n = n()) %>%
        mutate(pct_outliers = .data$n / sum(.data$n) * 100) %>%
        filter(.data$is_outlier)
}

#' Make a plot of distributions with outliers identified
#'
#' @inheritParams outlier_pct
#' @param var Unquoted name of variable to check
#' @param grp Unquoted name of variable to group by
#' @family functions for identifying outliers
#' @export
#' @examples
#' # see ?outlier_tukey
outlier_plot <- function(df, var, grp, apply_log = FALSE) {
    var <- enquo(var)
    grp <- enquo(grp)
    df <- filter(df, !is.na(!! var))
    cnts <- count(df, !! grp, !! var, .data$is_outlier)
    p <- df %>%
        ggplot(aes(!! grp, !! var)) +
        geom_boxplot(outlier.size = -1) +
        geom_point(data = cnts, aes(size = .data$n, color = .data$is_outlier)) +
        scale_color_manual(values = c("gray", "red"))
    if (apply_log) p <- p + scale_y_log10()
    p
}
