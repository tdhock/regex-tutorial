## Parse the first occurance of pattern from each of several strings
## using (named) capturing regular expressions, returning a matrix
## (with column names).
str_match_perl <- function(string, pattern, type.list=NULL){
  stopifnot(is.character(string))
  stopifnot(is.character(pattern))
  stopifnot(length(pattern)==1)
  parsed <- regexpr(pattern,string,perl=TRUE)
  captured.text <- substr(string,parsed,parsed+attr(parsed,"match.length")-1)
  captured.text[captured.text==""] <- NA
  captured.groups <- if(is.null(attr(parsed, "capture.start"))){
    NULL
  }else{
    do.call(rbind,lapply(seq_along(string),function(i){
      st <- attr(parsed,"capture.start")[i,]
      if(is.na(parsed[i]) || parsed[i]==-1)return(rep(NA,length(st)))
      substring(string[i],st,st+attr(parsed,"capture.length")[i,]-1)
    }))
  }
  result <- cbind(captured.text,captured.groups)
  colnames(result) <- c("",attr(parsed,"capture.names"))
  if(is.list(type.list)){
    df <- data.frame(result[,-1])
    for(col.name in names(type.list)){
      if(col.name %in% names(df)){
        type.fun <- type.list[[col.name]]
        df[[col.name]] <- type.fun(df[[col.name]])
      }
    }
    df
  }else{
    result
  }
}
