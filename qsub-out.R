library(namedCapture)

## Read only the lines with data for walltime used.
out.file.vec <- Sys.glob("qsub-out/*_residuals.out")
time.lines <- system("grep Res qsub-out/*.out", intern=TRUE)
head(time.lines)

## Without the third argument, the result is a character matrix.
walltime.pattern <- paste0(
  "(?<person>[^/]+?)",
  "_",
  "(?<cell_type>.*?)",
  "_",
  ".*?",
  ":",
  ".*?",
  "walltime=",
  "(?<hours>[0-9]+)",
  ":",
  "(?<minutes>[0-9]+)",
  ":",
  "(?<seconds>[0-9]+)")
(time.mat <- str_match_named(time.lines, walltime.pattern))

## If the third argument is a named list of functions, then they are
## used to make the columns in the returned data.frame.
conversion.funs <-
  list(hours=as.integer, minutes=as.integer, seconds=as.integer)
time.df <- str_match_named(time.lines, walltime.pattern, conversion.funs)
str(time.df)

## Compute quantiles and plot walltime in minutes.
minutes <- with(time.df, hours*60 + minutes + seconds/60)
quantile(minutes)
hist(minutes)
