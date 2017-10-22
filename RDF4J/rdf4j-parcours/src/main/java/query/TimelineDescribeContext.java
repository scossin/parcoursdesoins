package query;

import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.vocabulary.RDF;
import org.eclipse.rdf4j.model.vocabulary.RDFS;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import exceptions.IncomparableValueException;
import exceptions.InvalidContextException;
import exceptions.InvalidXMLFormat;
import exceptions.MyExceptions;
import exceptions.OperatorException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundResultVariable;
import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;
import query.XMLFile.XMLelement;
import servlet.DockerDB;
import servlet.DockerDB.Endpoints;
import terminology.OneClass;
import terminology.Predicates;
import terminology.TerminoEnum;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class TimelineDescribeContext implements Query {
	final static Logger logger = LoggerFactory.getLogger(TimelineDescribeContext.class);
	
	private String sparqlQuery;
	
	private Terminology terminology;
	
	public TimelineDescribeContext(String contextName) throws RDFParseException, RepositoryException, IOException, InvalidContextException{
		this.terminology = TerminoEnum.CONTEXT.getTermino();
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

	public Endpoints getEndpoint() {
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
		System.out.println(query.getEndpoint().getURL());
		Results result = new Results(DockerDB.getEndpointIPadress(query.getEndpoint()),query);
		result.serializeResult();
	}
}

 
