package query;

import java.text.ParseException;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Literal;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.datatypes.XMLDatatypeUtil;
import org.eclipse.rdf4j.model.util.LiteralUtilException;
import org.eclipse.rdf4j.model.vocabulary.RDF;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import exceptions.InvalidXMLFormat;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import integration.TIME;
import integration.Util;
import ontologie.Event;
import ontologie.EventOntology;
import query.XMLquery.XMLelement;

public class EventQuery {

	private String eventVariable ; 
	
	public String getEventVariable() {
		// TODO Auto-generated method stub
		return eventVariable;
	}
	
	private Event event;
	
	public Event getEvent(){
		return(event);
	}
	
	private Set<String> stringStatements = new LinkedHashSet<String>();
	
	private Set<String> stringFilter = new LinkedHashSet<String>();	
	
	public Set<String> getStatementsWhere(){
		return(stringStatements);
	}
	
	public Set<String> getStatementsFilter(){
		return(stringFilter);
	}
	
	public void addStringStatement(String subject, String predicate, String object){
		String statement = subject + " " + predicate + " " + object + " .";
		stringStatements.add(statement);
	}
	
	public void addFilterStatement(String statement){
		stringFilter.add(statement);
	}
	

	
	public EventQuery(Node eventNode) throws UnfoundEventException, InvalidXMLFormat, UnfoundPredicatException, ParseException{
		eventVariable = "?event" + XMLquery.getEventNumber(eventNode);
		this.event = EventOntology.getEvent(XMLquery.getEventType(eventNode));
		setRDFtypeStatement();
		updateEventQuery(eventNode);
	}
	
	public void updateEventQuery(Node eventNode) throws InvalidXMLFormat, UnfoundPredicatException, ParseException{
		NodeList nodeList = XMLquery.getDatePredicate(eventNode);
		for (int i = 0; i < nodeList.getLength() ; i ++){
			Element element = (Element) nodeList.item(i);
			setDateStatement(element);
		}
		nodeList = XMLquery.getNumericPredicate(eventNode);
		for (int i = 0; i < nodeList.getLength() ; i ++){
			Element element = (Element) nodeList.item(i);
			setNumericalStatement(element);
		}
		nodeList = XMLquery.getFactorPredicate(eventNode);
		for (int i = 0; i < nodeList.getLength() ; i ++){
			Element element = (Element) nodeList.item(i);
			setFactorStatement(element);
		}
	}
	
	public EventQuery(int eventNumber, String eventName) throws UnfoundEventException{
		this.eventVariable = "?event" + eventNumber;
		this.event = EventOntology.getEvent(eventName);
		setRDFtypeStatement();
	}
	
	private String formatIRI4query (IRI oneIRI){
		return("<" + oneIRI.stringValue()+">");
	}
	
	private void setRDFtypeStatement (){
		addStringStatement(eventVariable, formatIRI4query(RDF.TYPE), formatIRI4query(this.event.getEventIRI()));
	}
	
	public void addLinkStatement (IRI predicate){
		if (TIME.isRecognizedTimePredicate(predicate.getLocalName())){
			if (TIME.HASBEGINNING.equals(predicate)){
				setHasBeginningStatement();
			} else {
				setHasEndStatement();
			}
		} else {
			addStringStatement(eventVariable, formatIRI4query(predicate), getVariableName(predicate.getLocalName()));	
		}

	}
	
	public String getVariableName (String predicate){
		return(eventVariable + predicate);
	}
	
	public void setHasBeginningStatement(){
		// create node timeInstantStart
		String variableInstantStart = eventVariable + "Start";
		String variableInstantStartValue = getVariableName(TIME.HASBEGINNING.getLocalName());
		// this event hasBeginning this node 
		addStringStatement(eventVariable, formatIRI4query(TIME.HASBEGINNING), variableInstantStart);
		// the start of the event is a timeInstant
		addStringStatement(variableInstantStart, formatIRI4query(RDF.TYPE), formatIRI4query(TIME.INSTANT));
		// the date value is
		addStringStatement(variableInstantStart, formatIRI4query(TIME.INXSDDATETIME), 
				variableInstantStartValue);
	}
	
	public void setHasEndStatement(){
		String variableInstantEnd = eventVariable + "End";
		String variableInstantEndValue = getVariableName(TIME.HASEND.getLocalName());
		// this event hasBeginning this node 
		addStringStatement(eventVariable, formatIRI4query(TIME.HASEND), variableInstantEnd);
		// the start of the event is a timeInstant
		addStringStatement(variableInstantEnd, formatIRI4query(RDF.TYPE), formatIRI4query(TIME.INSTANT));
		// the date value is
		addStringStatement(variableInstantEnd, formatIRI4query(TIME.INXSDDATETIME), 
				variableInstantEndValue);
	}
	
	private String getPredicateType(Element element){
		String predicateType = element.getElementsByTagName("predicateType").item(0).getTextContent();
		return(predicateType);
	}
	
	
	public void setNumericalStatement (Element numericPredicate) throws UnfoundPredicatException, LiteralUtilException, NumberFormatException, InvalidXMLFormat{
		String predicateType = getPredicateType(numericPredicate);
		HashMap<IRI, Value> predicateValue = EventOntology.getOnePredicateValuePair(predicateType, this.event);
		IRI predicateIRI = predicateValue.keySet().iterator().next();		
		Value value = predicateValue.get(predicateIRI);

		String numericVariable = getVariableName(predicateType);
		
		IRI valueIRI = (IRI) value;
		if (!XMLDatatypeUtil.isNumericDatatype(valueIRI)){
			throw new LiteralUtilException(predicateType + " doesn't expect a date value" +
					" but a " + valueIRI.stringValue() + "datatype");
		}
		
		String minValue = numericPredicate.getElementsByTagName(XMLelement.minValue.toString()).item(0).getTextContent();
		String maxValue = numericPredicate.getElementsByTagName(XMLelement.maxValue.toString()).item(0).getTextContent();
		
		try{
			addFilterStatement(getNumericFilter(numericVariable,minValue,maxValue));
		} catch (IllegalArgumentException e){
			throw new InvalidXMLFormat(eventVariable + predicateType + " min and maxValue : at least one of them must be set");
		}
		
		// finally add predicateIRI statement :
		addStringStatement(eventVariable, formatIRI4query(predicateIRI), numericVariable);
		
	}
	
	public static String getNumericFilter(String numericVariableName, String minValue, String maxValue) throws IllegalArgumentException{
		boolean isSetMin = !minValue.equals("");
		boolean isSetMax = !maxValue.equals("");
		
		if (!isSetMin && !isSetMax){
			throw new IllegalArgumentException("min and maxValue : at least one of them must be set");
		}
		
		String minStat = "";
		String maxStat = "";
		
		try {
			
		} catch (NumberFormatException e) {
			throw new NumberFormatException ("Non integer event number given");
		}
		if (isSetMin){
			double min = Double.parseDouble(minValue);
			minStat = numericVariableName + " > " + min;
		}
		
		if (isSetMax){
			double max = Double.parseDouble(maxValue);
			maxStat = numericVariableName + " < " + max ;
		}
		
		if (isSetMin && isSetMax){
			return("FILTER (" + minStat + " && " + maxStat + ")");
		}
		
		if (isSetMin && !isSetMax){
			return("FILTER (" + minStat + ")");
		}
		
		if (!isSetMin && isSetMax){
			return("FILTER (" + maxStat + ")");
		}
		// unreachable
		return("");
	}
	
	public void setDateStatement (Element datePredicate) throws UnfoundPredicatException, ParseException, InvalidXMLFormat{
		
		String predicateType = getPredicateType(datePredicate);
		String dateVariable = getVariableName(predicateType);
		
		if (TIME.isRecognizedTimePredicate(predicateType)){
			if (predicateType.equals(TIME.HASBEGINNING.getLocalName())){
				setHasBeginningStatement();
			} else {
				setHasEndStatement();
			}
		
		} else {
			HashMap<IRI, Value> predicateValue = EventOntology.getOnePredicateValuePair(predicateType, this.event);
			IRI predicateIRI = predicateValue.keySet().iterator().next();		
			Value value = predicateValue.get(predicateIRI);
			IRI valueIRI = (IRI) value;
			if (!XMLDatatypeUtil.isCalendarDatatype(valueIRI)){
				throw new LiteralUtilException(predicateType + " doesn't expect a date value" +
						" but a " + valueIRI.stringValue() + "datatype");
			}
			
			addStringStatement(eventVariable, formatIRI4query(predicateIRI), dateVariable);	
		}
			
			String minValue = datePredicate.getElementsByTagName(XMLelement.minValue.toString()).item(0).getTextContent();
			boolean isSetMin = !minValue.equals("");
			String maxValue = datePredicate.getElementsByTagName(XMLelement.maxValue.toString()).item(0).getTextContent();
			boolean isSetMax = !maxValue.equals("");
			
			if (!isSetMin && !isSetMax){
				throw new InvalidXMLFormat(eventVariable + predicateType + " min and maxValue not set");
			}
			
			String minStat = "";
			String maxStat = "";
			
			if (isSetMin){
				Literal dateMin = Util.dateStringToLiteral(minValue);
				minStat = dateVariable + " > " + dateMin.toString();
			}
			
			if (isSetMax){
				Literal dateMax = Util.dateStringToLiteral(maxValue);
				maxStat = dateVariable + " < " + dateMax.toString();
			}
			
			if (isSetMin && isSetMax){
				addFilterStatement("FILTER (" + minStat + " && " + maxStat + ")");
			}
			
			if (isSetMin && !isSetMax){
				addFilterStatement("FILTER (" + minStat + ")");
			}
			
			if (!isSetMin && isSetMax){
				addFilterStatement("FILTER (" + maxStat + ")");
			}
			
	}
	
	public void setFactorStatement (Element factorPredicate) throws UnfoundPredicatException{
		String predicateType = getPredicateType(factorPredicate);
		String factorVariable = getVariableName(predicateType);
		
		HashMap<IRI, Value> predicateValue = EventOntology.getOnePredicateValuePair(predicateType, this.event);
		IRI predicateIRI = predicateValue.keySet().iterator().next();		
		Value value = predicateValue.get(predicateIRI);
		IRI valueIRI = (IRI) value;
		/* Must check here if value is expected to be a resource*/ 
		addStringStatement(eventVariable, formatIRI4query(predicateIRI), factorVariable);
		
		// Filter part :
		NodeList factorValuesNodes = factorPredicate.getElementsByTagName(XMLelement.value.toString());
		if (factorValuesNodes.getLength() == 0){
			return;
		}
		
		String filter = "FILTER ("+ factorVariable + " IN ( " + "";
		for (int i = 0; i<factorValuesNodes.getLength() ; i++){
			IRI tempValue = Util.vf.createIRI(valueIRI.stringValue(), factorValuesNodes.item(i).getTextContent());
			filter += formatIRI4query(tempValue) + ",";
		}
		filter = filter.replaceAll("[,]$", "");
		filter = filter + "))";
		addFilterStatement(filter);
	}
	
	
	
	public static void main(String[] args) throws UnfoundEventException {
		// TODO Auto-generated method stub
		EventQuery eventQuery = new EventQuery(0, "SejourMCO");
		//eventQuery.setHasBeginningStatement();
		//eventQuery.setHasEndStatement();
		Set<String> statements = eventQuery.getStatementsWhere();
		
		for(String statement : statements){
			System.out.println(statement);
		}
		

	}



}
