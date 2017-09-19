package query;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashSet;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import exceptions.InvalidContextException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import ontologie.TIME;
import parameters.MainResources;
import parameters.Util;
import query.XMLFile.XMLelement;
import servlet.DockerDB.Endpoints;
import terminology.Terminology;

/**
 * The describe event query return predicate and value of a particular event
 * @author cossin
 *
 */
public class XMLDescribeQuery implements Query {
	final static Logger logger = LoggerFactory.getLogger(XMLDescribeQuery.class);
	/**
	 * The initial query is a XML file
	 */
	private XMLFile xml ;
	
	/**
	 * A string containing VALUES { value1 value2 ... valueN} where value1 ... valueN are eventInstances
	 */
	private Set<IRI> eventValuesSPARQL = new HashSet<IRI>();
	
	/**
	 * A a set of IRI containing VALUES { value1 value2 ... valueN} where value1 ... valueN are predicatesInstances
	 */
	private Set<IRI> predicateValuesBasic = new HashSet<IRI>();
	
	/**
	 * A string containing VALUES { value1 value2 ... valueN} where value1 ... valueN are predicatesInstances of Time Ontology
	 */
	private Set<IRI> predicateValuesTime = new HashSet<IRI>();
	
	private Terminology terminology ;
	
	
	private final String eventReplacementString = "EVENTSINSTANCESgoHERE";
	private final String basicReplacementString = "PREDICATESgoHERE";
	private final String timeReplacementString = "PREDICATESTIMEvaluesGOhere";
	
	String startOfQuery = "SELECT * WHERE { \n " +
			"VALUES ?event {" +             eventReplacementString                           + "} \n"+
			"{";
	
	String basicQuery = "SELECT ?context ?event ?predicate ?value WHERE {graph ?context { \n"+
			"VALUES ?predicate {" +             basicReplacementString            +"} . \n" + 
			"?event ?predicate ?value . \n" + 
			"}}"
	;
	
	String timeOntologyQuery = "SELECT ?context ?event ?predicate ?value WHERE {graph ?context { \n" + 
			"VALUES ?predicate {"+            timeReplacementString            + "} . \n" + 
			"?event ?predicate ?startORend . \n"+
			"?startORend a "+ Query.formatIRI4query(TIME.INSTANT) + " . \n" + 
			"?startORend "+ Query.formatIRI4query(TIME.INXSDDATETIME) + " ?value . \n"+
			"}}";
	;
	
	
	/**
	 * 
	 * @param xml
	 * @throws ParserConfigurationException
	 * @throws SAXException
	 * @throws IOException
	 * @throws UnfoundEventException
	 * @throws UnfoundPredicatException
	 * @throws InvalidContextException
	 * @throws UnfoundTerminologyException 
	 */
	public XMLDescribeQuery (XMLFile xml) throws ParserConfigurationException, SAXException, IOException, UnfoundPredicatException, InvalidContextException, UnfoundTerminologyException{
		this.xml = xml;
		Node eventNode = xml.getEventNodes().item(0);
		this.terminology = xml.getTerminology(eventNode);
		setEventValuesSPARQL(eventNode);
		setPredicatesValues(eventNode);
		replacePredicatesValues();
	}
	
	/**
	 * main function of the Query type : return a SPARQL query
	 */
	public String getSPARQLQueryString() {
		StringBuilder sb = new StringBuilder();
		sb.append(startOfQuery);
		sb.append(basicQuery);
		sb.append("} UNION { \n");
		sb.append(timeOntologyQuery);
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
			if (TIME.isRecognizedTimePredicate(predicateName)){
				predicateValuesTime.add(Util.vf.createIRI(TIME.NAMESPACE, predicateName));
			} else {
				predicateValuesBasic.add(Util.vf.createIRI(EIG.NAMESPACE, predicateName));
			}
		}
	}
	
	private void replacePredicatesValues(){
		// basic : 
		StringBuilder sb = new StringBuilder();
		sb.append(" ");
		for (IRI predicateIRI : predicateValuesBasic){
			sb.append(Query.formatIRI4query(predicateIRI));
			sb.append(" ");
		}
		this.basicQuery = basicQuery.replace(basicReplacementString, sb.toString());
		
		// time : 
		sb.setLength(0);
		sb.append(" ");
		for (IRI predicateIRI : predicateValuesTime){
			sb.append(Query.formatIRI4query(predicateIRI));
			sb.append(" ");
		}
		this.timeOntologyQuery = timeOntologyQuery.replace(timeReplacementString, sb.toString());
		
		// events : 
		sb.setLength(0);
		sb.append(" ");
		for (IRI predicateIRI : eventValuesSPARQL){
			sb.append(Query.formatIRI4query(predicateIRI));
			sb.append(" ");
		}
		this.startOfQuery = startOfQuery.replace(eventReplacementString, sb.toString());
	}
	
	/*
	 * Create a "VALUES" condition of predicates for the SPARQL query
	 * @throws UnfoundEventException
	
	
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
	 */
	
	/**
	 * Create a "VALUES" condition of events instances for the SPARQL query
	 * @param eventNode
	 * @throws UnfoundPredicatException
	 */
	private void setEventValuesSPARQL (Node eventNode) throws UnfoundPredicatException{
		Element element = (Element) eventNode;
		NodeList eventInstance = element.getElementsByTagName(XMLelement.value.toString());
		Node eventInstances = eventInstance.item(0);
		String eventInstancesNames[] = eventInstances.getTextContent().split("\t");
		for (String eventInstanceName : eventInstancesNames){
			eventValuesSPARQL.add(Util.vf.createIRI(EIG.NAMESPACE, eventInstanceName));
		}
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
	
	
	public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, InvalidContextException, UnfoundTerminologyException{
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "describeMCO.xml" );
		XMLFile file = new XMLFile(xmlFile);
		XMLDescribeQuery describe = new XMLDescribeQuery(file);
		System.out.println(describe.getSPARQLQueryString());
		xmlFile.close();
	}

	@Override
	public Endpoints getEndpoint() {
		return terminology.getEndpoint();
	}

	@Override
	public Terminology getTerminology() {
		return terminology;
	}
}
