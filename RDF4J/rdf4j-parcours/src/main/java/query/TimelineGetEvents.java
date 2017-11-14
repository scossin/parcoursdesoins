package query;

import java.io.IOException;
import java.text.ParseException;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import exceptions.IncomparableValueException;
import exceptions.InvalidContextException;
import exceptions.InvalidXMLFormat;
import exceptions.OperatorException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundResultVariable;
import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import parameters.Util;
import servlet.Endpoint;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class TimelineGetEvents implements Query {
	final static Logger logger = LoggerFactory.getLogger(TimelineGetEvents.class);
	
	private String sparqlQuery;
	
	private Terminology terminology;
	
	private SimpleDataset contextDataset = new SimpleDataset();
	
	public TimelineGetEvents(String contextName) throws RDFParseException, RepositoryException, IOException, InvalidContextException, UnfoundTerminologyException{
		this.terminology = TerminologyInstances.getTerminology(EIG.TerminologyName);
		setSparqlQueryTerminology();
		setContextDataSet(contextName);
	}
	
	private void setSparqlQueryTerminology(){
		IRI eventIRI = Util.vf.createIRI(EIG.NAMESPACE, EIG.eventClassName);
		String queryString = 
				"SELECT ?event ?eventType ?beginningDate ?endingDate WHERE { GRAPH ?g { \n" +
				"?event a " +  Query.formatIRI4query(eventIRI) + ". \n " + 
			    "?event " + Query.formatIRI4query(EIG.HASTYPE) + " ?eventType" + ". \n " + 
			    "?event " + Query.formatIRI4query(EIG.HASBEGINNING) + " ?beginningDate " + ". \n " +
			    "?event " + Query.formatIRI4query(EIG.HASEND) + " ?endingDate " + ". \n " +
				"}} \n " ;
		this.sparqlQuery = queryString ;
	}
	
	public String getSPARQLQueryString() {
		return(sparqlQuery);
	}

	private void setContextDataSet(String contextName) throws InvalidContextException {
		logger.info("setting dataset...");
		SimpleDataset dataset = new SimpleDataset();
		IRI contextIRI = EIG.getContextIRI(contextName);
		dataset.addNamedGraph(contextIRI);
		this.contextDataset = dataset;
	}
	
	public String[] getVariableNames() {
		String[] variablesNames = {"event","eventType","beginningDate","endingDate"};
		return variablesNames;
	}

	public Endpoint getEndpoint() {
		return terminology.getEndpoint();
	}

	public Terminology getTerminology() {
		return terminology;
	}
	
	public SimpleDataset getContextDataset() {
		return(contextDataset);
	}
	
	public static void main (String[] args) throws NumberFormatException, UnfoundEventException, UnfoundPredicatException, IncomparableValueException, UnfoundTerminologyException, OperatorException, InvalidContextException, InvalidXMLFormat, ParserConfigurationException, SAXException, IOException, ParseException, UnfoundResultVariable{
	
		Query query = new TimelineGetEvents("p21");
		System.out.println(query.getSPARQLQueryString());
		System.out.println(query.getEndpoint().getDBnamespace());
		Results result = new Results(query.getEndpoint().getEndpointIPadress(),query);
		result.serializeResult();
	}
}

 
