package terminology;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.InvalidContextFormatException;
import exceptions.MyExceptions;
import exceptions.UnfoundTerminologyException;
import integration.DBconnection;
import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;
import query.Query;
import servlet.DockerDB;
import servlet.DockerDB.Endpoints;
import terminology.Terminology.TerminoEnum;

public class TerminologyServer {

	
	final static Logger logger = LoggerFactory.getLogger(TerminologyServer.class);
	
	private String sparlqEndpoint ;
	private DBconnection con ;
	
	public DBconnection getCon(){
		return(con);
	}
	
	public TerminologyServer(String sparlqEndpoint) throws Exception{
		con = new DBconnection(sparlqEndpoint);
		
		// test connection 
		String queryString = "ASK {?s ?p ?o}" ;
		try {
			logger.info("Trying to connect to " + sparlqEndpoint);
			con.getDBcon().prepareBooleanQuery(queryString).evaluate();
		} catch (Exception e) {
			MyExceptions.logException(logger, e);
			throw e;
		}
		logger.info("Connection successful");
	}
	

	
	public void countInstances(Set<IRI> classNames){
		logger.info("Counting number of instances in termologies...");
		for (IRI className : classNames){
			String query = countInstancesQuery(className);
			TupleQueryResult queryResult = con.getDBcon().prepareTupleQuery(query).evaluate();
			String count="0";
			if (queryResult.hasNext()){
				BindingSet set = queryResult.next();
				count = set.getValue("count").stringValue();
			}
			logger.info("\t" + className.stringValue() + ": " + count);
			try{
				queryResult.close();
			} catch (Exception e) {
				MyExceptions.logException(logger, e);
			}

		}
	}
	
	public void loadTerminology(TerminoEnum termino) throws Exception{
		String terminoFile = Terminology.terminologiesFolder + termino.getTermino().getFileName();
		String terminoNameSpace = termino.getTermino().getNAMESPACE();
		
		logger.info("Trying to load "+ terminoFile + "...");
		InputStream in = Util.classLoader.getResourceAsStream(terminoFile);
		try {
			con.getDBcon().add(in, terminoNameSpace, Util.DefaultRDFformat);
			logger.info("\t Successful");
		} catch (RDFParseException | RepositoryException | IOException e) {
			// TODO Auto-generated catch block
			MyExceptions.logException(logger, e);
			throw e;
		} finally{
			in.close();
		}
	}
	
	private String countInstancesQuery (IRI className){
		String queryString = "SELECT (count(distinct ?s) as ?count) WHERE {?s a " + 
				Query.formatIRI4query(className) + ". } \n";
		return(queryString);
	}
	
	private String getInstancesQuery(IRI className){
		String queryString = "SELECT ?s WHERE {?s a " + Query.formatIRI4query(className) + ". } \n";
		System.out.println(queryString);
		return(queryString);
	}
	
	public Set<IRI> getInstancesOfTerminology(TerminoEnum termino){
		Set<IRI> instancesIRI = new HashSet<IRI>();
		IRI className = termino.getTermino().getClassNameIRI();
		String query = getInstancesQuery(className);
		
		logger.info("Trying to get instances of "+ className.stringValue() + "...");
		
		TupleQueryResult queryResult = con.getDBcon().prepareTupleQuery(query).evaluate();
		while (queryResult.hasNext()){
			BindingSet set = queryResult.next();
			IRI instanceIRI = (IRI) set.getValue("s");
			instancesIRI.add(instanceIRI);
		}
		try{
			queryResult.close();
		} catch (Exception e) {
			MyExceptions.logException(logger, e);
		}
		
		logger.info("\t" + instancesIRI.size() + " instances retrieved");
		return instancesIRI;
	}
	
	public static HashMap<IRI, Set<IRI>> getInstancesOfTerminology() throws Exception{
		String sparqlEndpoint = DockerDB.getEndpointIPadress(Endpoints.TERMINOLOGIES);
		TerminologyServer terminoServer = new TerminologyServer(sparqlEndpoint);
		Set<IRI> classNames = Terminology.getClassNames();
		terminoServer.countInstances(classNames);
		
		HashMap<IRI, Set<IRI>> instancesOfTerminology = new HashMap<IRI, Set<IRI>>();
		for (TerminoEnum termino : TerminoEnum.values()){
			IRI className = termino.getTermino().getClassNameIRI();
			Set<IRI> instancesIRI = terminoServer.getInstancesOfTerminology(termino);
			instancesOfTerminology.put(className, instancesIRI);
		}
		terminoServer.countInstances(classNames);
		terminoServer.getCon().close();
		return(instancesOfTerminology);
	}
	
	public static void main (String[] args) throws Exception{
		
		String sparqlEndpoint = DockerDB.getEndpointIPadress(Endpoints.TERMINOLOGIES);
		
		TerminologyServer terminoServer = new TerminologyServer(sparqlEndpoint);
		
		Set<IRI> classNames = Terminology.getClassNames();
		
		terminoServer.countInstances(classNames);
		
		for (TerminoEnum termino : TerminoEnum.values()){
			terminoServer.loadTerminology(termino);
		}
		
		HashMap<IRI, Set<IRI>> instancesOfTerminology = new HashMap<IRI, Set<IRI>>();
		for (TerminoEnum termino : TerminoEnum.values()){
			IRI className = termino.getTermino().getClassNameIRI();
			Set<IRI> instancesIRI = terminoServer.getInstancesOfTerminology(termino);
			instancesOfTerminology.put(className, instancesIRI);
		}
		System.out.println("end");
		terminoServer.countInstances(classNames);
		terminoServer.getCon().close();
		

		
	}
	

	private String makeBooleanQuery (IRI instanceIRI, IRI classNameIRI){
		String query = Query.formatIRI4query(instanceIRI) + " a " + Query.formatIRI4query(classNameIRI);
		return(query);
	}
	

	
	public boolean isInstanceOfTerminology(String instanceName, IRI classNameIRI) throws UnfoundTerminologyException{
		
		
		IRI instanceIRI = Terminology.getTerminology(classNameIRI).makeInstanceIRI(instanceName);
	 
		String query = makeBooleanQuery(instanceIRI, classNameIRI);
		boolean answer = con.getDBcon().prepareBooleanQuery(query).evaluate();
		return(answer);
	}
}
