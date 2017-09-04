package servlet;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


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
public class DockerDB {

	final static Logger logger = LoggerFactory.getLogger(DockerDB.class);
	
	public static final String dbName = "BlazegraphDB";
	public static final String dbAlias = "BlazegraphDB" ;
	
	public enum Endpoints {
		TIMELINES("/bigdata/namespace/timelines/sparql"),
		TERMINOLOGIES("/bigdata/namespace/terminologies/sparql"),
		ONTOLOGY("/bigdata/namespace/ontology/sparql"), 
		RPPS("/bigdata/namespace/RPPS/sparql"),
		FINESS("/bigdata/namespace/FINESS/sparql");
		
		private final String url;
		
		private Endpoints(String url){
			this.url = url;
		}
		
		public String getURL(){
			return(url);
		}
		
	}
	
	
	private static String getEnvValue() throws NullPointerException{
		// DB_PORT=tcp://172.17.0.5:5432
		String envName = dbAlias.toUpperCase() + "_PORT"; // ENV variable are UpperCase
		String envValue = System.getenv(envName);
		if (envValue == null){
			String msg = "Environnement variable \"" + envName + "\" not found";
			logger.error(msg);
			throw new NullPointerException(msg);
		}
		return(envValue);
		
	}
	
	public static String getEndpointIPadress(Endpoints endpoint) throws NullPointerException{
		String envValue = getEnvValue().replaceAll("^tcp", "http");
		envValue += endpoint.getURL();
		return(envValue);
	}
	
	public static String getEndpointIPadress(String IPadress, String port, Endpoints endpoint) throws NullPointerException{
		String envValue = IPadress + ":" + port;
		envValue += endpoint.getURL();
		return(envValue);
	}
	
	public static void main(String[] args){
		System.out.println(getEndpointIPadress(Endpoints.TIMELINES));
	}
}
