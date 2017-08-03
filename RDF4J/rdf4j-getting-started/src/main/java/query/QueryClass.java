package query;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Value;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import exceptions.IncomparableValueException;
import exceptions.InvalidXMLFormat;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import integration.Util;
import ontologie.EventOntology;
import query.XMLquery.XMLelement;

public class QueryClass {

	
	private XMLquery xml ;
	
	public XMLquery getXMLquery(){
		return(xml);
	}
	
	private HashSet<String> bindStatements = new HashSet<String>();
	private HashSet<String> filterStatements = new HashSet<String>();
	
	private void addBindStatements(String bindStatement){
		bindStatements.add(bindStatement);
	}
	
	private void addFilterStatements(String filterStatement){
		filterStatements.add(filterStatement);
	}
	
	public HashSet<String> getFilterStatements(){
		return(filterStatements);
	}
	
	public HashSet<String> getBindStatements(){
		return(bindStatements);
	}
	
	private Map<Integer, EventQuery> eventQuery = new HashMap<Integer, EventQuery>();
	
	public String mergeStatementWhere (){
		String output="";
		Iterator<EventQuery> events = eventQuery.values().iterator();
		while(events.hasNext()){
			EventQuery nextEventQuery = events.next();
			for (String statementWhere : nextEventQuery.getStatementsWhere()){
				output += statementWhere + "\n";
			}
		}
		
		
		return(output);
	}
	
	public String mergeStatementFilter (){
		String output="";
		Iterator<EventQuery> events = eventQuery.values().iterator();
		while(events.hasNext()){
			EventQuery nextEventQuery = events.next();
			for (String statementWhere : nextEventQuery.getStatementsFilter()){
				output += statementWhere + "\n";
			}
		}
		return(output);
	}
	
	public QueryClass(File xmlFile) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, ParseException, NumberFormatException, IncomparableValueException{
		xml = new XMLquery(xmlFile);
		NodeList nList = xml.getEventNodes();
		for (int i = 0 ; i<nList.getLength() ; i++){
			Node eventNode = nList.item(i);
			int numEvent = XMLquery.getEventNumber(eventNode);
			if (!eventQuery.containsKey(numEvent)){
				eventQuery.put(numEvent, new EventQuery(eventNode));
			} else {
				eventQuery.get(numEvent).updateEventQuery(eventNode);
			}
		}
		
		nList = xml.getLinkNodes();
		for (int i = 0 ; i<nList.getLength() ; i++){
			Node linkNode = nList.item(i);
			makeSomething(linkNode);
		}
	}
	
	public void makeSomething(Node linkNode) throws NumberFormatException, UnfoundPredicatException, IncomparableValueException{
		Element element = (Element) linkNode;
		int eventNumber1 = 0;
		int eventNumber2 = 0;
		
		try {
		eventNumber1 = Integer.parseInt(element.getElementsByTagName(XMLelement.event1.toString())
				.item(0).getTextContent());
		eventNumber2 = Integer.parseInt(element.getElementsByTagName(XMLelement.event2.toString())
				.item(0).getTextContent());
		} catch (NumberFormatException e) {
			throw new NumberFormatException ("Non integer event number given");
		}
		
		// check predicate 1 : 
		String predicate1 = element.getElementsByTagName(XMLelement.predicate1.toString())
				.item(0).getTextContent();
		Map<IRI,Value> predicateValuesEvent1 = EventOntology.getOnePredicateValuePair(predicate1, 
				eventQuery.get(eventNumber1).getEvent());
		IRI predicate1IRI = predicateValuesEvent1.keySet().iterator().next();
		IRI value1IRI = (IRI) predicateValuesEvent1.get(predicate1IRI);
		
		// check predicate 2 :
		String predicate2 = element.getElementsByTagName(XMLelement.predicate2.toString())
				.item(0).getTextContent();
		Map<IRI,Value> predicateValuesEvent2 = EventOntology.getOnePredicateValuePair(predicate2, 
				eventQuery.get(eventNumber2).getEvent());
		IRI predicate2IRI = predicateValuesEvent2.keySet().iterator().next();
		IRI value2IRI = (IRI) predicateValuesEvent2.get(predicate2IRI);
		
		if (!value1IRI.equals(value2IRI)){
			throw new IncomparableValueException("can't compare " + value1IRI.stringValue() + 
					" and " + value2IRI.stringValue() + " values of " + predicate1 + " and " + 
					predicate2);
		}
		
		eventQuery.get(eventNumber1).addLinkStatement(predicate1IRI);
		eventQuery.get(eventNumber2).addLinkStatement(predicate2IRI);
		
		// Check the operator !!
		String variableName1 = eventQuery.get(eventNumber1).getVariableName(predicate1IRI.getLocalName()) ;
		String variableName2 = eventQuery.get(eventNumber2).getVariableName(predicate2IRI.getLocalName()) ;
		String minValue = element.getElementsByTagName(XMLelement.minValue.toString())
				.item(0).getTextContent();
		String maxValue = element.getElementsByTagName(XMLelement.maxValue.toString())
				.item(0).getTextContent();
		addBinding(variableName1,variableName2,minValue,maxValue);
	}
	
	private void addBinding (String variableName1, String variableName2, String minValue, String maxValue) throws IllegalArgumentException{
		String diff = "?diff" + variableName2.replaceAll("^[?]", "") + variableName1.replaceAll("^[?]", "");
		String bind = "bind ((" + variableName2 + " - " + variableName1 + ") as " + diff + ")";
		String filter = EventQuery.getNumericFilter(diff, minValue, maxValue);
		addBindStatements(bind);
		addFilterStatements(filter);
	}
	
	public String getQueryString(){
		String queryString = "";
		
		// Select Statements
		String part1 = "SELECT ?context ";
		for (int numberEvent : eventQuery.keySet()){
			part1 += "?event" + numberEvent + " ";
		}
		queryString += part1 ; 
		
		// Where Statements
		String part2 = " WHERE {graph ?context { \n";
		part2 += mergeStatementWhere();
		
		// Bound variable :
		for(String statement : getBindStatements()){
			part2 += statement + "\n";
		}
		
		// Filter of events statement : 
		Iterator<EventQuery> eventQueries = eventQuery.values().iterator();
		while(eventQueries.hasNext()){
			for(String statement : eventQueries.next().getStatementsFilter()){
				part2 += statement + "\n";
			}
		}
		
		// Filter of bound Variable :
		for(String statement : getFilterStatements()){
			part2 += statement + "\n";
		}

		part2 += "}}";
		
		queryString += part2;
		
		return(queryString);
	}
	
	public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, ParseException, NumberFormatException, IncomparableValueException {
		QueryClass queryClass = new QueryClass(new File(Util.queryFolder+"queryMCOSSR3day.xml"));
		System.out.println(queryClass.getQueryString());
	}

}
