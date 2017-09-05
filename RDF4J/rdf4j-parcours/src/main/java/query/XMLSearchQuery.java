package query;

import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Value;
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
import exceptions.OperatorException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import ontologie.EventOntology;
import parameters.MainResources;
import parameters.Util;
import query.XMLFile.DTDFiles;
import query.XMLFile.XMLelement;
import servlet.DockerDB.Endpoints;


/**
 * A class to produce SPARQL query to search events and links between events. <br>
 * The XML file is handled by {@link XMLFile}. <br>
 * The events elements of the XML query are handled by {@link EventInXMLfile}
 * @author cossin
 *
 */
public class XMLSearchQuery implements Query {

	final static Logger logger = LoggerFactory.getLogger(XMLSearchQuery.class);
	
	/**
	 * Instance of XMLFile representing a user query in a XML file
	 */
	private XMLFile xml ;
	
	/**
	 * a list of binding statement. A bind statement create a new variable to compare 2 values
	 */
	private HashSet<String> bindStatements = new HashSet<String>();
	
	/**
	 * A list of filter statements for binding variables. (filter statements for event are in {@link EventInXMLfile} instances)
	 */
	private HashSet<String> filterStatements = new HashSet<String>();
	
	/**
	 * Add a new binding statement (ex : bind (?bindVariable as ?event1value - ?event2value))
	 * @param bindStatement
	 */
	private void addBindStatements(String bindStatement){
		bindStatements.add(bindStatement);
	}
	
	/**
	 * Add a filter statement (ex : FILTER (?bindVariable < 1))
	 * @param filterStatement
	 */
	private void addFilterStatements(String filterStatement){
		filterStatements.add(filterStatement);
	}
	
	/**
	 * Integer : the event number
	 * EventInXMLfile : a description of an Event (type, predicates ...), each one contains SPARQL statements for
	 * description and filtering
	 */
	private Map<Integer, EventInXMLfile> eventQuery = new HashMap<Integer, EventInXMLfile>();
	
	
	/******************************* getter **********************/
	public HashSet<String> getFilterStatements(){
		return(filterStatements);
	}
	
	public HashSet<String> getBindStatements(){
		return(bindStatements);
	}
	

	/**
	 * 
	 * @param xmlFile A user query XML file well formed and validated against a DTD file
	 * @throws ParserConfigurationException
	 * @throws SAXException
	 * @throws IOException
	 * @throws UnfoundEventException
	 * @throws UnfoundPredicatException
	 * @throws ParseException
	 * @throws NumberFormatException
	 * @throws IncomparableValueException
	 * @throws UnfoundTerminologyException
	 * @throws OperatorException 
	 * @throws InvalidContextException 
	 * @throws InvalidXMLFormat 
	 */
	public XMLSearchQuery(XMLFile xmlFile) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, ParseException, NumberFormatException, IncomparableValueException, UnfoundTerminologyException, OperatorException, InvalidContextException, InvalidXMLFormat{
		this.xml = xmlFile;
		// events element description in the XML :
		NodeList eventNodes = xml.getEventNodes();
		for (int i = 0 ; i<eventNodes.getLength() ; i++){
			Node eventNode = eventNodes.item(i);
			int numEvent = XMLFile.getEventNumber(eventNode);
			if (!eventQuery.containsKey(numEvent)){ // if event number doesn't exist : create a new instance
				eventQuery.put(numEvent, new EventInXMLfile(eventNode));
			} else { // if event number exists : add new predicates statements of this eventNode
				eventQuery.get(numEvent).setPredicatesStatement(eventNode); 
			}
		}
		
		// links between events in the XML : 
		NodeList linkNodes = xml.getLinkNodes();
		for (int i = 0 ; i<linkNodes.getLength() ; i++){
			Node linkNode = linkNodes.item(i);
			addLinkStatements(linkNode);
		}
	}
	
	/**
	 * Get WhereStatement from a list of {@link EventInXMLfile}
	 * @return a string of statements to put in the WHERE clause of a SPARQL query
	 */
	private String mergeWhereStatements (){
		String output= "";
		Iterator<EventInXMLfile> events = eventQuery.values().iterator();
		while(events.hasNext()){
			EventInXMLfile nextEventQuery = events.next();
			for (String statementWhere : nextEventQuery.getStatementsWhere()){
				output += statementWhere + "\n";
			}
		}
		return(output);
	}
	
	/**
	 * Get FilterStatement from a list of {@link EventInXMLfile}
	 * @return a string of statements to put in the FILTER clause of a SPARQL query (end of WHERE)
	 */
	private String mergeFilterStatements (){
		String output="";
		Iterator<EventInXMLfile> events = eventQuery.values().iterator();
		while(events.hasNext()){
			EventInXMLfile nextEventQuery = events.next();
			for (String statementWhere : nextEventQuery.getStatementsFilter()){
				output += statementWhere + "\n";
			}
		}
		return(output);
	}
	
	
	/**
	 * Add contraints/links between events
	 * @param linkNode A XML element describing links between events
	 * @throws NumberFormatException Wrong event numbers
	 * @throws UnfoundPredicatException If the predicate can't be found in the EventOntology
	 * @throws IncomparableValueException If the user try to compare incomparable datatypes
	 * @throws OperatorException 
	 */
	public void addLinkStatements(Node linkNode) throws NumberFormatException, UnfoundPredicatException, IncomparableValueException, OperatorException{
		Element element = (Element) linkNode;
		int eventNumber1 = 0;
		int eventNumber2 = 0;
		
		try {
			eventNumber1 = Integer.parseInt(element.getElementsByTagName(XMLelement.event1.toString())
					.item(0).getTextContent());
			eventNumber2 = Integer.parseInt(element.getElementsByTagName(XMLelement.event2.toString())
					.item(0).getTextContent());
		} catch (NumberFormatException e) {
			throw new NumberFormatException ("Event number are not integers");
		}
		
		// check predicate 1 : 
		String predicate1 = element.getElementsByTagName(XMLelement.predicate1.toString())
				.item(0).getTextContent();
		Map<IRI,Value> predicateValuesEvent1 = EventOntology.getOnePredicateValuePair(predicate1, 
				eventQuery.get(eventNumber1).getEvent());
		IRI predicate1IRI = predicateValuesEvent1.keySet().iterator().next(); // only one predicate
		IRI value1IRI = (IRI) predicateValuesEvent1.get(predicate1IRI); // expected value of predicate 1
		
		// check predicate 2 :
		String predicate2 = element.getElementsByTagName(XMLelement.predicate2.toString())
				.item(0).getTextContent();
		Map<IRI,Value> predicateValuesEvent2 = EventOntology.getOnePredicateValuePair(predicate2, 
				eventQuery.get(eventNumber2).getEvent());
		IRI predicate2IRI = predicateValuesEvent2.keySet().iterator().next(); // only one predicate
		IRI value2IRI = (IRI) predicateValuesEvent2.get(predicate2IRI); // expected value of predicate 2
		
		// check the comparison is possible between values
		if (!value1IRI.equals(value2IRI)){
			String msg = "can't compare " + value1IRI.stringValue() + 
					" and " + value2IRI.stringValue() + " values of " + predicate1 + " and " + 
					predicate2;
			throw new IncomparableValueException(logger, msg);
		}
		
		// For each event, declare the variable that will be compared in a filter statement 
		eventQuery.get(eventNumber1).addLinkStatement(predicate1IRI);
		eventQuery.get(eventNumber2).addLinkStatement(predicate2IRI);
		
		// Check the operator :
		String operatorName = element.getElementsByTagName(XMLelement.operator.toString())
				.item(0).getTextContent();
		if (!XMLFile.isRecognizedOperator(operatorName)){
			throw new OperatorException(logger, "Unknown operator \"" + operatorName + "\"");
		}
		
		// only difference of values is implemented now (date difference, numerical differences...)
		String variableName1 = eventQuery.get(eventNumber1).getVariableName(predicate1IRI.getLocalName()) ;
		String variableName2 = eventQuery.get(eventNumber2).getVariableName(predicate2IRI.getLocalName()) ;
		String minValue = element.getElementsByTagName(XMLelement.minValue.toString())
				.item(0).getTextContent();
		String maxValue = element.getElementsByTagName(XMLelement.maxValue.toString())
				.item(0).getTextContent();
		addDifferenceStatement(variableName1,variableName2,minValue,maxValue);
	}
	
	/**
	 * Add a constraint SPARQL statement : compare the difference between 2 event values and check it's greater than minValue and lower than maxValue
	 * @param variableName1 variable name of the first event
	 * @param variableName2 variable name of the second event
	 * @param minValue minimum value of the difference
	 * @param maxValue maximum value of the difference
	 * @throws IllegalArgumentException If min or max value is not set
	 */
	private void addDifferenceStatement (String variableName1, String variableName2, String minValue, String maxValue) throws IllegalArgumentException{
		// Name of the new comparisonVariable : ?diff + variableName2 + variableName1
		String comparisonVariable = "?diff" + variableName2.replaceAll("^[?]", "") + variableName1.replaceAll("^[?]", "");
		// variableName2 - variableName1
		String bindStatement = "bind ((" + variableName2 + " - " + variableName1 + ") as " + comparisonVariable + ")";
		String filterStatement = EventInXMLfile.getNumericFilter(comparisonVariable, minValue, maxValue);
		addBindStatements(bindStatement);
		addFilterStatements(filterStatement);
	}
	
	/**
	 * Variables of a search query are : 
	 * <ul>
	 * <li> ?context : the namedGraph specific to a patient
	 * <li> ?event0 : first event
	 * <li> ...
	 * <li> ?eventn : nth event
	 * </ul>
	 */
	public String[] getVariableNames() {
		ArrayList<String> eventNumber = new ArrayList<String>();
		eventNumber.add("context");
		for (int numberEvent : eventQuery.keySet()){
			eventNumber.add("event" + numberEvent);
		}
		return(eventNumber.toArray(new String[eventNumber.size()]));
	}
	
	/**
	 * main function of this class : return a SPARQL query String
	 * @return a SPARQL query string
	 */
	public String getSPARQLQueryString(){
		String queryString = "";
		
		   // Select Statements
		String part1 = "SELECT ?context ";
		
  	      // ?event0hasNum : the event number in the timeline
		for (int numberEvent : eventQuery.keySet()){
			part1 += "?event" + numberEvent + " "; // ?event0
			part1 += "?event" + numberEvent + EIG.HASNUM.getLocalName() + " "; 
		}
		queryString += part1 ; 
		
		// Where Statements
		String part2 = " WHERE {graph ?context { \n";
		part2 += mergeWhereStatements();
		
		// Bind variables :
		for(String statement : getBindStatements()){
			part2 += statement + "\n";
		}
		
		// Filter of events statement :
		part2 += mergeFilterStatements();
		
		// Filter of bind variables :
		for(String statement : getFilterStatements()){
			part2 += statement + "\n";
		}

		part2 += "}}\n";
		
		queryString += part2;
		
		
		// Order by : 
		queryString += "ORDER BY ?context ";
		
		// and numEvent : 
		for (int numberEvent : eventQuery.keySet()){
			queryString += "?event" + numberEvent + EIG.HASNUM.getLocalName() + " "; // ?event0hasNum : the event number in the timeline
		}
		
		return(queryString);
	}
	
	public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, ParseException, NumberFormatException, IncomparableValueException, UnfoundTerminologyException, OperatorException, InvalidContextException, InvalidXMLFormat {
		//QueryClass queryClass = new QueryClass(new File(Util.queryFolder+"queryMCOSSR3day.xml"));
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "queryMCOSSR3day.xml" );
		XMLSearchQuery queryClass = new XMLSearchQuery(new XMLFile(xmlFile));
		System.out.println(queryClass.getSPARQLQueryString());
	}

	@Override
	public SimpleDataset getContextDataset() {
		return(xml.getContextDataSet());
	}

	@Override
	public Endpoints getEndpoint() {
		return(Endpoints.TIMELINES);
	}
}
