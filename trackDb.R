library(namedCapture)

## Read the text file and convert it to a character vector with one
## element per track.
trackDb.lines <- readLines("trackDb.txt")
str(trackDb.lines)
trackDb.str <- paste(trackDb.lines, collapse="\n")
str(trackDb.str)
track.vec <- strsplit(trackDb.str, "\n\\s*\n")[[1]]
str(track.vec)
subtrack.vec <- paste0(track.vec[-1], "\n")
str(subtrack.vec)

## If there is a capture group named "name" then it is used as the
## rownames of the resulting match matrices. Extracted data can thus
## be accessed convienently by rownames.
track.pattern <- paste0(
  "    ",
  "(?<name>.*?)",
  " ",
  "(?<value>.*?)",
  "\n")
track.list <- str_match_all_named(subtrack.vec, track.pattern)
sample.mat <- track.list[[1]]
dimnames(sample.mat)
sample.mat["shortLabel", ]
sample.mat["subGroups", ]
sample.mat["metadata", ]

## Extract the subGroups and metadata of each track, and save them to
## the track.info data.frame.
name.value.pattern <- paste0(
  "(?<name>[^ ]+?)",
  "=",
  "(?<value>[^ ]+)")
track.info.list <- list()
for(sample.mat in track.list){
  shortLabel <- sample.mat["shortLabel", ]
  sample.subject <- sample.mat[c("subGroups", "metadata"),]
  match.list <- str_match_all_named(sample.subject, name.value.pattern)
  sample.id <- match.list$metadata["SAMPLE_ID", ]
  track.info.list[[shortLabel]] <-
    data.frame(sample.id, t(match.list$subGroups))
}
track.info <- do.call(rbind, track.info.list)
head(track.info)

## When the input character vector subject has names, they are used as
## names of the output match list.
str(sample.subject)
str(match.list)
