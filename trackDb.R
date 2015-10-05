library(namedCapture)

track.pattern <-
  paste0("    ",
         "(?<name>.*?)",
         " ",
         "(?<value>.*?)",
         "\n")

trackDb.lines <- readLines("trackDb.txt")
trackDb.str <- paste(trackDb.lines, collapse="\n")
track.vec <- strsplit(trackDb.str, "\n\\s*\n")[[1]]
subtrack.vec <- paste0(track.vec[-1], "\n")

track.list <- str_match_all_named(subtrack.vec, track.pattern)

subGroups.pattern <- paste0(
  "(?<name>[^ ]+?)",
  "=",
  "(?<value>[^ ]+)")

track.info.list <- list()
for(sample.mat in track.list){
  shortLabel <- sample.mat["shortLabel", ]
  match.list <- str_match_all_named(
    sample.mat[c("subGroups", "metadata"),],
    subGroups.pattern)
  sample.id <- match.list$metadata["SAMPLE_ID", ]
  track.info.list[[shortLabel]] <-
    data.frame(sample.id,
               t(match.list$subGroups))
}
track.info <- do.call(rbind, track.info.list)
head(track.info)
