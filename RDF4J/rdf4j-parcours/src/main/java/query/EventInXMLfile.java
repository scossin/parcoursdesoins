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
import exceptions.UnfoundInstanceOfTerminologyException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import ontologie.Event;
import ontologie.EventOntology;
import ontologie.TIME;
import parameters.Util;
import query.XMLFile.XMLelement;


/**
 * This class represents an event described in a user query (send via a XMLfile).
 * @author cossin
 *
 */
public class EventInXMLfile {

	/**
	 * The variable that will be used to describe the event in the SPARQL query
	 * Concatenation of "?event" and event number (ex : ?event0)
	 */
	private String eventVariable ; 
	
	/**
	 * According to the eventType : an instance of class Event
	 * It makes the link with the Ontology (event must be known, list of predicates of this event...)
	 */
	private Event event;

	/**
	 * A set of SPARQL statements in the WHERE clause
	 */
	private Set<String> whereStatements = new LinkedHashSet<String>();
	
	/**
	 * A set of SPARQL statements in the FILTER clause (the end of WHERE clause)
	 */
	private Set<String> filterStatements = new LinkedHashSet<String>();	
	
	
	/********************************* Getter **********************/
	public Set<String> getStatementsWhere(){
		return(whereStatements);
	}
	
	public Set<String> getStatementsFilter(){
		return(filterStatements);
	}
	
	public String getEventVariable() {
		return eventVariable;
	}
	
	public Event getEvent(){
		return(event);
	}
	
	/**
	 * Transform a XML element describing an event to an instance of this class :
	 * <ul>
	 * <li> check if the event type is in the EventOntology
	 * <li> check if all predicates are known
	 * <li> check values of predicates are correct (date, numeric values or instance of a terminology)
	 * <li> Transform the description into SPARQL statements
	 * </ul>
	 * @param eventNode A XML element describing an event. See {@link XMLFile}
	 * @throws UnfoundEventException If the event type is not in the EventOntology
	 * @throws InvalidXMLFormat If XML element is invalid (already checked normally)
	 * @throws UnfoundPredicatException If a predicate of this event is not in the EventOntology 
	 * @throws ParseException 
	 * @throws UnfoundTerminologyException The terminology is not found in the EventOntology
	 */
	public EventInXMLfile(Node eventNode) throws UnfoundEventException, InvalidXMLFormat, UnfoundPredicatException, ParseException, UnfoundTerminologyException{
		this.eventVariable = "?event" + XMLFile.getEventNumber(eventNode);
		this.event = EventOntology.getEvent(XMLFile.getEventType(eventNode));
		setRDFtypeStatement();
		setHasNumStatement();
		setPredicatesStatement(eventNode);
	}
	

	/**
	 * Extract from the XML element the predicates and create SPARQL statements
	 * @param eventNode A XML element describing an event. See {@link XMLFile}
	 * @throws InvalidXMLFormat If XML element is invalid (already checked normally)
	 * @throws UnfoundPredicatException If a predicate of this event is not in the EventOntology 
	 * @throws ParseException
	 * @throws UnfoundTerminologyException The terminology is not found in the EventOntology
	 */
	public void setPredicatesStatement(Node eventNode) throws InvalidXMLFormat, UnfoundPredicatException, ParseException, UnfoundTerminologyException{
		// date type
		NodeList nodeList = XMLFile.getDatePredicate(eventNode);
		for (int i = 0; i < nodeList.getLength() ; i ++){
			Element element = (Element) nodeList.item(i);
			setDateStatement(element);
		}
		
		// numeric type
		nodeList = XMLFile.getNumericPredicate(eventNode);
		for (int i = 0; i < nodeList.getLength() ; i ++){
			Element element = (Element) nodeList.item(i);
			setNumericalStatement(element);
		}
		
		// factor type
		nodeList = XMLFile.getFactorPredicate(eventNode);
		for (int i = 0; i < nodeList.getLength() ; i ++){
			Element element = (Element) nodeList.item(i);
			setFactorStatement(element);
		}
	}
	
	/**
	 * Add a new SPARQL statement in the WHERE clause
	 * @param subject
	 * @param predicate
	 * @param object
	 */
	public void addWhereStatement(String subject, String predicate, String object){
		String statement = subject + " " + predicate + " " + object + " .";
		whereStatements.add(statement);
	}
	
	/**
	 * Add a new SPARQL statement in the FILTER clause
	 * @param statement A string statement
	 */
	public void addFilterStatement(String statement){
		filterStatements.add(statement);
	}


	
	/**
	 * Add the type of this event in the SPARQL statement where (ex : ?event0 a SejourHospitalier)
	 */
	private void setRDFtypeStatement (){
		addWhereStatement(eventVariable, Query.formatIRI4query(RDF.TYPE), Query.formatIRI4query(this.event.getEventIRI()));
	}
	
	/**
	 * Add the numbering of this event in the timeline in the SPARQL statement where (ex : ?event0 hasNum ?event0hasNum)
	 * It's only used to order the results. 
	 */
	private void setHasNumStatement (){
		IRI hasNum = Util.vf.createIRI(EIG.NAMESPACE, EIG.hasNum);
		String numVariable = getVariableName(EIG.hasNum) ; 
		addWhereStatement(eventVariable, Query.formatIRI4query(hasNum), numVariable);
	}
	
	/**
	 * If there is a link between 2 events, we must add the description before comparison. <br>
	 * Ex : link between hasEnd and hasBeginning of events 0 and 1 ; we add hasEnd statement of event0 and
	 * hasBeginning of event1 before comparison of dates. 
	 * @param predicate
	 * @throws UnfoundPredicatException 
	 */
	public void addLinkStatement (IRI predicate) throws UnfoundPredicatException{
		if (!EventOntology.isPredicateOfEvent(predicate.getLocalName(), event)){
			throw new UnfoundPredicatException(predicate.getLocalName());
		}
		
		if (TIME.isRecognizedTimePredicate(predicate.getLocalName())){
			if (TIME.HASBEGINNING.equals(predicate)){
				setHasBeginningStatement();
			} else {
				setHasEndStatement();
			}
			
		} else {
			String variableName = getVariableName(predicate.getLocalName());
			addWhereStatement(eventVariable, Query.formatIRI4query(predicate), variableName);	
		}
	}
	
	/**
	 * Variable names are created by concatenation of the eventVariable (ex : ?event0) and localName of predicate (ex : hasBeginning). (ex : ?event0hasBeginning)
	 * @param predicateName
	 * @return
	 */
	public String getVariableName (String predicateName){
		return(eventVariable + predicateName);
	}
	
	/**
	 * Add hasBeginning statement of the event
	 */
	private void setHasBeginningStatement(){
		// create node timeInstantStart
		String variableInstantStart = eventVariable + "Start";
		String variableInstantStartValue = getVariableName(TIME.HASBEGINNING.getLocalName());
		// this event hasBeginning this node 
		addWhereStatement(eventVariable, Query.formatIRI4query(TIME.HASBEGINNING), variableInstantStart);
		// the start of the event is a timeInstant
		addWhereStatement(variableInstantStart, Query.formatIRI4query(RDF.TYPE), Query.formatIRI4query(TIME.INSTANT));
		// the date value is
		addWhereStatement(variableInstantStart, Query.formatIRI4query(TIME.INXSDDATETIME), 
				variableInstantStartValue);
	}
	
	/**
	 * Add hasEnd statement of the event
	 */
	private void setHasEndStatement(){
		String variableInstantEnd = eventVariable + "End";
		String variableInstantEndValue = getVariableName(TIME.HASEND.getLocalName());
		// this event hasBeginning this node 
		addWhereStatement(eventVariable, Query.formatIRI4query(TIME.HASEND), variableInstantEnd);
		// the start of the event is a timeInstant
		addWhereStatement(variableInstantEnd, Query.formatIRI4query(RDF.TYPE), Query.formatIRI4query(TIME.INSTANT));
		// the date value is
		addWhereStatement(variableInstantEnd, Query.formatIRI4query(TIME.INXSDDATETIME), 
				variableInstantEndValue);
	}
	
	/**
	 * Get the predicate type in the XML file
	 * @param element A XML predicate element 
	 * @return The predicateName
	 */
	private String getPredicateType(Element element){
		String predicateType = element.getElementsByTagName(XMLelement.predicateType.toString()).item(0).getTextContent();
		return(predicateType);
	}
	
	/**
	 * Add statement for a numerical predicate
	 * @param numericPredicate XML element containing a predicate description
	 * @throws UnfoundPredicatException The predicate of this event is not described in the EventOntology
	 * @throws LiteralUtilException If the predicate doesn't expect a numeric value
	 * @throws NumberFormatException If the value in the XML is unexpected (not numeric)
	 * @throws InvalidXMLFormat If XML element is invalid (ex : minValue and maxValue not set)
	 */
	private void setNumericalStatement (Element numericPredicate) throws UnfoundPredicatException, LiteralUtilException, NumberFormatException, InvalidXMLFormat{
		String predicateType = getPredicateType(numericPredicate);
		HashMap<IRI, Value> predicateValue = EventOntology.getOnePredicateValuePair(predicateType, this.event);
		IRI predicateIRI = predicateValue.keySet().iterator().next(); // only one predicate	
		// check if expected value is numeric
		Value value = predicateValue.get(predicateIRI);
		IRI valueIRI = (IRI) value;
		if (!XMLDatatypeUtil.isNumericDatatype(valueIRI)){
			throw new LiteralUtilException(predicateType + " doesn't expect a date value" +
					" but a " + valueIRI.stringValue() + "datatype");
		}
		
		// name of the numericVariable in the SPARQL query
		String numericVariable = getVariableName(predicateType);
		
		// minValue or MaxValue must be set
		String minValue = numericPredicate.getElementsByTagName(XMLelement.minValue.toString()).item(0).getTextContent();
		String maxValue = numericPredicate.getElementsByTagName(XMLelement.maxValue.toString()).item(0).getTextContent();
		
		// try to add the filter statement
		try{
			addFilterStatement(getNumericFilter(numericVariable,minValue,maxValue));
		} catch (IllegalArgumentException e){
			throw new InvalidXMLFormat(eventVariable + predicateType + " min and maxValue : at least one of them must be set");
		}
		
		// finally add the where statement :
		addWhereStatement(eventVariable, Query.formatIRI4query(predicateIRI), numericVariable);
	}
	
	/**
	 * Get a SPARQL statement for filtering a numeric value
	 * @param numericVariableName The name of the numeric variable
	 * @param minValue The minimum value for this variable
	 * @param maxValue The maximum value for this variable
	 * @return A string for a filter statement
	 * @throws IllegalArgumentException
	 */
	public static String getNumericFilter(String numericVariableName, String minValue, String maxValue) throws IllegalArgumentException{
		boolean isSetMin = !minValue.equals("");
		boolean isSetMax = !maxValue.equals("");
		
		if (!isSetMin && !isSetMax){
			throw new IllegalArgumentException("min and maxValue : at least one of them must be set");
		}
		
		String minStat = "";
		String maxStat = "";
		
		try {
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
		} catch (NumberFormatException e) {
			throw new NumberFormatException ("Non integer event number given");
		}
		// unreachable : every combination done
		return("");
	}
	

	/**
	 * Add statement for a date predicate
	 * @param datePredicate XML element containing a date predicate description
	 * @throws UnfoundPredicatException The predicate of this event is not described in the EventOntology
	 * @throws ParseException 
	 * @throws InvalidXMLFormat If XML element is invalid (ex : minValue and maxValue not set)
	 */
	private void setDateStatement (Element datePredicate) throws UnfoundPredicatException, ParseException, InvalidXMLFormat{
		String predicateType = getPredicateType(datePredicate);
		String dateVariable = getVariableName(predicateType);
		
		// first : add the Where Statement : 
		if (TIME.isRecognizedTimePredicate(predicateType)){
			if (predicateType.equals(TIME.HASBEGINNING.getLocalName())){
				setHasBeginningStatement();
			} else {
				setHasEndStatement();
			}
		
		} else {
			HashMap<IRI, Value> predicateValue = EventOntology.getOnePredicateValuePair(predicateType, this.event);
			IRI predicateIRI = predicateValue.keySet().iterator().next(); // only one predicate
			// check if value is expected to be a date : 
			Value value = predicateValue.get(predicateIRI);
			IRI valueIRI = (IRI) value;
			if (!XMLDatatypeUtil.isCalendarDatatype(valueIRI)){
				throw new LiteralUtilException(predicateType + " doesn't expect a date value" +
						" but a " + valueIRI.stringValue() + "datatype");
			}
			addWhereStatement(eventVariable, Query.formatIRI4query(predicateIRI), dateVariable);	
		}
			
		
		// Second : add the Filter Statement
		String minValue = datePredicate.getElementsByTagName(XMLelement.minValue.toString()).item(0).getTextContent();
		String maxValue = datePredicate.getElementsByTagName(XMLelement.maxValue.toString()).item(0).getTextContent();
		boolean isSetMin = !minValue.equals("");
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
	
	/**
	 * Add statement for a factor predicate
	 * 
	 * @param factorPredicate XML element containing a factor predicate description
	 * @throws UnfoundPredicatException The predicate of this event is not described in the EventOntology
	 * @throws UnfoundTerminologyException The terminology is not found in the EventOntology
	 */
	private void setFactorStatement (Element factorPredicate) throws UnfoundPredicatException, UnfoundTerminologyException{
		String predicateType = getPredicateType(factorPredicate);
		String factorVariable = getVariableName(predicateType);
		
		HashMap<IRI, Value> predicateValue = EventOntology.getOnePredicateValuePair(predicateType, this.event);
		IRI predicateIRI = predicateValue.keySet().iterator().next();		
		Value value = predicateValue.get(predicateIRI);
		IRI terminologyIRI = (IRI) value;

		// add the filter statement : 
		NodeList factorValuesNodes = factorPredicate.getElementsByTagName(XMLelement.value.toString());
		if (factorValuesNodes.getLength() == 0){ // no element value
			return;
		}
		
		// ex : VALUES (?event0inEtab) { ( <https://www.data.gouv.fr/FINESS#Etablissement330000555> ) }
		String filter = "VALUES ("+ factorVariable + ") {";
		for (int i = 0; i<factorValuesNodes.getLength() ; i++){
			String instanceName = factorValuesNodes.item(i).getTextContent();
			// check if instance belongs to the terminology
			IRI instanceIRI = Util.vf.createIRI(terminologyIRI.stringValue(), instanceName);
			filter += "("+Query.formatIRI4query(instanceIRI) + ") ";	
		}
		filter = filter + "}";
		addFilterStatement(filter);
		
		// finally, add the whereStatement :
		addWhereStatement(eventVariable, Query.formatIRI4query(predicateIRI), factorVariable);
	}
	
	/**
	 * Add statement for a factor predicate
	 * @param factorPredicate XML element containing a factor predicate description
	 * @throws UnfoundPredicatException The predicate of this event is not described in the EventOntology
	 * @throws UnfoundTerminologyException The terminology is not found in the EventOntology
	 */
	@Deprecated
	private void setFactorStatementin (Element factorPredicate) throws UnfoundPredicatException, UnfoundTerminologyException{
		String predicateType = getPredicateType(factorPredicate);
		String factorVariable = getVariableName(predicateType);
		
		HashMap<IRI, Value> predicateValue = EventOntology.getOnePredicateValuePair(predicateType, this.event);
		IRI predicateIRI = predicateValue.keySet().iterator().next();		
		Value value = predicateValue.get(predicateIRI);
		IRI terminologyIRI = (IRI) value;

		// add the filter statement : 
		NodeList factorValuesNodes = factorPredicate.getElementsByTagName(XMLelement.value.toString());
		if (factorValuesNodes.getLength() == 0){ // no node value
			return;
		}
		
		String filter = "FILTER ("+ factorVariable + " IN ( " + "";
		for (int i = 0; i<factorValuesNodes.getLength() ; i++){
			String instanceName = factorValuesNodes.item(i).getTextContent();
			// doesn'check if instance belongs to the terminology
			IRI instanceIRI = Util.vf.createIRI(terminologyIRI.stringValue(), instanceName);
			filter += Query.formatIRI4query(instanceIRI) + ",";
		}
		filter = filter.replaceAll("[,]$", ""); // remove last ,
		filter += "))"; // clause filter statement
		addFilterStatement(filter);
		
		// finally, add the whereStatement :
		addWhereStatement(eventVariable, Query.formatIRI4query(predicateIRI), factorVariable);
	}
	
	
}
