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

## ex 2.
out.lines <- readLines("qsub-out/BF775_Mono_ATACSeq_2_residuals.out")

epilogue.mat <- str_match_all_variable(
  tail(out.lines, 15),
  "\n",
  name=".*?",
  ":\\s+",
  value="\\S+")
str_match_all_variable(
  epilogue.mat["Resources", ],
  name="[^,]+?",
  "=",
  value="[^,]+")

## Ex 3.
out.files <- Sys.glob("qsub-out/*.out")
out.text.vec <- sapply(out.files, function(f)paste(readLines(f), collapse="\n"))

name.mat <- str_match_variable(
  out.files,
  "/",
  sample_type=list(
    sample=".*?",
    "_",
    type=".*?"
  ), "_ATAC")
names(out.text.vec) <- name.mat[, "sample_type"]

int.pattern <- list("[0-9]+", as.integer)
str_match_variable(
  out.text.vec,
  pmem="[0-9]+",
  "mb,walltime=",
  hours=int.pattern,
  ":",
  minutes=int.pattern,
  ":",
  seconds=int.pattern)

hms.pattern <- function(prefix){
  L <- list(
    prefix, "=",
    hours=int.pattern,
    ":",
    minutes=int.pattern,
    ":",
    seconds=int.pattern)
  to.rep <- names(L)!=""
  names(L)[to.rep] <- paste0(prefix, "_", names(L)[to.rep])
  L
}

str_match_variable(
  out.text.vec,
  hms.pattern("cput"),
  ",mem=",
  mem=int.pattern,
  "kb,vmem=",
  vmem=int.pattern,
  "kb,",
  hms.pattern("walltime"))
