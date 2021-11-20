#' Show top N values of each group on the boxplot
#'
#' This function adds top N highest values of every group to the boxplot
#' visualization
#'
#' @param dataset Dataframe or tibble with at least two columns
#' @param value A numeric column that is used for ordering
#' @param group A factor or character column used for grouping
#' @param n An integer showing the number of top values to be plotted. Default value is 10.
#'
#' @return A ggplot object, visualization with two layers (boxplot and scatterplot)
#'
#' @details Function would not work if any of the groups has less than n observations
#'
#' @examples
#' mtcars %>%
#' dplyr::mutate(am = as.factor(am)) %>%
#' top_n_boxplot(mpg, am, 5)
#' @export


top_n_boxplot <- function(dataset, value, group, n=10) {
  if (!is.data.frame(dataset)) {
    stop("dataset parameter is not a dataframe")
  }

  check_numeric <- dplyr::summarise(dataset, is.numeric({{ value }}))
  if (!check_numeric[[1]]) {
    stop("col parameter is not a numeric variable")
  }

  check_factor <- dplyr::summarise(dataset, is.factor({{ group }}) |
                                     is.character({{ group }}))
  if (!check_factor[[1]]) {
    stop("group parameter is not a factor")
  }

  if (!DistributionUtils::is.wholenumber(n)) {
    stop("n is not a whole number")
  }

  grouped_df <- dataset %>%
    dplyr::group_by({{ group }}) %>%
    dplyr::summarise(count = dplyr::n())

  if (any(grouped_df$count < n)) {
    stop(paste("At least for one group the number of observations is lower than ", n, ". Please choose a number less or equal to ", min(grouped_df$count)),sep="")
  }

  top_n_values <- dataset %>%
    dplyr::group_by({{ group }}) %>%
    dplyr::top_n(n, wt = {{ value }})

  plot <- ggplot2::ggplot(
    ggplot2::aes(y = {{ value }}, x = {{ group }}),
    data = dataset) +
    ggplot2::geom_boxplot(
      ggplot2::aes(group ={{ group }}, fill = {{ group }})) +
    ggplot2::geom_point(data=top_n_values, color ="red", shape = 4) +
    ggplot2::scale_fill_brewer() +
    ggplot2::theme_minimal()

  return(plot)
}
