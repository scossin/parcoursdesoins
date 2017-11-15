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

public class TimelineDescribeContext implements Query {
	final static Logger logger = LoggerFactory.getLogger(TimelineDescribeContext.class);
	
	private String sparqlQuery;
	
	private Terminology terminology;
	
	public TimelineDescribeContext(String contextName) throws RDFParseException, RepositoryException, IOException, InvalidContextException, UnfoundTerminologyException{
		this.terminology = TerminologyInstances.getTerminology(EIG.contextTerminologyName);
		setSparqlQueryTerminology(contextName);
	}
	
	private void setSparqlQueryTerminology(String contextName){
		IRI contextIRI = Util.vf.createIRI(EIG.NAMESPACE, contextName);
		String queryString = 
				"SELECT ?predicate ?object WHERE { \n" +
			     Query.formatIRI4query(contextIRI) + " ?predicate ?object " + ". \n " +
				"} \n " ;
		this.sparqlQuery = queryString ;
	}
	
	public String getSPARQLQueryString() {
		return(sparqlQuery);
	}

	public String[] getVariableNames() {
		String[] variablesNames = {"predicate","object"};
		return variablesNames;
	}

	public Endpoint getEndpoint() {
		return terminology.getEndpoint();
	}

	public Terminology getTerminology() {
		return terminology;
	}
	
	public SimpleDataset getContextDataset() {
		return(new SimpleDataset());
	}
	
	public static void main (String[] args) throws NumberFormatException, UnfoundEventException, UnfoundPredicatException, IncomparableValueException, UnfoundTerminologyException, OperatorException, InvalidContextException, InvalidXMLFormat, ParserConfigurationException, SAXException, IOException, ParseException, UnfoundResultVariable{
		Query query = new TimelineDescribeContext("p21");
		System.out.println(query.getSPARQLQueryString());
		System.out.println(query.getEndpoint().getDBnamespace());
		Results result = new Results(query.getEndpoint().getEndpointIPadress(),query);
		result.serializeResult();
	}
}

 
