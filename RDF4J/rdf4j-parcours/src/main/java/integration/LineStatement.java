package integration;

import java.text.ParseException;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Literal;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.vocabulary.RDF;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.InvalidContextException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundInstanceOfTerminologyException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import parameters.Util;
import terminology.OneClass;
import terminology.Predicates;
import terminology.Terminology;
import terminology.TerminologyInstances;

/**
 * A class to transform statements in a CSV file to statements in RDF. <br>
 * A CSV file must contain the following 5 columns : 
 *  <ul>
 *  <li> contextName
 *  <li> eventName (eventType)
 *  <li> dateStart of the event
 *  <li> predicateName
 *  <li> value
 *  </ul>
 *  The value of each column is checked during initialization of the object. <br>
 *  One statement by line in the CSV file == one instance of LineStatement created for each line
 *  Method {@link getStatements} returns a RDF statement 
 * @author cossin
 *
 */

public class LineStatement {
	
	final static Logger logger = LoggerFactory.getLogger(LineStatement.class);
	
	/**
	 * First thing checked : number of expected columns in the CSV file
	 */
	private final int nColumns = 5;
	
	/**
	 * IRI of the contextName
	 */
	private IRI contextIRI;
	
	private String columnSeparator;
	
	/**
	 * Object of class Event retrieved with the eventName(eventType)
	 */
	private OneClass oneClass;
	
	/**
	 * IRI of the predicate retrieved with the predicateName
	 */
	private IRI predicateIRI;
	
	/**
	 * The value (Resource or datatype) according to the predicate (range described in the ontology) and value given in CSV file
	 */
	private Value value;
	
	/**
	 * the id of the event in RDF 
	 */
	private IRI idEventIRI;
	
	private Terminology terminology;
	
	/**
	 * 
	 * @param line A line of a CSV file for example
	 * @param columnSeparator Columns separated by
	 * @throws ParseException if dateString not valid
	 * @throws UnfoundEventException if event not described in the ontology
	 * @throws UnfoundPredicatException if predicate not described in the ontology for this event
	 * @throws InvalidContextException if contextName format is incorrect
	 * @throws UnfoundTerminologyException if predicate is an objectProperty and instance is not found in terminology
	 */
	
	public LineStatement (String columnSeparator, Terminology terminology) {
		this.columnSeparator = columnSeparator;
		this.terminology = terminology;
	}
	
	public void addLineStatement (String line) throws UnfoundEventException, UnfoundPredicatException, InvalidContextException, ParseException, UnfoundTerminologyException, UnfoundInstanceOfTerminologyException{
		
		String[] columns = line.split(columnSeparator);
		checknColumns(columns.length);
		
		// first column
		String contextName = columns[0];
		this.contextIRI = EIG.getContextIRI(contextName);
		
		// Column 2 : type of Event
		String eventName = columns[1];
		this.oneClass = terminology.getClassDescription().getClass(eventName);
		
		// Column3 : setIdEvent with contextName + typeofEvent + dateStart
		String dateStart = columns[2];
		setIdEventIRI(dateStart);
		
		// Column 4 and 5 : predicate and value
		String predicate = columns[3];
		String value = columns[4];
		setPredicateValue(predicate, value);
		
	}
	
	/**
	 * If the predicateName is a time Ontology predicate (hasBeginning, hasEnd), 4 statements are returned <br>
	 * Otherwise, one statement is returned
	 * 
	 * @return RDF statements
	 */
	public Set<Statement> getStatements(){
		Set<Statement> statements = new HashSet<Statement>() ;
		
		// first statement : RDF.TYPE of event : 
		statements.add(Util.vf.createStatement(this.idEventIRI, RDF.TYPE, this.oneClass.getClassIRI(),contextIRI));
		
	    statements.add(Util.vf.createStatement(this.idEventIRI, predicateIRI, value, contextIRI));
		return(statements);
	}
		// check if predicateIRI is a time Ontology predicate
//		if (this.predicateIRI.equals(TIME.HASBEGINNING) || this.predicateIRI.equals(TIME.HASEND)){
//			// Every event is a timeInterval
//			statements.add(Util.vf.createStatement(this.idEventIRI, RDF.TYPE, TIME.INTERVAL,contextIRI));
//			if (this.predicateIRI.equals(TIME.HASBEGINNING)){
//				// create node timeInstantStart
//				IRI timeInstantStart = Util.vf.createIRI(TIME.NAMESPACE, idEventIRI.getLocalName()+"Start");
//				// this event hasBeginning this node 
//				statements.add(Util.vf.createStatement(this.idEventIRI, TIME.HASBEGINNING, timeInstantStart,contextIRI));
//				// the start of the event is a timeInstant
//				statements.add(Util.vf.createStatement(timeInstantStart, RDF.TYPE, TIME.INSTANT,contextIRI));
//				// the date value is
//				statements.add(Util.vf.createStatement(timeInstantStart, TIME.INXSDDATETIME, this.value,contextIRI));
//			} else {
//				// create node timeInstantEnd
//				IRI timeInstantEnd = Util.vf.createIRI(TIME.NAMESPACE, idEventIRI.getLocalName()+"End");
//				// this event hasEnd this node 
//				statements.add(Util.vf.createStatement(this.idEventIRI, TIME.HASEND, timeInstantEnd,contextIRI));;
//				// the end of the event is a timeInstant
//				statements.add(Util.vf.createStatement(timeInstantEnd, RDF.TYPE, TIME.INSTANT,contextIRI));
//				// the date value is
//				statements.add(Util.vf.createStatement(timeInstantEnd, TIME.INXSDDATETIME, this.value,contextIRI));
//			}
//		
//		// if predicateIRI is not a time Ontology predicate
//		} 



	/**
	 * check number of columns is equal to the expected value
	 * @param lengthExpected Number of columns expected
	 * @throws ParseException
	 */
	private void checknColumns(int lengthExpected) throws ParseException {
		if (lengthExpected != nColumns){
			String message = "Incorrect number of columns : " + nColumns + " ("+lengthExpected+" expected)";
			throw new java.text.ParseException(message,0);
		}
	}
	
	/**
	 * Compute the event id. This is created by concatenation of : 
	 * <li> contextName
	 * <li> eventName
	 * <li> dateStart
	 * @param dateStart The beginning of the event
	 * @throws ParseException If date can't be parsed
	 */
	private void setIdEventIRI(String dateStart) throws ParseException {
		// eventid = context + type + beginningdate
		Literal hasBeginning = Util.dateStringToLiteral(dateStart);
		String hasBeginningString = hasBeginning.stringValue();
		hasBeginningString = hasBeginningString.replaceAll("[-:.+]", "_"); // IRI must be correct format
		String idEvent = this.contextIRI.getLocalName() + "_" + this.oneClass.getClassIRI().getLocalName() 
				+ "_" + hasBeginningString ;	
		this.idEventIRI = Util.vf.createIRI(EIG.NAMESPACE, idEvent);
	}
	
	/**
	 * Check the predicate (a known predicate in the ontology), transform it to IRI ; check the value, transform it to a literal
	 * @param predicateName Must be known in the ontology {@link EventOntology}
	 * @param objValue Must be a valid object value according to the predicate
	 * @throws ParseException If the literal can't be made
	 * @throws UnfoundPredicatException If the predicate is not found
	 * @throws UnfoundTerminologyException If the instance is not described in the terminology
	 * @throws UnfoundInstanceOfTerminologyException 
	 * @throws UnfoundEventException 
	 */

	private void setPredicateValue(String predicateName, String objValue) throws UnfoundPredicatException, ParseException, UnfoundTerminologyException, UnfoundInstanceOfTerminologyException, UnfoundEventException {	
		
		// check if it's a timePredicate
//		if (TIME.isRecognizedTimePredicate(predicate)){
//			this.predicateIRI = Util.vf.createIRI(TIME.NAMESPACE, predicate);
//			this.value = Util.makeLiteral(XMLSchema.DATETIME, objValue);
//		} else { // not a timePredicate
			// is it a DataTypeProperty or ObjectProperty
		Predicates predicate = terminology.getOnePredicate(predicateName, this.oneClass);
		this.predicateIRI = predicate.getPredicateIRI();
		Value expectedValue = predicate.getExpectedValue();
		IRI expectedValueIRI = (IRI) expectedValue;

		// 2 possibilities : predicate is a datatype property or an object property
		boolean isDataType = !predicate.getIsObjectProperty();
		if (isDataType){
			this.value = Util.makeLiteral(expectedValueIRI, objValue);
		} else {
			// check if instance is known in the other terminology
			IRI mainClassNameIRI = expectedValueIRI;
			Terminology terminologyTarget = TerminologyInstances.getTerminologyByMainClassIRI(mainClassNameIRI);
			String instanceName = objValue;
			IRI instanceIRI = Util.vf.createIRI(mainClassNameIRI.getNamespace(), instanceName);
			boolean isInstance = terminologyTarget.getTerminologyServer().isInstanceOfTerminology(instanceIRI);
			if (isInstance){
				this.value = instanceIRI ;
			} else {
				throw new UnfoundInstanceOfTerminologyException(logger,instanceIRI.stringValue(), 
						expectedValueIRI.stringValue());
			}
		}
	}

	/* Getters ....................................*/
	public IRI getIdEventIRI() {
		return idEventIRI;
	}

	public IRI getPredicatIRI() {
		return predicateIRI;
	}

	public Value getValue() {
		return value;
	}
	
	public IRI getContext() {
		return contextIRI;
	}

	public OneClass getOneClass() {
		return oneClass;
	}
	
	
	public static void main(String[] args) throws Exception  {
		// TODO Auto-generated method stub
		//String line = "p1\tSejourMCO\t2017_02_28_23_59_59\thasEnd\t2017_02_28_23_59_59";
		String line = "p1\tSejourMCO\t2017_02_28_23_59_59\tinEtab\tEtablissement330781360";
		String separator = "\t";
			LineStatement newStatement = new LineStatement(separator, TerminologyInstances.getTerminology("Event"));
			
			try {
				newStatement.addLineStatement(line);
			} catch (InvalidContextException | UnfoundEventException | UnfoundPredicatException | ParseException
					| UnfoundTerminologyException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			Set<Statement> statements = newStatement.getStatements();
			for (Statement statement : statements){
				System.out.println(statement.toString());
			}
			
	}
}
