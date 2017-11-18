docker stop webserverPMSI
docker stop BlazegraphDBpmsi 
docker rm BlazegraphDBpmsi 
docker rm webserverPMSI
docker rmi lyrasis/blazegraph:withTriplesPMSI 
docker commit pmsi lyrasis/blazegraph:withTriplesPMSI
docker run -d --name BlazegraphDBpmsi lyrasis/blazegraph:withTriplesPMSI
docker run -d -p 8080:8080 --name webserverPMSI --link BlazegraphDBpmsi:BlazegraphDBpmsi tomcat:latest 
docker exec -i webserverPMSI sh -c 'cat > webapps/parcoursdesoins-0.0.1.war' < ./target/parcoursdesoins-0.0.1.war
