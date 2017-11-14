### webserver is the name of the docker :
### sudo docker run -it -p 3838:3838 --name shinyV5 --link webserver:webserver shiny:parcoursV5
## previous command means : make a link between shinyV5 container and webserver
## inside shinyV5 container, we have env variables with link to webserver container
## we get the URL of the container by this WEBSERVER_PORT env variable

## the other solution is to put the webserver container on a server and pass the URL directly here
## the shiny apps is local

## parameters : 
webserverENV = "WEBSERVERPMSI_PORT"
webapp <- "/parcoursdesoins-0.0.1/"


args <- (commandArgs(TRUE))
if (length(args) == 0){
  folder <- NULL
} else {
  folder <- args[1]
}


envVariables <- Sys.getenv()                                                                    
bool <- names(envVariables) == webserverENV
if (!any(bool)){
  msg <- "No WEBSERVER_PORT env variable found, 
                           is the shiny apps running inside a docker container 
                           and linked to another container named webserver ?"
  stop(msg)
}
httpAdress <- as.character(envVariables[bool])                                                  
httpAdress <- gsub("^tcp","http",httpAdress)
webserverURL <- paste0(httpAdress, webapp)

GLOBALurlserver <- webserverURL
path <- paste0(folder,"GLOBALurlserver.rdata")
GLOBALurlserver <- save(GLOBALurlserver, 
                        file=path)
