library(data.table)
out.lines <- fread("cat *out",sep="\n",header=FALSE)[[1]]
write.lines <- grep("VALID [written to", out.lines, value=TRUE, fixed=TRUE)
file.pattern <- list(
  "[.]{3}VALID [[]written to ",
  ".*?/src/",
  file=".*?",
  "/.*?",
  task="[0-9]+", as.integer,
  "[.]c"
)
write.dt <- nc::capture_first_vec(write.lines, file.pattern)
mutant.dt <- nc::capture_all_str(
  out.lines,
  "\nPROCESSING MUTANT: ",
  line="[0-9]+",
  ": +",
  original=".*?",
  " +==> +",
  mutated="(?:\n(?!PROCESSING)|.)*?",
  file.pattern)
stopifnot(nrow(mutant.dt)==nrow(write.dt))
stopifnot(nrow(mutant.dt[grepl("INVALID", mutated)])==0)
dim(mutant.dt)

