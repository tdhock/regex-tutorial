str_match_all_perl<- function(string,pattern){
  parsed <- gregexpr(pattern,string,perl=TRUE)
  lapply(seq_along(parsed),function(i){
    r <- parsed[[i]]
    starts <- attr(r,"capture.start")
    names <- colnames(starts)
    m <- if(r[1]==-1){
      matrix(nrow=0,ncol=1+ncol(starts))
    }else{
      lengths <- attr(r,"capture.length")
      full <- substring(string[i],r,r+attr(r,"match.length")-1)
      subs <- substring(string[i],starts,starts+lengths-1)
      matrix(c(full,subs),ncol=length(names)+1)
    }
    colnames(m) <- c("",names)
    m
  })
}
get.first <- function(html,before,match){
  pattern <- sprintf("%s(%s)",before,match)
  p <- regexpr(pattern,html,perl=TRUE)
  st <- attr(p,"capture.start")
  substr(html,st,st+attr(p,"capture.length")-1)
}
