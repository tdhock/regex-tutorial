## copied from https://r-forge.r-project.org/scm/viewvc.php/tex/2011-06-09-ibl/rforge-download.R?view=markup&revision=402&root=inlinedocs

## The point of this script is to read the current state of R-Forge as
## saved in the csv files, then hit the R-Forge website as few times
## as possible to download info about new projects. NOTE: people can
## leave/join existing projects, which may make the project.users.csv
## table invalid!
project.stats <- read.csv("project.stats.csv",header=TRUE,
                          colClasses=c("POSIXct","factor","integer"))
users <- read.csv("project.users.csv",header=TRUE,
                  colClasses=c("factor","factor"))
home <- readLines(home.conn <- url("http://r-forge.r-project.org/"))
close(home.conn)
lines.after.recently <- paste(home[-(1:grep("Recently",home))],collapse="")
most.recent.project <- paste(namedCapture::str_match_variable(
  lines.after.recently,
  "projects/",
  project="[^/]+"))
## now download the most recent project page to get its project id
download.project.html <- function(project){
  project.url.format <- "http://r-forge.r-project.org/projects/%s/"
  project.url <- sprintf(project.url.format,project)
  conn <- url(project.url)
  html <- paste(readLines(conn),collapse="")
  close(conn)
  html
}
## extract the project registration datetime
get.registration <- function(html){
  parsed <- get.first(html,
    'Registered: <span property=\"doap:created\" content=\"[-0-9]+\">',
                      "[^<]+")
  as.POSIXct(strptime(parsed,"%Y-%m-%d %H:%M"))
}
### lookup a project name from id by looking at the scm page
get.project.from.id <- function(project.id){
  scm.url <- sprintf("http://r-forge.r-project.org/scm/?group_id=%d",project.id)
  print(scm.url)
  scm.html <- tryCatch({
    conn <- url(scm.url)
    html <- paste(readLines(conn),collapse="")
    close(conn)
    html
  },error=function(e)"")
  get.first(scm.html,"svnroot/","[^</]+")
### project name or "" if we couldn't do the lookup.
}

## to parse user info off the project page we need this function
get.user.ids <- function(html){
  user.pattern <- "org/users/(?<id>[^/]+)/\">(?<name>[^<]+)"
  str_match_all_perl(paste(html,collapse=""),user.pattern)[[1]][,"id"]
}
project.html <- download.project.html(most.recent.project)
most.recent.project.id <-
  as.integer(get.first(project.html,"group_id=","[0-9]+"))
sorted.projects <- project.stats[order(project.stats$id),]
last.id <- tail(sorted.projects,1)$id
if(most.recent.project.id>last.id){
  register.datetime <- get.registration(project.html)
  ## collect the data into a data.frame
  new.stats <- data.frame(registered=register.datetime,
                          project=most.recent.project,
                          id=most.recent.project.id,
                          row.names=NULL)
  project.stats <- rbind(project.stats,new.stats)
  ## collect the users info from the most recent project page
  user <- get.user.ids(project.html)
  new.users <- data.frame(user,project=most.recent.project,row.names=NULL)
  users <- rbind(users,new.users)

  ## first, lookup all ids from 1 to the most recent, and if the id is
  ## not in the project.stats table, lookup the project name.
  for(project.id in last.id:most.recent.project.id){
    print(project.id)
    if(!project.id%in%project.stats$id){
      project <- get.project.from.id(project.id)
      if(project!=""){
        newline <- data.frame(registered=NA,
                              project,
                              id=project.id,
                              row.names=NULL)
        print(newline)
        project.stats <- rbind(project.stats,newline)
      }
    }
  }

  ## then, lookup all projects with missing registration info
  for(project in with(project.stats,project[is.na(registered)])){
    print(project)
    project.html <- download.project.html(project)
    registered <- get.registration(project.html)
    print(registered)
    project.stats[project.stats$project==project,"registered"] <- registered
    user <- get.user.ids(project.html)
    if(length(user)){
      newlines <- data.frame(user,project,row.names=NULL)
      print(newlines)
      users <- rbind(users,newlines)
    }
  }
}
sorted.projects <- project.stats[order(project.stats$id),]

## Some projects still have NA registration timestamps, because their
## registration time is not listed on the R-Forge project page,
## e.g. https://r-forge.r-project.org/projects/texreg/ In those cases
## I just manually edited the project.stats.csv file, giving a
## registration time that is between the previous and next project
## ids. These registration times are the only ones that end with
## 00:00:00 so you can search for them if necessary.
sum(is.na(sorted.projects$registered))

write.csv(sorted.projects,"project.stats.csv",row.names=FALSE,quote=FALSE)

write.csv(users,"project.users.csv",row.names=FALSE,quote=FALSE)
