package terminology;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.MyExceptions;
import exceptions.UnfoundTerminologyException;
import integration.DBconnection;
import parameters.Util;
import query.Query;
import servlet.DockerDB;
import terminology.Terminology.TerminoEnum;

public class TerminologyServer {

	
	final static Logger logger = LoggerFactory.getLogger(TerminologyServer.class);
	
	private DBconnection con ;
	
	public DBconnection getCon(){
		return(con);
	}
	
	private TerminoEnum termino ;
	
	
	public TerminologyServer(TerminoEnum termino) throws Exception{
		this.termino = termino;
		String sparqlEndpoint = DockerDB.getEndpointIPadress(termino.getTermino().getEndpoint());
		con = new DBconnection(sparqlEndpoint);
		
		// test connection 
		String queryString = "ASK {?s ?p ?o}" ;
		try {
			logger.info("Trying to connect to " + sparqlEndpoint);
			con.getDBcon().prepareBooleanQuery(queryString).evaluate();
		} catch (Exception e) {
			MyExceptions.logException(logger, e);
			throw e;
		}
		logger.info("Connection successful");
	}
	

	
	public void countInstances(){
		IRI classNameIRI = termino.getTermino().getClassNameIRI();
		logger.info("Counting number of instances of " + classNameIRI.stringValue());
		String query = countInstancesQuery(classNameIRI);
		TupleQueryResult queryResult = con.getDBcon().prepareTupleQuery(query).evaluate();
		String count="0";
		if (queryResult.hasNext()){
			BindingSet set = queryResult.next();
			count = set.getValue("count").stringValue();
		}
		logger.info("\t" + classNameIRI.stringValue() + ": " + count);
		try{
			queryResult.close();
		} catch (Exception e) {
			MyExceptions.logException(logger, e);
		}

	}
	
	public void loadTerminology() throws Exception{
		String terminoFile = Terminology.terminologiesFolder + termino.getTermino().getDataFileName();
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
	
	public Set<IRI> getInstancesOfTerminology(){
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
	
//	public static HashMap<IRI, Set<IRI>> getInstancesOfTerminology(TerminoEnum terminoEnum) throws Exception{
//		TerminologyServer terminoServer = new TerminologyServer(terminoEnum);
//		Set<IRI> classNames = Terminology.getClassNames();
//		terminoServer.countInstances(classNames);
//		
//		HashMap<IRI, Set<IRI>> instancesOfTerminology = new HashMap<IRI, Set<IRI>>();
//		for (TerminoEnum termino : TerminoEnum.values()){
//			IRI className = termino.getTermino().getClassNameIRI();
//			Set<IRI> instancesIRI = terminoServer.getInstancesOfTerminology(termino);
//			instancesOfTerminology.put(className, instancesIRI);
//		}
//		terminoServer.countInstances(classNames);
//		terminoServer.getCon().close();
//		return(instancesOfTerminology);
//	}
	
	public static void main (String[] args) throws Exception{
		
		Set<TerminoEnum> terminoToLoad = new HashSet<TerminoEnum>();
		//terminoToLoad.add(TerminoEnum.FINESS);
		//terminoToLoad.add(TerminoEnum.RPPS);
		terminoToLoad.add(TerminoEnum.CONTEXT);
		
		for (TerminoEnum termino : terminoToLoad){
			TerminologyServer terminoServer = new TerminologyServer(termino);
			terminoServer.loadTerminology();
			terminoServer.countInstances();
			terminoServer.getCon().close();
		}

//		for (TerminoEnum termino : TerminoEnum.values()){
//			terminoServer.loadTerminology(termino);
//		}
		
//		HashMap<IRI, Set<IRI>> instancesOfTerminology = new HashMap<IRI, Set<IRI>>();
//		for (TerminoEnum termino : TerminoEnum.values()){
//			IRI className = termino.getTermino().getClassNameIRI();
//			Set<IRI> instancesIRI = terminoServer.getInstancesOfTerminology(termino);
//			instancesOfTerminology.put(className, instancesIRI);
//		}
//		System.out.println("end");
//		terminoServer.countInstances(classNames);
//		terminoServer.getCon().close();
		

		
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
