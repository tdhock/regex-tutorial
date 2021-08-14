## Python pandas has some way to do this, see ex.py and
## https://pandas.pydata.org/docs/reference/api/pandas.wide_to_long.html
## but it is complicated and limited, like stats::reshape in R.
(one.iris <- data.table(iris[1,]))
varying <- list(
  Sepal=c("Sepal.Length", "Sepal.Width"),
  Petal=c("Petal.Length", "Petal.Width"))
stats::reshape(
  one.iris,
  varying=varying,
  direction="long",
  v.names=names(varying),
  times=c("Length", "Width"),
  timevar="dim")

varying <- list(
  Length=c("Sepal.Length", "Petal.Length"),
  Width=c("Sepal.Width", "Petal.Width"))
stats::reshape(
  one.iris,
  varying=varying,
  direction="long",
  v.names=names(varying),
  times=c("Sepal", "Petal"),
  timevar="part")

times <- c("Sepal.Length","Sepal.Width","Petal.Length","Petal.Width")
stats::reshape(
  one.iris, varying=list(times), direction="long", v.names="cm", times=times)

names_pattern <- "(.*)[.](.*)"
tidyr::pivot_longer(
  one.iris, matches(names_pattern),
  names_pattern=names_pattern,
  names_to=c("part","dim"))

tidyr::pivot_longer(
  one.iris, matches(names_pattern),
  names_pattern=names_pattern,
  names_to=c(".value","dim"))

tidyr::pivot_longer(
  one.iris, matches(names_pattern),
  names_pattern=names_pattern,
  names_to=c("part",".value"))

data.table::melt(one.iris, measure=measure(part, dim, pattern=names_pattern))

data.table::melt(one.iris, measure=measure(value.name, dim, pattern=names_pattern))

nc::capture_melt_single(one.iris, part=".*", "[.]", dim=".*")

nc::capture_melt_multiple(one.iris, column=".*", "[.]", dim=".*")
