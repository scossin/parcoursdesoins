STATICqueriesList <- R6::R6Class(
  "STATICqueriesList",
  
  public = list(
    
    fileName = character(),
    queriesDf = data.frame(),
    
    initialize = function(){
      self$fileName <- paste0(GLOBALqueriesFolder, GLOBALqueriesListFile)
      if (!file.exists(self$fileName)){
        stop("Unfound file : " + self$fileName)
      }
      self$queriesDf <- read.table(self$fileName,sep="\t",header=T)
      bool <- colnames(self$queriesDf) %in% c("file","lib")
      if (!all(bool)){
        stop("unexpected columns in ", fileName)
      }
      self$checkFile()
    },
    
    getLibQueries = function (){
      return(as.character(self$queriesDf$lib))
    },
    
    deleteQuery = function(libQuery){
      bool <- self$queriesDf$lib %in% libQuery
      if (!any(bool)){
        warning("deleteQuery : unfound ", libQuery)
        return(NULL);
      }
      fileQuery <- as.character(self$queriesDf$file[bool])
      file.remove(fileQuery)
      self$queriesDf <- subset (self$queriesDf, !bool)
      self$writeQueriesDf()
    },
    
    getXMLsearchQuery = function (libQuery){
      staticLogger$info("Getting xmlSearchQuery from libQuery : ", libQuery)
      bool <- self$queriesDf$lib %in% libQuery
      if (!any(bool)){
        stop("unfound libQuery:", libQuery)
      }
      sub <- subset (self$queriesDf, bool)
      if (nrow(sub) != 1){ ## same label multiple times
        sub <- sub[1,]
      }
      fileQueryName <- as.character(sub$file)
      staticLogger$info("\t loading query : ", fileQueryName)
      xmlQueryName <- load (fileQueryName)
      load(fileQueryName)
      return(get(xmlQueryName))
    },
    
    checkFile = function(){
      files <- list.files(GLOBALqueriesFolder,full.names = T)
      files <- gsub("//","/",files)
      bool <- as.character(self$queriesDf$file) %in% files
      if (any(!bool)){
        self$queriesDf <- subset (self$queriesDf, bool)
        self$writeQueriesDf()
      }
    },

    saveQuery = function(xmlSearchQuery, libQuery){
      files <- list.files(GLOBALqueriesFolder)
      bool <- grepl("queries[0-9]+.rdata$",files)
      files <- files[bool]
      if (length(files) == 0){
        num <- 1
      } else {
        nums <- stringr::str_extract(files,pattern = "[0-9]+")
        num <- max(as.numeric(nums)) + 1
      }
      fileQueryName <- paste0(GLOBALqueriesFolder, "queries",num,".rdata")
      save(file = fileQueryName, xmlSearchQuery)
      
      ajout <- data.frame(file = fileQueryName, lib = libQuery)
      self$queriesDf <- rbind(self$queriesDf, ajout)
      self$writeQueriesDf()
    },
    
    writeQueriesDf = function(){
      write.table(self$queriesDf,file = self$fileName, sep="\t", col.names = T, 
                  row.names = F, quote=F)
    }
    
  ),
  
  private = list(
    
  )
)
