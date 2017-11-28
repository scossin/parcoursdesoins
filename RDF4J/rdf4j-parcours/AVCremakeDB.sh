docker stop webserver
docker stop BlazegraphDB
docker rm BlazegraphDB 
docker rm webserver
docker rmi lyrasis/blazegraph:withTriples
docker commit blazegraph lyrasis/blazegraph:withTriples
docker run -d --name BlazegraphDB lyrasis/blazegraph:withTriples
docker run -d -p 8080:8080 --name webserver --link BlazegraphDB:BlazegraphDB tomcat:latest 
docker exec -i webserver sh -c 'cat > webapps/parcoursdesoins-0.0.1.war' < ./target/parcoursdesoins-0.0.1.war
