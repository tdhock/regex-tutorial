works_with_R("3.2.2", data.table="1.9.6")

out.file.vec <- Sys.glob("qsub-out/*_residuals.out")

walltime.pattern <-
  paste0("(?<file>",
         "qsub-out/",
         "(?<person>.*?)",
         "_",
         "(?<cell_type>.*?)",
         "_",
         ".*?",
         ")",
         ":",
         ".*?",
         "walltime=",
         "(?<hours>[0-9]+)",
         ":",
         "(?<minutes>[0-9]+)",
         ":",
         "(?<seconds>[0-9]+)")

time.lines <- system("grep Res qsub-out/*.out", intern=TRUE)
regexpr(walltime.pattern, time.lines, perl=TRUE)
time.df <- str_match_perl(
  time.lines, walltime.pattern,
  list(hours=as.integer, minutes=as.integer, seconds=as.integer)
  )
minutes <- with(time.df, hours*60 + minutes + seconds/60)
  time.list[[step.name]] <- 
    data.frame(step.name, file=mat[,"file"], minutes)
}
times <- do.call(rbind, time.list)

ggplot()+
  geom_
