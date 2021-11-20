### Testing incorrect data inputs
cars <- mtcars %>%
  dplyr::mutate(am = as.factor(am))

test_that("Incorrect parameters", {
  lm1 <- lm(mpg ~ am, data = mtcars)
  testthat::expect_error(top_n_boxplot(lm1, mpg, am),"not a dataframe")
  testthat::expect_error(top_n_boxplot(palmerpenguins::penguins, sex, species),"not a numeric")
  testthat::expect_error(top_n_boxplot(cars, mpg, wt),"not a factor")
  testthat::expect_error(top_n_boxplot(cars, mpg, am, 4.5), "not a whole number")
})

### Testing compatibility with NA, or one category only
df <- data.frame(
  x = c(0.2, 0.3, 0.2, 0.4, 0.1),
  y = c(NA, 0.3, 0.2, NA, 0.1))
df$factor <- "a"

test_that("NA and one category do not produce errors", {
  testthat::expect_silent(top_n_boxplot(df, x, factor, 2))
  testthat::expect_silent(top_n_boxplot(df, y, factor, 2))
})

### Testing the return object type
test_that("Plot returns correct object", {
  bxplot<-top_n_boxplot(cars, mpg, am)
  testthat::expect_s3_class(bxplot, "ggplot")
})

### Testing ggplot2 object components
test_that("Plot details are correct", {
  bxplot<-top_n_boxplot(cars, mpg, am)
  testthat::expect_length(bxplot$layers, 2)
  testthat::expect_match(class(bxplot$layers[[1]]$geom)[[1]], "Boxplot")
  testthat::expect_match(class(bxplot$layers[[2]]$geom)[[1]], "Point")
})
