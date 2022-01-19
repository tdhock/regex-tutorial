subject <- c("chr1:10", "chrX:25 chrY:15")
pos.pattern <- ":([0-9]+)" #parens are capture groups
proto <- data.frame(position_int=integer())
(strcapture_df <- strcapture(pos.pattern, subject, proto))
str(strcapture_df)
## two points to notice: where are names and types for output columns
## defined? Together with the pattern or? Here names and types are
## defined together in proto, which is separate from pattern.

library(ggplot2)
ggplot()+
  geom_point(aes(
    seq_along(position_int), position_int),
    data=strcapture_df)

(regexec.result <- regexec(pos.pattern, subject))
(regmatches.result <- regmatches(subject, regexec.result))
(regexec_mat <- do.call(rbind, regmatches.result))
colnames(regexec_mat) <- c("full.match", "position_chr")
(regexec_df <- data.frame(position_int=as.integer(regexec_mat[,"position_chr"])))
## Here the names and types must be defined after computing the match
## matrix (separate from the pattern). 

## Exercise 1 (easy): the pattern below captures the chr ID in
## addition to the position. What modifications would you need for the
## strcapture and regexec code above?
chr.pos.pattern <- "chr(.):([0-9]+)"

(gregexec_result <- regmatches(subject, gregexec(chr.pos.pattern, subject)))
gregexec_df_list <- list()
for(subject_int in seq_along(gregexec_result)){
  gregexec_mat <- gregexec_result[[subject_int]]
  rownames(gregexec_mat) <- c("full.match", "chrom", "position_chr")
  gregexec_df_list[[subject_int]] <- data.frame(
    subject_fac=factor(subject_int),
    chrom=gregexec_mat["chrom",],
    position_int=as.integer(gregexec_mat["position_chr",]))
}
(gregexec_df <- do.call(rbind, gregexec_df_list))
## Again names and types must be defined after computing the match
## matrix (separate from the pattern).
ggplot()+
  geom_point(aes(
    chrom, position_int, color=subject_fac),
    data=gregexec_df)

named.pattern <- "chr(?P<chrom>.):(?P<position_chr>[0-9]+)"
## Names defined together with the pattern, but type conversion must
## be specified separately.

do.call(cbind, regmatches(subject, regexec(named.pattern, subject, perl=TRUE)))
regmatches(subject, gregexec(named.pattern, subject, perl=TRUE))
## Result is named but conversion to int must be done after,
## separately.
regmatches(subject, gregexec(named.pattern, subject))
## need perl=TRUE (PCRE not TRE) for named groups.

## Exercise 2 (easy): using the named pattern above with regexec or
## gregexec, convert the output to a data frame (with columns
## position_int and subject_fac) for plotting.

stringi::stri_match_first_regex(subject, chr.pos.pattern)
stringi::stri_match_all_regex(subject, chr.pos.pattern)
stringi::stri_match_all_regex(subject, named.pattern)#error, (?P< not allowed in ICU regex.
stringi::stri_match_all_regex(subject, "chr(?<chrom>.):(?<position>[0-9]+)")#name output to R as of stringi-1.7.1 (2021-06-19)
## Column types must be defined after, separately from the pattern (as
## with regexec/gregexec above).

rex::matches(subject, chr.pos.pattern)
(rex.first.match <- rex::matches(subject, named.pattern))
rex.first.match[["position_int"]] <- as.integer(rex.first.match[["position_chr"]])
str(rex.first.match)
rex::matches(subject, named.pattern, global=TRUE)
## Column names defined together with pattern, but type conversion
## must be done after, separately.

re2::re2_match(subject, chr.pos.pattern)
re2::re2_match(subject, named.pattern)
re2::re2_match_all(subject, named.pattern)
## similar.

rematch2::re_match(subject, chr.pos.pattern)
rematch2::re_match(subject, named.pattern)
rematch2::re_match_all(subject, named.pattern)
## similar.

## Exercise 3 (easy): use one of re2r, rematch2, stringi, rex to
## convert match_all/global=TRUE output to a data frame for plotting,
## including creation of position_int and subject_fac columns.

nc::capture_first_vec(subject, pos.pattern)#error!
pos.pattern
nc.pos.pattern <- list(":", position_int="[0-9]+", as.integer)
## Note that group name, pattern, and type conversion are defined
## together in this list.

nc.first.match.dt <- nc::capture_first_vec(subject, nc.pos.pattern)
print(nc.first.match.dt, class=TRUE)
## Column is named and typed!

nc::var_args_list(nc.pos.pattern)
## Display the regex that is generated and used for
## matching/capturing. Note that un-named lists become non-capturing
## groups (?:), and named patterns become capture groups ().

## Exercise 4 (medium): Add a chrom group to the pattern above, then
## use it with nc::capture_first_vec for processing and
## nc::var_args_list for pattern display.

nc::capture_all_str(subject, nc.pos.pattern)#treats as one subject.
library(data.table)
data.table(subject)[
, j=nc::capture_all_str(subject, nc.pos.pattern),
  by=subject]
## j argument evaluated for each unique value of by (here each subject).

data.table(subject)[
, nc::capture_all_str(subject, nc.pos.pattern),
  by=.(subject_fac=factor(seq_along(subject)))]
## can create new variables in by.

range.subjects <- c(
  "chr1:1-2", "chr1:4-5", "chr10:8-9", "chr2:6-7", "chrY:19-20",
  "chrX:17-18", "chr17_ctg5_hap1:13-14", "chr21:15-16", "chr17:10-11")
## Exercise 5 (easy): parse using regex with three groups (chrom,
## start, end), then plot using geom_segment. Hint: for matching start
## and end, you can define and re-use a sub-pattern list variable
## which contains the pattern and conversion function.

## Exercise 6 (hard): create a chrom_fac column which is a factor with
## levels that are sorted so that the ggplot display order is 1, 2,
## 10, 17, 17_ctg5_hap1, 21, X, Y. Create the factor levels
## programmatically based on the data -- don't just copy and paste the
## values mentioned above!

## Solution!
int.pattern <- list("[0-9]+", as.integer)
range.dt <- nc::capture_first_vec(
  range.subjects,
  "chr", chrom=".*?", ":", start=int.pattern, "-", end=int.pattern)
ggplot()+
  geom_segment(aes(
    chrom, start,
    xend=chrom, yend=end),
    data=range.dt)

## Solution 1, use sub in a conversion function.
range.dt <- nc::capture_first_vec(
  range.subjects, "chr",
  chrom_fac=".*?", function(chrom){
    prefix <- sub("_.*", "", chrom)
    ord.vec <- order(suppressWarnings(as.integer(prefix)), chrom)
    levs <- unique(chrom[ord.vec])
    factor(chrom, levs)
  }, ":", start=int.pattern, "-", end=int.pattern)
ggplot()+
  geom_segment(aes(
    chrom_fac, start,
    xend=chrom_fac, yend=end),
    data=range.dt)

## Solution 2, capture and use the prefix group.
range.dt <- nc::capture_first_vec(
  range.subjects, "chr",
  chrom=list(prefix="[^_]+", ".*?"),
  ":", start=int.pattern, "-", end=int.pattern)
levs <- range.dt[
  order(suppressWarnings(as.integer(prefix)), chrom),
  unique(chrom)]
range.dt[, chrom_fac := factor(chrom, levs)]
ggplot()+
  geom_segment(aes(
    chrom_fac, start,
    xend=chrom_fac, yend=end),
    data=range.dt)

## TODO exercises
subject.dt <- data.table::data.table(
  JobID = c("13937810_25", "14022192_1"),
  Elapsed = c("07:04:42", "07:04:49"))
int.pat <- list("[0-9]+", as.integer)
## Sub-pattern and type conversion defined together.
options(datatable.print.class=TRUE)
nc::capture_first_df(
  subject.dt,
  JobID=list(job=int.pat, "_", task=int.pat),
  Elapsed=list(hours=int.pat, ":", minutes=int.pat, ":", seconds=int.pat))
## One call to nc::capture_first_df parses both input columns.

## using data.table::tstrsplit
subject.dt[, tstrsplit(
  JobID, "_", type.convert=TRUE, names=c("job", "task"))]
subject.dt[, tstrsplit(
  Elapsed, ":", type.convert=TRUE, names=c("hours", "minutes", "seconds"))]

subject.dt |> tidyr::extract(
  JobID, into=c("job", "task"),
  regex="([0-9]+)_([0-9]+)", remove=FALSE, convert=TRUE
) |> tidyr::extract(
  Elapsed,  into=c("hours", "minutes", "seconds"),
  regex="([0-9]+):([0-9]+):([0-9]+)", remove=FALSE, convert=TRUE
)
## Pattern defined by regex argument, separate from names which are
## defined by into argument. Limited type conversion: when
## convert=TRUE the type.convert() function is used. Also note that
## tidyr::extract must be called twice (once for each input column to
## parse).

subject.dt |> tidyr::separate(
  JobID, into=c("job", "task"),
  sep="_", remove=FALSE, convert=TRUE
) |> tidyr::separate(
  Elapsed, c("hours", "minutes", "seconds"),
  sep=":", remove=FALSE, convert=TRUE
)
## In this case a separator is simpler to use than a regex.

## Data reshaping!
(one.iris <- iris[1,])
nc::capture_melt_single(one.iris, part=".*", "[.]", dim=".*")

names_pattern <- "(.*)[.](.*)"
tidyr::pivot_longer(
  one.iris, matches(names_pattern),
  names_pattern=names_pattern,
  names_to=c("part","dim"))

library(data.table)
melt(as.data.table(one.iris), measure=measure(part, dim, pattern=names_pattern))

## base R equivalent!
capture.df <- strcapture(
  names_pattern,
  names(one.iris),
  data.frame(part=character(), dim=character()))
rownames(capture.df) <- names(one.iris)
match.df <- subset(capture.df, !is.na(part))
times <- rownames(match.df)
one.long <- stats::reshape(
  one.iris,
  varying=list(times),
  direction="long",
  v.names="cm",
  times=times,
  timevar="variable")
data.frame(one.long, match.df[paste(one.long$variable),])

## Exercise: use one of these tools to reshape entire iris data set,
## then use ggplot2 to make a histogram (fill=Species) with facets for
## part and dim.

## special multiple output column keywords for
## nc(column),data.table(value.name),tidyr(.value)
nc::capture_melt_multiple(one.iris, column=".*", "[.]", dim=".*")
melt(
  as.data.table(one.iris),
  measure=measure(value.name, dim, pattern=names_pattern))
tidyr::pivot_longer(
  one.iris, matches(names_pattern),
  names_pattern=names_pattern,
  names_to=c(".value","dim"))

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



library(bit64)
library(data.table)
value <- list(NA, NA_character_, NA_complex_, NA_integer_, NA_integer64_, NA_real_)
DT <- data.table(value, class=sapply(value, class), is.na=sapply(value, is.na))
DT[is.na(value)==FALSE]
DT[is.na==FALSE]
DT.wide <- data.table(l1=list(NA, c(NA,NA)), l2=list(NA_complex_, NA_integer64_))
(DT.long.na.rm <- melt(DT.wide, measure=c("l1","l2"), na.rm=TRUE))
DT.long.na.keep <- melt(DT.wide, measure=c("l1","l2"), na.rm=FALSE)
DT.long.na.keep[!is.na(value)]
DT.long.na.list <- lapply(DT.long.na.keep[["value"]], is.na)
lengths(DT.long.na.list)==1 & DT.long.na.listis
is.na(l)
sapply(l, is.na)
DT <- data.table(l, i=seq_along(l))
times <- ,"i")
stats::reshape(
  DT,
  varying=list(times),
  direction="long",
  v.names="cm",
  times=times,
  timevar="variable")
