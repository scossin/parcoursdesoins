package integration;

import java.text.ParseException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Literal;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.vocabulary.RDF;
import org.eclipse.rdf4j.model.vocabulary.XMLSchema;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.InvalidContextException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundInstanceOfTerminologyException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import ontologie.Event;
import ontologie.EventOntology;
import ontologie.TIME;
import parameters.Util;
import servlet.DockerDB;
import servlet.DockerDB.Endpoints;
import terminology.Terminology;
import terminology.TerminologyServer;
import terminology.Terminology.TerminoEnum;

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
	private Event event;
	
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
	

	
	private HashMap<IRI, Set<IRI>> instancesOfTerminology ;
	
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
	
	public LineStatement (String columnSeparator, HashMap<IRI, Set<IRI>> instancesOfTerminology) {
		this.instancesOfTerminology = instancesOfTerminology;
		this.columnSeparator = columnSeparator;
	}
	
	public void addLineStatement (String line) throws UnfoundEventException, UnfoundPredicatException, InvalidContextException, ParseException, UnfoundTerminologyException, UnfoundInstanceOfTerminologyException{
		
		String[] columns = line.split(columnSeparator);
		checknColumns(columns.length);
		
		// first column
		String contextName = columns[0];
		this.contextIRI = EventOntology.getContextIRI(contextName);
		
		// Column 2 : type of Event
		String eventName = columns[1];
		this.event = EventOntology.getEvent(eventName);
		
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
		statements.add(Util.vf.createStatement(this.idEventIRI, RDF.TYPE, this.event.getEventIRI(),contextIRI));
		
		// check if predicateIRI is a time Ontology predicate
		if (this.predicateIRI.equals(TIME.HASBEGINNING) || this.predicateIRI.equals(TIME.HASEND)){
			// Every event is a timeInterval
			statements.add(Util.vf.createStatement(this.idEventIRI, RDF.TYPE, TIME.INTERVAL,contextIRI));
			if (this.predicateIRI.equals(TIME.HASBEGINNING)){
				// create node timeInstantStart
				IRI timeInstantStart = Util.vf.createIRI(TIME.NAMESPACE, idEventIRI.getLocalName()+"Start");
				// this event hasBeginning this node 
				statements.add(Util.vf.createStatement(this.idEventIRI, TIME.HASBEGINNING, timeInstantStart,contextIRI));
				// the start of the event is a timeInstant
				statements.add(Util.vf.createStatement(timeInstantStart, RDF.TYPE, TIME.INSTANT,contextIRI));
				// the date value is
				statements.add(Util.vf.createStatement(timeInstantStart, TIME.INXSDDATETIME, this.value,contextIRI));
			} else {
				// create node timeInstantEnd
				IRI timeInstantEnd = Util.vf.createIRI(TIME.NAMESPACE, idEventIRI.getLocalName()+"End");
				// this event hasEnd this node 
				statements.add(Util.vf.createStatement(this.idEventIRI, TIME.HASEND, timeInstantEnd,contextIRI));;
				// the end of the event is a timeInstant
				statements.add(Util.vf.createStatement(timeInstantEnd, RDF.TYPE, TIME.INSTANT,contextIRI));
				// the date value is
				statements.add(Util.vf.createStatement(timeInstantEnd, TIME.INXSDDATETIME, this.value,contextIRI));
			}
		
		// if predicateIRI is not a time Ontology predicate
		} else {
			statements.add(Util.vf.createStatement(this.idEventIRI, predicateIRI, value,contextIRI));
		}
		return(statements);
	}


	/**
	 * check number of columns is equal to the expected value
	 * @param lengthExpected Number of columns expected
	 * @throws ParseException
	 */
	private void checknColumns(int lengthExpected) throws ParseException {
		if (lengthExpected != nColumns){
			String message = "Incorrect number of columns ("+lengthExpected+")";
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
		String idEvent = this.contextIRI.getLocalName() + "_" + this.event.getEventIRI().getLocalName() 
				+ "_" + hasBeginningString ;	
		this.idEventIRI = Util.vf.createIRI(EIG.NAMESPACE, idEvent);
	}
	
	/**
	 * Check the predicate (a known predicate in the ontology), transform it to IRI ; check the value, transform it to a literal
	 * @param predicate Must be known in the ontology {@link EventOntology}
	 * @param objValue Must be a valid object value according to the predicate
	 * @throws ParseException If the literal can't be made
	 * @throws UnfoundPredicatException If the predicate is not found
	 * @throws UnfoundTerminologyException If the instance is not described in the terminology
	 * @throws UnfoundInstanceOfTerminologyException 
	 */

	private void setPredicateValue(String predicate, String objValue) throws UnfoundPredicatException, ParseException, UnfoundTerminologyException, UnfoundInstanceOfTerminologyException {	
		
		// check if it's a timePredicate
		if (TIME.isRecognizedTimePredicate(predicate)){
			this.predicateIRI = Util.vf.createIRI(TIME.NAMESPACE, predicate);
			this.value = Util.makeLiteral(XMLSchema.DATETIME, objValue);
		} else { // not a timePredicate
			// is it a DataTypeProperty or ObjectProperty
			Map<IRI, Value> predsValue = EventOntology.getPredicatesValueOfEvent(event);
			IRI predicateIRI = EventOntology.getPredicateIRI(predicate, predsValue);
			this.predicateIRI = predicateIRI;
			Value obj = predsValue.get(predicateIRI);
			IRI objIRI = (IRI) obj;
			
			// 2 possibilities : predicate is a datatype property or an object property
			boolean isDataType = EventOntology.getPredicatesIsDataTypeOfEvent(event).get(predicateIRI);
			if (isDataType){
				
				this.value = Util.makeLiteral(objIRI, objValue);
				
			} else {
				// check is value is known
				IRI classNameIRI = objIRI;
				String instanceName = objValue;
				IRI instanceIRI = Terminology.getTerminology(classNameIRI).makeInstanceIRI(instanceName);
				if (isInstanceOfTerminology(objIRI, instanceIRI)){
					this.value = Util.vf.createIRI(objIRI.stringValue(), objValue) ;
				} else {
					throw new UnfoundInstanceOfTerminologyException(logger,instanceIRI.stringValue(), 
							objIRI.stringValue());
				}
			}
		}
	}

	
	private boolean isInstanceOfTerminology(IRI classNameIRI, IRI instanceIRI) throws UnfoundTerminologyException {
		boolean search = instancesOfTerminology.get(classNameIRI).contains(instanceIRI);
		return search;
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
	
	public IRI getContexte() {
		return contextIRI;
	}

	public Event getEvent() {
		return event;
	}
	
	
	public static void main(String[] args) throws Exception  {
		String sparqlEndpoint = DockerDB.getEndpointIPadress(Endpoints.TERMINOLOGIES);
		TerminologyServer terminoServer = new TerminologyServer(sparqlEndpoint);
		HashMap<IRI, Set<IRI>> instancesOfTerminology = new HashMap<IRI, Set<IRI>>();
		for (TerminoEnum termino : TerminoEnum.values()){
			IRI className = termino.getTermino().getClassNameIRI();
			Set<IRI> instancesIRI = terminoServer.getInstancesOfTerminology(termino);
			instancesOfTerminology.put(className, instancesIRI);
		}
		terminoServer.getCon().close();
		
		// TODO Auto-generated method stub
		//String line = "p1\tSejourMCO\t2017_02_28_23_59_59\thasEnd\t2017_02_28_23_59_59";
		String line = "p1\tSejourMCO\t2017_02_28_23_59_59\tinEtab\t330781360";
		String separator = "\t";
			LineStatement newStatement = new LineStatement(separator,instancesOfTerminology);
			
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
