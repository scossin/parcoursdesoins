
library(httr)
test <- httr::POST( "http://localhost:9999/rdf4j-getting-started-0.0.1/HelloServlet", 
            body=list(filedata=upload_file("test.xml")))
test$url
test$status_code
test$request
test$handle
test$cookies
rawToChar(test$content)
?httr::POST
test$content

test <- httr::GET("http://localhost:8085/parcoursdesoins-0.0.1/HelloServlet")
rawToChar(test$content)

test <- httr::POST( "http://localhost:8085/parcoursdesoins-0.0.1/HelloServlet", 
                    body=list(filedata=upload_file("test.xml")))
