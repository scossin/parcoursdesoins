
args <- (commandArgs(TRUE))
if (length(args) == 0){
  stop("no argument given")
}
if (length(args) > 1){
  stop("more than one argument given")
}

pattern <- args[length(args)]

allFiles <- list.files(path = ".", recursive = T)
bool <- grepl(pattern = ".R$",allFiles)
allFiles <- allFiles[bool]
bool <- allFiles == "search.R"
allFiles <- allFiles[!bool]
#pattern <- "finalize"
options(warn=-1)
library(crayon)
for (file in allFiles){
  reading <- readLines(file)
  bool <- grep(pattern = pattern,reading)
  if (length(bool)!=0){
    for (line in bool){
      cat(green(file, " line:", as.character(line),"\t",reading[line], "\n"))
    }
  }
}