package servlet;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import parameters.Project;

/**
 * https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/#environment-variables
 * @author cossin
 * 
 * 
 * sudo docker run -d --name BlazegraphDB lyrasis/blazegraph:2.1.4 
 * sudo docker run -it -p 8080:8080 --name webserver --link BlazegraphDB:BlazegraphDB tomcat:latest
 * sudo docker exec -it webserver /bin/sh
 * echo $BLAZEGRAPHDB_PORT
 * 
 */

public class Endpoint {

	final static Logger logger = LoggerFactory.getLogger(Endpoint.class);
	
	private final String dbNameSpace;
	
	public Endpoint(String dbNameSpace){
		this.dbNameSpace = dbNameSpace;
	}
	
	public String getDBnamespace(){
		return(dbNameSpace);
	}
	
	private static String getEnvValue() throws NullPointerException{
		// DB_PORT=tcp://172.17.0.5:5432
		String envName = Project.dbAlias.toUpperCase() + "_PORT"; // ENV variable are UpperCase
		String envValue = System.getenv(envName);
		if (envValue == null){
			String msg = "Environnement variable \"" + envName + "\" not found";
			logger.error(msg);
			throw new NullPointerException(msg);
		}
		return(envValue);
		
	}
	
	public String getEndpointIPadress() throws NullPointerException{
		String envValue = getEnvValue().replaceAll("^tcp", "http");
		envValue += getDBnamespace();
		return(envValue);
	}
}
