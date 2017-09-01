STATIClogger <- R6::R6Class(
  "STATIClogger",
  
  public=list(
    conFileLog = NULL,
    
    initialize = function(){
      cat("creating a new StaticLogger")
      bool <- dir.exists(GLOBALlogFolder)
      if (!bool){
        stop("Please create a ./logs repository to save logs")
      }
      # fileNameError <- "/tmp/error.txt"
      # file.create(fileNameError)
      # fileCon <- file(fileNameError)
      
      fileName <- private$getLogFileName()
      file.create(fileName)
      tryCatch(
        self$conFileLog <- file(fileName,open="a")
      , error = function(e) print("Can't open a connection"))
      
      sink(self$conFileLog)
      sink(self$conFileLog, type="message")
      sink()
    },
    
    close = function(){
      for(i in seq_len(sink.number(type="message"))){
        sink(type="message")
      }
      
      tryCatch({
        self$info("Trying to close connection")
        close.connection(self$conFileLog)
      }, error = function(e) print("Error trying to close connection"))
     
    },
    
    info = function(...){
      msg <- NULL
      msg <- append(msg, "INFO - ")
      msg <- append(msg, private$getDate())
      args <- list(...)
      private$writeMsg(msg,args)
    },
    
    user = function(...){
      msg <- NULL
      msg <- append(msg, "USERINPUT - ")
      msg <- append(msg, private$getDate())
      args <- list(...)
      private$writeMsg(msg,args)
    },
    
    error = function(...){
      msg <- NULL
      msg <- append(msg, "ERROR - ")
      msg <- append(msg, private$getDate())

      args <- list(...)
      private$writeMsg(msg,args)
    }
    
  ),
  
  private = list(
    getLogFileName = function(){
      date <- private$getDate()
      randomNumber <- sample(1:10000, size=1) ## in case 2 users connects at the same second !
      fileName <- paste0(date, randomNumber, ".txt")
      fileName <- paste0(GLOBALlogFolder, fileName)
    },
    
    getDate = function(){
      return(format(Sys.time(), "%Y-%m-%d-%H-%M-%S"))
    },
    
    writeMsg = function(msg, args){
      msg <- append(msg, " : ")
      for(arg in args){
        if (is.factor(arg) || is.numeric(arg)){
          arg <- as.character(arg)
        }
        if (is.character(arg)){
          if (length(arg) == 1){
            msg <- append(msg, arg)
            msg <- append(msg," ")
          } else {
            arg <- paste(arg, collapse="-")
            arg <- paste0("(",arg,")")
            msg <- append(msg, arg)
            msg <- append(msg," ")
          }
        } else { ## if not character nor vector
          msg <- append(msg,"LoggerWarning : arguments not character nor vector")
        }
      }
      
      cat(msg,"\n")
      msg <- paste0(msg,collapse = "")
      write(msg,self$conFileLog)
    }
  )
)


# tryCatch(
#   write(msg,self$conFileLog)
# , error = function(e, msg) {
#   print(msg)
#   print("Can't write AAAAAAA to the file")
#   e})