works_with_R(
  "3.3.2",
  "tidyverse/stringr@2ff11fdf91c248fa3e068b6323d20b1d789a2416",
  "tdhock/namedCapture@1da425bb24a2ff1edc89d38654b5c9465aa9fa20",
  "MangoTheCat/rematch2@a5e4648600acd4e509897a04d2ed61e25b0dd583",
  "qinwf/re2r@044cd14df46d2aa04b7b48be5345d57bce131838")

pattern <- "^(?P<lowerdot>(?P<lower>[a-z])+.)+[A-Z](?P<after>[a-z])+$"

max.N <- 25
times.list <- list()
for(N in 1:max.N){
  cat(sprintf("subject size %4d / %4d\n", N, max.N))
  subject <- paste0(paste0(rep("a",N), collapse = ""),"Boom!")
  N.times <- microbenchmark::microbenchmark(
    ##stringr=stringr.result <- str_match(subject, pattern),
    re2r=re2r.result <- re2_extract(pattern, subject),
    namedCapture=namedCapture.result <- str_match_named(subject, pattern),
    rematch2=rematch2.result <- re_match(subject, pattern),
    times=10)
  times.list[[N]] <- data.frame(N, N.times)
}
times <- do.call(rbind, times.list)

library(ggplot2)
library(directlabels)
linear.legend <- ggplot()+
  ggtitle("Timing regular expressions in R, linear scale")+
  scale_y_continuous("seconds")+
  scale_x_continuous("subject/pattern size",
                     limits=c(1, 27),
                     breaks=c(1, 5, 10, 15, 20, 25))+
  geom_point(aes(N, time/1e9, color=expr),
             shape=1,
             data=times)
(linear.dl <- direct.label(linear.legend, "last.polygons"))

png("figure-compare-linear.png")
print(linear.dl)
dev.off()

log.legend <- ggplot()+
  ggtitle("Timing regular expressions in R, log scale")+
  scale_y_log10("seconds")+
  scale_x_log10("subject/pattern size",
                limits=c(1, 30),
                breaks=c(1, 5, 10, 15, 20, 25))+
  geom_point(aes(N, time/1e9, color=expr),
             shape=1,
             data=times)
(log.dl <- direct.label(log.legend, "last.polygons"))

png("figure-compare-log.png")
print(log.dl)
dev.off()
