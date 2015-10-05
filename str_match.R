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
  captured.groups <- do.call(rbind,lapply(seq_along(string),function(i){
    st <- attr(parsed,"capture.start")[i,]
    if(is.na(parsed[i]) || parsed[i]==-1)return(rep(NA,length(st)))
    substring(string[i],st,st+attr(parsed,"capture.length")[i,]-1)
  }))
  result <- cbind(captured.text,captured.groups)
  colnames(result) <- c("",attr(parsed,"capture.names"))
  apply_type_funs(result, type.list)
}

## Parse several occurances of pattern from each of several strings
## using (named) capturing regular expressions, returning a list of
## matrices (with column names).
str_match_all_perl <- function(string,pattern, type.list=NULL){
  stopifnot(is.character(string))
  stopifnot(is.character(pattern))
  stopifnot(length(pattern)==1)
  parsed <- gregexpr(pattern,string,perl=TRUE)
  lapply(seq_along(parsed),function(i){
    r <- parsed[[i]]
    full <- substring(string[i],r,r+attr(r,"match.length")-1)
    names <- attr(r,"capture.names")
    if(r[1]==-1 || is.null(names)){
      m <- matrix(character(), nrow=0)
    }else{
      starts <- attr(r,"capture.start")
      lengths <- attr(r,"capture.length")
      subs <- substring(string[i],starts,starts+lengths-1)
      m <- matrix(c(full,subs),ncol=length(names)+1)
      colnames(m) <- c("",names)
    }
    apply_type_funs(m, type.list)
  })
}

### Convert columns of match.mat using corresponding functions from
### type.list.
apply_type_funs <- function(match.mat, type.list){
  if(is.list(type.list)){
    df <- data.frame(match.mat[, -1, drop=FALSE])
    for(col.name in names(type.list)){
      if(col.name %in% names(df)){
        type.fun <- type.list[[col.name]]
        df[[col.name]] <- type.fun(df[[col.name]])
      }
    }
    df
  }else{
    match.mat
  }
}
