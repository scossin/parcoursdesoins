package query;

import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.vocabulary.RDF;
import org.eclipse.rdf4j.model.vocabulary.RDFS;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
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

public class XMLCountQuery implements Query {
	final static Logger logger = LoggerFactory.getLogger(XMLCountQuery.class);
	
	private XMLFile xml;
	
	private String sparqlQuery;
	
	private Terminology terminology;
	
	private OneClass oneClass;
	
	private IRI predicateIRI;
	
	public XMLCountQuery(XMLFile xml) throws UnfoundTerminologyException, UnfoundEventException, UnfoundPredicatException, ParserConfigurationException{
		this.xml = xml;
		Node eventNode = xml.getEventNodes().item(0);
		this.terminology = XMLFile.getTerminology(eventNode);
		String eventType = XMLFile.getEventType(eventNode);
		oneClass = terminology.getClassDescription().getClass(eventType);
		setPredicateIRI(eventNode);
		if (getEndpoint() == Endpoints.TIMELINES){
			setSparqlQueryContext();
		} else {
			setSparqlQueryTerminology();
		}
	}
	
	private void setPredicateIRI (Node eventNode) throws UnfoundPredicatException, ParserConfigurationException, UnfoundEventException{
		Element element = (Element) eventNode;
		NodeList predicates = element.getElementsByTagName(XMLelement.predicateType.toString());
		Node predicateNode = predicates.item(0);
		String predicateNames[] = predicateNode.getTextContent().split("\t");
		if (predicateNames.length != 1){
			MyExceptions.logMessage(logger, "predicate of a Count query must be length one. Given : ");
			for (String predicateName : predicateNames){
				MyExceptions.logMessage(logger, "\t " + predicateName);
			}
			throw new ParserConfigurationException();
		}
		String predicateName = predicateNames[0];
		Predicates predicate = terminology.getOnePredicate(predicateName, oneClass);
		this.predicateIRI = predicate.getPredicateIRI();
	}
	
	private void setSparqlQueryContext(){
		String queryString = "SELECT ?className (count(?className) as ?count) WHERE { GRAPH ?context { \n"+
				"?event "+  Query.formatIRI4query(predicateIRI) + " ?className . \n " +
				//"?event " + Query.formatIRI4query(RDF.TYPE) + " " +  Query.formatIRI4query(oneClass.getClassIRI()) + 
				"}} \n " + 
				"group by ?className \n" ;
		this.sparqlQuery = queryString ;
	}
	
	private void setSparqlQueryTerminology(){
		String queryString = "SELECT ?className (count(?className) as ?count) WHERE { \n"+
				"?event "+  Query.formatIRI4query(predicateIRI) + " ?className . \n " +
				//"?event " + Query.formatIRI4query(RDF.TYPE) + " " + Query.formatIRI4query(oneClass.getClassIRI()) + 
				"} \n " + 
				"group by ?className \n" ;
		this.sparqlQuery = queryString ;
	}
	
	public String getSPARQLQueryString() {
		return(sparqlQuery);
	}

	public String[] getVariableNames() {
		String[] variablesNames = {"className","count"};
		return variablesNames;
	}

	public Endpoints getEndpoint() {
		return terminology.getEndpoint();
	}

	public Terminology getTerminology() {
		return terminology;
	}
	
	public SimpleDataset getContextDataset() {
		return(xml.getContextDataSet());
	}
	
	public static void main (String[] args) throws NumberFormatException, UnfoundEventException, UnfoundPredicatException, IncomparableValueException, UnfoundTerminologyException, OperatorException, InvalidContextException, InvalidXMLFormat, ParserConfigurationException, SAXException, IOException, ParseException, UnfoundResultVariable{
		//QueryClass queryClass = new QueryClass(new File(Util.queryFolder+"queryMCOSSR3day.xml"));
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "countQueryNew.xml" );
		XMLFile xml = new XMLFile(xmlFile);
		Query query = new XMLCountQuery(xml);
		System.out.println(query.getSPARQLQueryString());
		System.out.println(xml.getContextDataSet().hashCode());
		System.out.println(query.getEndpoint().getURL());
		Results result = new Results(DockerDB.getEndpointIPadress(query.getEndpoint()),query);
		result.serializeResult();
	}
}

/**
// * SELECT ?eventType ?p (count(?p) as ?count) ?comment WHERE { 
//  ?s a ?eventType .
//  ?s ?p ?o .
//SERVICE <http://127.0.0.1:8080/bigdata/namespace/ontology/sparql> { 
//?p rdfs:comment ?comment .
//FILTER(regex(str(?p), "http://www.eigsante2017.fr#"))
//}}
//GROUP BY ?eventType ?p ?comment
 */
 
