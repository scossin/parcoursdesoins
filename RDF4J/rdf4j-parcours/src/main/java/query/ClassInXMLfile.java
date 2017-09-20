package query;

import java.text.ParseException;
import java.util.LinkedHashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Literal;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.datatypes.XMLDatatypeUtil;
import org.eclipse.rdf4j.model.util.LiteralUtilException;
import org.eclipse.rdf4j.model.vocabulary.RDF;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import exceptions.InvalidXMLFormat;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import parameters.Util;
import query.XMLFile.XMLelement;
import terminology.OneClass;
import terminology.Predicates;
import terminology.Terminology;


/**
 * This class represents an oneClass described in a user query (send via a XMLfile).
 * @author cossin
 *
 */
public class ClassInXMLfile {
	final static Logger logger = LoggerFactory.getLogger(ClassInXMLfile.class);
	
	/**
	 * The variable that will be used to describe the oneClass in the SPARQL query
	 * Concatenation of "?oneClass" and oneClass number (ex : ?oneClass0)
	 */
	private String oneClassVariable ; 
	
	/**
	 * According to the oneClassType : an instance of class OneClass
	 * It makes the link with the Ontology (oneClass must be known, list of predicates of this oneClass...)
	 */
	private OneClass oneClass;

	/**
	 * A set of SPARQL statements in the WHERE clause
	 */
	private Set<String> whereStatements = new LinkedHashSet<String>();
	
	/**
	 * A set of SPARQL statements in the FILTER clause (the end of WHERE clause)
	 */
	private Set<String> filterStatements = new LinkedHashSet<String>();	
	
	
	private Terminology terminology ; 
	
	/********************************* Getter **********************/
	public Set<String> getStatementsWhere(){
		return(whereStatements);
	}
	
	public Set<String> getStatementsFilter(){
		return(filterStatements);
	}
	
	public String getOneClassVariable() {
		return oneClassVariable;
	}
	
	public OneClass getOneClass(){
		return(oneClass);
	}
	
	/**
	 * Transform a XML element describing an oneClass to an instance of this class :
	 * <ul>
	 * <li> check if the oneClass type is in the OneClassOntology
	 * <li> check if all predicates are known
	 * <li> check values of predicates are correct (date, numeric values or instance of a terminology)
	 * <li> Transform the description into SPARQL statements
	 * </ul>
	 * @param eventNode A XML element describing an oneClass. See {@link XMLFile}
	 * @throws UnfoundEventException If the oneClass type is not in the OneClassOntology
	 * @throws InvalidXMLFormat If XML element is invalid (already checked normally)
	 * @throws UnfoundPredicatException If a predicate of this oneClass is not in the OneClassOntology 
	 * @throws ParseException 
	 * @throws UnfoundTerminologyException The terminology is not found in the OneClassOntology
	 */
	public ClassInXMLfile(Node eventNode) throws UnfoundEventException, InvalidXMLFormat, UnfoundPredicatException, ParseException, UnfoundTerminologyException{
		this.oneClassVariable = "?event" + XMLFile.getEventNumber(eventNode);
		String className = XMLFile.getEventType(eventNode);
		terminology = XMLFile.getTerminology(eventNode);
		this.oneClass = terminology.getClassDescription().getClass(className);
		setRDFtypeStatement();
		//setHasNumStatement();
		setPredicatesStatement(eventNode);
	}
	

	/**
	 * Extract from the XML element the predicates and create SPARQL statements
	 * @param eventNode A XML element describing an oneClass. See {@link XMLFile}
	 * @throws InvalidXMLFormat If XML element is invalid (already checked normally)
	 * @throws UnfoundPredicatException If a predicate of this oneClass is not in the OneClassOntology 
	 * @throws ParseException
	 * @throws UnfoundTerminologyException The terminology is not found in the OneClassOntology
	 * @throws UnfoundEventException 
	 */
	public void setPredicatesStatement(Node eventNode) throws InvalidXMLFormat, UnfoundPredicatException, ParseException, UnfoundTerminologyException, UnfoundEventException{
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
	 * Add the type of this oneClass in the SPARQL statement where (ex : ?oneClass0 a SejourHospitalier)
	 */
	private void setRDFtypeStatement (){
		addWhereStatement(oneClassVariable, Query.formatIRI4query(RDF.TYPE), Query.formatIRI4query(this.oneClass.getClassIRI()));
	}
	
	/**
	 * If there is a link between 2 oneClasss, we must add the description before comparison. <br>
	 * Ex : link between hasEnd and hasBeginning of oneClasss 0 and 1 ; we add hasEnd statement of oneClass0 and
	 * hasBeginning of oneClass1 before comparison of dates. 
	 * @param predicate
	 * @throws UnfoundPredicatException 
	 * @throws UnfoundEventException 
	 */
	public void addLinkStatement (IRI predicate) throws UnfoundPredicatException, UnfoundEventException{
		if (!terminology.isPredicateOfClass(predicate.getLocalName(), oneClass)){
			throw new UnfoundPredicatException(logger, predicate.getLocalName());
		}
		String variableName = getVariableName(predicate.getLocalName());
		addWhereStatement(oneClassVariable, Query.formatIRI4query(predicate), variableName);
	}
	
	/**
	 * Variable names are created by concatenation of the oneClassVariable (ex : ?oneClass0) and localName of predicate (ex : hasBeginning). (ex : ?oneClass0hasBeginning)
	 * @param predicateName
	 * @return
	 */
	public String getVariableName (String predicateName){
		return(oneClassVariable + predicateName);
	}
	
	/**
	 * Add hasBeginning statement of the oneClass
	 */
//	private void setHasBeginningStatement(){
//		// create node timeInstantStart
//		String variableInstantStart = oneClassVariable + "Start";
//		String variableInstantStartValue = getVariableName(TIME.HASBEGINNING.getLocalName());
//		// this oneClass hasBeginning this node 
//		addWhereStatement(oneClassVariable, Query.formatIRI4query(TIME.HASBEGINNING), variableInstantStart);
//		// the start of the oneClass is a timeInstant
//		addWhereStatement(variableInstantStart, Query.formatIRI4query(RDF.TYPE), Query.formatIRI4query(TIME.INSTANT));
//		// the date value is
//		addWhereStatement(variableInstantStart, Query.formatIRI4query(TIME.INXSDDATETIME), 
//				variableInstantStartValue);
//	}
	
	/**
	 * Add hasEnd statement of the oneClass
	 */
//	private void setHasEndStatement(){
//		String variableInstantEnd = oneClassVariable + "End";
//		String variableInstantEndValue = getVariableName(TIME.HASEND.getLocalName());
//		// this oneClass hasBeginning this node 
//		addWhereStatement(oneClassVariable, Query.formatIRI4query(TIME.HASEND), variableInstantEnd);
//		// the start of the oneClass is a timeInstant
//		addWhereStatement(variableInstantEnd, Query.formatIRI4query(RDF.TYPE), Query.formatIRI4query(TIME.INSTANT));
//		// the date value is
//		addWhereStatement(variableInstantEnd, Query.formatIRI4query(TIME.INXSDDATETIME), 
//				variableInstantEndValue);
//	}
	
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
	 * @throws UnfoundPredicatException The predicate of this oneClass is not described in the OneClassOntology
	 * @throws LiteralUtilException If the predicate doesn't expect a numeric value
	 * @throws NumberFormatException If the value in the XML is unexpected (not numeric)
	 * @throws InvalidXMLFormat If XML element is invalid (ex : minValue and maxValue not set)
	 * @throws UnfoundEventException 
	 */
	private void setNumericalStatement (Element numericPredicate) throws UnfoundPredicatException, LiteralUtilException, NumberFormatException, InvalidXMLFormat, UnfoundEventException{
		String predicateType = getPredicateType(numericPredicate);
		Predicates predicate = terminology.getOnePredicate(predicateType, this.oneClass);
		// check if expected value is numeric
		Value value = predicate.getExpectedValue();
		IRI valueIRI = (IRI) value;
		if (!XMLDatatypeUtil.isNumericDatatype(valueIRI)){
			throw new LiteralUtilException(predicateType + " doesn't expect this datatype" +
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
			String msg = oneClassVariable + predicateType + " min and maxValue : at least one of them must be set";
			throw new InvalidXMLFormat(logger, msg);
		}
		
		// finally add the where statement :
		addWhereStatement(oneClassVariable, Query.formatIRI4query(predicate.getPredicateIRI()), numericVariable);
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
				minStat = numericVariableName + " >= " + min;
			}
			
			if (isSetMax){
				double max = Double.parseDouble(maxValue);
				maxStat = numericVariableName + " <= " + max ;
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
			throw new NumberFormatException ("Non integer oneClass number given");
		}
		// unreachable : every combination done
		return("");
	}
	

	/**
	 * Add statement for a date predicate
	 * @param datePredicate XML element containing a date predicate description
	 * @throws UnfoundPredicatException The predicate of this oneClass is not described in the OneClassOntology
	 * @throws ParseException 
	 * @throws InvalidXMLFormat If XML element is invalid (ex : minValue and maxValue not set)
	 * @throws UnfoundEventException 
	 */
	private void setDateStatement (Element datePredicate) throws UnfoundPredicatException, ParseException, InvalidXMLFormat, UnfoundEventException{
		String predicateType = getPredicateType(datePredicate);
		String dateVariable = getVariableName(predicateType);
		
		// first : add the Where Statement : 
//		if (TIME.isRecognizedTimePredicate(predicateType)){
//			if (predicateType.equals(TIME.HASBEGINNING.getLocalName())){
//				setHasBeginningStatement();
//			} else {
//				setHasEndStatement();
//			}
		
//		} else {
		Predicates predicate = terminology.getOnePredicate(predicateType, this.oneClass);
		Value value = predicate.getExpectedValue();
		IRI valueIRI = (IRI) value;
		if (!XMLDatatypeUtil.isCalendarDatatype(valueIRI)){
			throw new LiteralUtilException(predicateType + " doesn't expect a this datatype" +
					" but a " + valueIRI.stringValue() + "datatype");
		}
		addWhereStatement(oneClassVariable, Query.formatIRI4query(predicate.getPredicateIRI()), dateVariable);	
//		}
			
		
		// Second : add the Filter Statement
		String minValue = datePredicate.getElementsByTagName(XMLelement.minValue.toString()).item(0).getTextContent();
		String maxValue = datePredicate.getElementsByTagName(XMLelement.maxValue.toString()).item(0).getTextContent();
		boolean isSetMin = !minValue.equals("");
		boolean isSetMax = !maxValue.equals("");

		if (!isSetMin && !isSetMax){
			throw new InvalidXMLFormat(logger, oneClassVariable + predicateType + " min and maxValue not set");
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
	 * @throws UnfoundPredicatException The predicate of this oneClass is not described in the OneClassOntology
	 * @throws UnfoundTerminologyException The terminology is not found in the OneClassOntology
	 * @throws UnfoundEventException 
	 */
	private void setFactorStatement (Element factorPredicate) throws UnfoundPredicatException, UnfoundTerminologyException, UnfoundEventException{
		String predicateType = getPredicateType(factorPredicate);
		String factorVariable = getVariableName(predicateType);
		
		Predicates predicate = terminology.getOnePredicate(predicateType, this.oneClass);
		Value value = predicate.getExpectedValue();
		IRI terminologyIRI = (IRI) value;
		String namespaceTerminoIRI = terminologyIRI.getNamespace();

		// add the filter statement : 
		NodeList factorValuesNodes = factorPredicate.getElementsByTagName(XMLelement.value.toString());
		if (factorValuesNodes.getLength() == 0){ // no element value
			return;
		}
		// ex : VALUES (?oneClass0inEtab) { ( <https://www.data.gouv.fr/FINESS#Etablissement330000555> ) }
		String instanceNames[] = factorValuesNodes.item(0).getTextContent().split("\t"); // only one item
		String filter = "VALUES ("+ factorVariable + ") {";
		for (String instanceName : instanceNames){
			if (predicate.getIsObjectProperty()){
				IRI instanceIRI = Util.vf.createIRI(namespaceTerminoIRI, instanceName);
				filter += "("+Query.formatIRI4query(instanceIRI) + ") ";
			} else {
				Literal literal = Util.vf.createLiteral(instanceName);
				filter += "(" + literal.toString() +") ";
			}
			
		}
		filter = filter + "}";
		addFilterStatement(filter);
		
		// finally, add the whereStatement :
		addWhereStatement(oneClassVariable, Query.formatIRI4query(predicate.getPredicateIRI()), factorVariable);
	}
	
	/**
	 * Add statement for a factor predicate
	 * @param factorPredicate XML element containing a factor predicate description
	 * @throws UnfoundPredicatException The predicate of this oneClass is not described in the OneClassOntology
	 * @throws UnfoundTerminologyException The terminology is not found in the OneClassOntology
	 * @throws UnfoundEventException 
	 */
	@Deprecated
	private void setFactorStatementin (Element factorPredicate) throws UnfoundPredicatException, UnfoundTerminologyException, UnfoundEventException{
		String predicateType = getPredicateType(factorPredicate);
		String factorVariable = getVariableName(predicateType);
		
		Predicates predicate = terminology.getOnePredicate(predicateType, this.oneClass);
		Value value = predicate.getExpectedValue();
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
		addWhereStatement(oneClassVariable, Query.formatIRI4query(predicate.getPredicateIRI()), factorVariable);
	}
}
