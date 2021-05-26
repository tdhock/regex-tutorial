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

regexec(pos.pattern, subject)
regmatches(subject, regexec(pos.pattern, subject))
(regexec_mat <- do.call(rbind, regmatches(subject, regexec(pos.pattern, subject))))
(regexec_df <- data.frame(position_int=as.integer(regexec_mat[,2])))
## Here the names and types must be defined after computing the match
## matrix (separate from the pattern). Numeric indices are used in the
## conversion code, which can be confusing and difficult to maintain!
## For example, if you add a capture group at the beginning of the
## pattern, then you have to change ALL the numeric indices in the
## conversion code.

## Exercise 1 (easy): the pattern below captures the chr ID in
## addition to the position. What modifications would you need for the
## strcapture and regexec code above?
chr.pos.pattern <- "chr(.):([0-9]+)"

(gregexec_result <- regmatches(subject, gregexec(chr.pos.pattern, subject)))
gregexec_df_list <- list()
for(subject_int in seq_along(gregexec_result)){
  gregexec_mat <- gregexec_result[[subject_int]]
  gregexec_df_list[[subject_int]] <- data.frame(
    subject_fac=factor(subject_int),
    chrom=gregexec_mat[2,],
    position_int=as.integer(gregexec_mat[3,]))
}
(gregexec_df <- do.call(rbind, gregexec_df_list))
## Again names and types must be defined after computing the match
## matrix (separate from the pattern).
ggplot()+
  geom_point(aes(
    chrom, position_int, color=subject_fac),
    data=gregexec_df)

named.pattern <- "chr(?P<chrom>.):(?P<position>[0-9]+)"
## Names defined together with the pattern, but type conversion must
## be specified separately.

do.call(cbind, regmatches(subject, regexec(named.pattern, subject, perl=TRUE)))
regmatches(subject, gregexec(named.pattern, subject, perl=TRUE))
## Result is named but conversion to int must be done after,
## separately.
regmatches(subject, gregexec(named.pattern, subject))
## need perl=TRUE (PCRE not TRE) for named groups.

## Exercise 2 (easy): using the named pattern above with regexec or
## gregexec, convert the output to a data frame for plotting. Use
## column names instead of numeric indices to make the code easier to
## understand and maintain.

stringi::stri_match_first_regex(subject, chr.pos.pattern)
stringi::stri_match_all_regex(subject, chr.pos.pattern)
stringi::stri_match_all_regex(subject, named.pattern)#error!
stringi::stri_match_all_regex(subject, "chr(?<chrom>.):(?<position>[0-9]+)")#name ignored.
## stringi uses the ICU library which does NOT support (?P<name>)
## syntax for named groups, nor export of group names to R. Column
## names/types must be defined after, separately from the pattern (as
## with regexec/gregexec above).

?tidyr::extract_numeric


rex::matches(subject, chr.pos.pattern)
(rex.first.match <- rex::matches(subject, named.pattern))
rex.first.match[["position_int"]] <- as.integer(rex.first.match[["position"]])
str(rex.first.match)
rex::matches(subject, named.pattern, global=TRUE)
## Column names defined together with pattern, but type conversion
## must be done after, separately.

re2r::re2_match(subject, chr.pos.pattern)
re2r::re2_match(subject, named.pattern)
re2r::re2_match_all(subject, named.pattern)
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
data.table(subject)[, j=nc::capture_all_str(subject, nc.pos.pattern), by=subject]
## j argument evaluated for each unique value of by (here each subject).

data.table(subject)[, nc::capture_all_str(
  subject, nc.pos.pattern), by=.(subject_fac=factor(seq_along(subject)))]
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
  range.subjects, "chr", chrom=".*?", ":", start=int.pattern, "-", end=int.pattern)
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
options(datatable.print.class=TRUE)
nc::capture_first_df(
  subject.dt,
  JobID=list(job=int.pat, "_", task=int.pat),
  Elapsed=list(hours=int.pat, ":", minutes=int.pat, ":", seconds=int.pat))
subject.dt |> tidyr::extract(
  JobID, c("job", "task"),
  regex="([0-9]+)_([0-9]+)", remove=FALSE, convert=TRUE
) |> tidyr::extract(
  Elapsed, c("hours", "minutes", "seconds"),
  regex="([0-9]+):([0-9]+):([0-9]+)", remove=FALSE, convert=TRUE
)
subject.dt |> tidyr::separate(
  JobID, c("job", "task"),
  sep="_", remove=FALSE, convert=TRUE
) |> tidyr::separate(
  Elapsed, c("hours", "minutes", "seconds"),
  sep=":", remove=FALSE, convert=TRUE
)
