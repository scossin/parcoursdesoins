package query;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import exceptions.InvalidContextException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import ontologie.EIG;
import ontologie.Event;
import ontologie.EventOntology;
import parameters.MainResources;
import parameters.Util;
import query.XMLFile.DTDFiles;
import query.XMLFile.XMLelement;

/**
 * The describe event query return predicate and value of a particular event
 * @author cossin
 *
 */
public class XMLDescribeQuery implements Query {

	/**
	 * EventType
	 */
	private Event event ;
	/**
	 * The initial query is a XML file
	 */
	private XMLFile xml ;
	
	/**
	 * A list of predicate / value
	 */
	private HashMap<IRI,Value> predicatesValue = new HashMap<IRI,Value>();
		
	/**
	 * A string containing VALUES { value1 value2 ... valueN} where value1 ... valueN are eventInstances
	 */
	String eventValuesSPARQL;
	
	/**
	 * A string containing VALUES { value1 value2 ... valueN} where value1 ... valueN are predicatesInstances
	 */
	String predicatesValuesSPARQL;
	
	/**
	 * 
	 * @param xml
	 * @throws ParserConfigurationException
	 * @throws SAXException
	 * @throws IOException
	 * @throws UnfoundEventException
	 * @throws UnfoundPredicatException
	 * @throws InvalidContextException
	 */
	public XMLDescribeQuery (XMLFile xml) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, InvalidContextException{
		this.xml = xml;
		Node eventNode = xml.getEventNodes().item(0);
		this.event = EventOntology.getEvent(XMLFile.getEventType(eventNode));
		setEventValuesSPARQL(eventNode);
		setPredicatesValues(eventNode); 
		setpredicatesValuesSPARQL();
	}
	
	/**
	 * main function of the Query type : return a SPARQL query
	 */
	public String getSPARQLQueryString() {
		StringBuilder sb = new StringBuilder();
		sb.append("SELECT ?context ?event ?predicate ?value WHERE {graph ?context { \n ");
		sb.append(eventValuesSPARQL);
		sb.append(predicatesValuesSPARQL);
		sb.append("?event ?predicate ?value . \n");
		sb.append("}} \n");
		return(sb.toString());
	}
	
	/**
	 * List of predicates asked in the query and their expected value (datatype / object type) 
	 * @param eventNode
	 * @throws UnfoundPredicatException
	 */
	private void setPredicatesValues (Node eventNode) throws UnfoundPredicatException{
		Element element = (Element) eventNode;
		NodeList predicates = element.getElementsByTagName(XMLelement.predicateType.toString());
		Node predicate = predicates.item(0);
		String predicateNames[] = predicate.getTextContent().split("\t");
		for (String predicateName : predicateNames){
			predicatesValue.putAll(EventOntology.getOnePredicateValuePair(predicateName, event));
		}
	}
	
	/**
	 * Create a "VALUES" condition of predicates for the SPARQL query
	 * @throws UnfoundEventException
	 */
	
	private void setpredicatesValuesSPARQL() throws UnfoundEventException{
		Set<IRI> predicatesIRI = predicatesValue.keySet();
		StringBuilder sb = new StringBuilder();
		sb.append("VALUES ?predicate { ");
		for (IRI predicateIRI : predicatesIRI){
			sb.append(Query.formatIRI4query(predicateIRI));
		}
		sb.append("} .\n");
		this.predicatesValuesSPARQL = sb.toString();
	}
	
	/**
	 * Create a "VALUES" condition of events instances for the SPARQL query
	 * @param eventNode
	 * @throws UnfoundPredicatException
	 */
	private void setEventValuesSPARQL (Node eventNode) throws UnfoundPredicatException{
		Element element = (Element) eventNode;
		NodeList predicates = element.getElementsByTagName(XMLelement.value.toString());
		Node predicate = predicates.item(0);
		String predicateNames[] = predicate.getTextContent().split("\t");
		IRI[] eventsIRI = new IRI[predicateNames.length];
		for (int i = 0; i<predicateNames.length; i++){
			eventsIRI[i] = Util.vf.createIRI(EIG.NAMESPACE, predicateNames[i]);
		}
		
		StringBuilder sb = new StringBuilder();
		sb.append("VALUES ?event { ");
		for (IRI eventIRI : eventsIRI){
			sb.append(Query.formatIRI4query(eventIRI));
			sb.append(" ");
		}
		sb.append("} . \n");
		this.eventValuesSPARQL = sb.toString();
	}


	/**
	 * The list of variable for the XML describe query : 
	 * <ul>
	 * <li> ?context : the namedGraph specific to a patient
	 * <li> ?event : the event instance
	 * <li> ?predicate : the predicateIRI
	 * <li> ?value : datatype or object
	 * <ul>
	 */
	public String[] getVariableNames() {
		// TODO Auto-generated method stub
		String[] variablesNames = {"context","event","predicate","value"};
		return(variablesNames);
	}

	/**
	 * Get the context (namedGraphIRI) where to perform the query
	 */
	public SimpleDataset getContextDataset() {
		return xml.getContextDataSet();
	}
	
	
	public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, InvalidContextException{
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "testDescribe.xml" );
		XMLFile file = new XMLFile(xmlFile);
		XMLDescribeQuery describe = new XMLDescribeQuery(file);
		System.out.println(describe.getSPARQLQueryString());
	}
}
