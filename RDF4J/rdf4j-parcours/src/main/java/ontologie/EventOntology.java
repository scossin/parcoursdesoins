package ontologie;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.vocabulary.OWL;
import org.eclipse.rdf4j.model.vocabulary.RDFS;
import org.eclipse.rdf4j.model.vocabulary.XMLSchema;
import org.eclipse.rdf4j.query.BooleanQuery;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.rio.datatypes.XMLSchemaDatatypeHandler;
import org.eclipse.rdf4j.sail.memory.MemoryStore;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;

/**
 * This class represents an ontology of events. 
 * 
 * @author cossin
 *
 */

public class EventOntology {
	
	final static Logger logger = LoggerFactory.getLogger(EventOntology.class);

	
	/**
	 * A list of {@link Event} describing each class of type Event in the Ontology
	 */
	private static HashSet<Event> events ;
	
	public static boolean isEvent(String eventName){
		IRI eventIRI = Util.vf.createIRI(EIG.NAMESPACE, eventName);
		Iterator<Event> iter = events.iterator();
		while (iter.hasNext()){
			Event unEvent = iter.next();
			boolean check = unEvent.getEventIRI().equals(eventIRI);
			if (check){
				return(true);
			}
		}
		return(false);
	}
	
	/**
	 * Retrieve the instance of class {@link Event} with the IRI of the event
	 * @param eventIRI The IRI of the event
	 * @return an instance of class {@link Event}
	 * @throws UnfoundEventException if the event is not in the ontology
	 */
	public static Event getEvent(IRI eventIRI) throws UnfoundEventException{
		Iterator<Event> iter = events.iterator();
		while (iter.hasNext()){
			Event unEvent = iter.next();
			boolean check = unEvent.getEventIRI().equals(eventIRI);
			if (check){
				return(unEvent);
			}
		}
		throw new UnfoundEventException (eventIRI.getLocalName()) ;
	}
	
	/**
	 * Overload method of getEvent 
	 * @param eventName The localName of the IRI of the event
	 * @return An instance of class {@link Event}
	 * @throws UnfoundEventException if the event is not in the ontology
	 */
	public static Event getEvent(String eventName) throws UnfoundEventException{
		IRI eventIRI = Util.vf.createIRI(EIG.NAMESPACE, eventName);
		return(getEvent(eventIRI));
	}
	
	/**
	 * Get all predicates of an event : look for this event predicates and its parent predicates
	 * @param event An instance of class {@link Event}
	 * @return A set of predicates IRI
	 * @throws UnfoundEventException 
	 */
	public static Set<IRI> getPredicatesOfEvent(Event event) throws UnfoundEventException{
		Set<IRI> predicates = new HashSet<IRI>();
		predicates.addAll(event.getPredicates());
		for (IRI parent : event.getParents()){ // get all parent predicates recursively
				Event parentEvent = getEvent(parent);
				Set<IRI> predicatessparents = getPredicatesOfEvent(parentEvent);
				predicates.addAll(predicatessparents);
		}
		return(predicates);
	}
	
	/**
	 * Get all the predicates and expected value (for each predicate) for this event and its parents
	 * @param event An instance of class {@link Event}
	 * @return a HashMap : predicateIRI and its associate expected value
	 */
	public static HashMap<IRI, Value> getPredicatesValueOfEvent(Event event){
		HashMap<IRI, Value> predicatesValue = new HashMap<IRI, Value>();
		predicatesValue.putAll(event.getPredicateValue());
		for (IRI parent : event.getParents()){ // get all parent predicates recursively
			try {
				Event parentEvent = getEvent(parent);
				Map<IRI, Value> predsparents = getPredicatesValueOfEvent(parentEvent);
				predicatesValue.putAll(predsparents);
			} catch (UnfoundEventException e) {
				System.out.println("Unfound parent event : " + e.getMessage());
			}	
		}
		return(predicatesValue);
	}
	
	/**
	 * Get all the predicates and predicateType (true if DataType) for this event and its parents
	 * @param event
	 * @return
	 */
	public static HashMap<IRI, Boolean> getPredicatesIsDataTypeOfEvent(Event event){
		HashMap<IRI, Boolean> predicatesIsDataType = new HashMap<IRI, Boolean>();
		predicatesIsDataType.putAll(event.getPredicateIsDataType());
		for (IRI parent : event.getParents()){ // get all parent predicates recursively
			try {
				Event parentEvent = getEvent(parent);
				Map<IRI, Boolean> predsparents = getPredicatesIsDataTypeOfEvent(parentEvent);
				predicatesIsDataType.putAll(predsparents);
			} catch (UnfoundEventException e) {
				System.out.println("Unfound parent event : " + e.getMessage());
			}	
		}
		return(predicatesIsDataType);
	}
	
	/**
	 * Search the predicateIRI from a list of predicatesValue. It's a way to check if a predicate belongs to an event.
	 * @param predicateName The localName of the IRI predicate
	 * @param predicatesValue An association of predicateIRI and expected value
	 * @return the predicateIRI 
	 * @throws UnfoundPredicatException If the predicate doesn't belong to this predicatesValue
	 */
	public static IRI getPredicateIRI(String predicateName, Map<IRI, Value> predicatesValue) throws UnfoundPredicatException{
		for (IRI unIRI : predicatesValue.keySet()){
			if (unIRI.getLocalName().equals(predicateName)){
				return(unIRI);
			}
		}
		throw new UnfoundPredicatException(predicateName);
	}
	
	public static boolean isPredicateOfEvent (String predicateName, Event event){
		
		if (TIME.isRecognizedTimePredicate(predicateName)){
			return(true);
		}
		
		HashMap<IRI, Value> predicatesValue = getPredicatesValueOfEvent(event);
		for (IRI predicate : predicatesValue.keySet()){
			if (predicate.getLocalName().equals(predicateName)){
				return(true);
			}
		}
		
		return(false);
	}
	public static HashMap<IRI, Value> getOnePredicateValuePair(String predicateName, Event event) throws UnfoundPredicatException{
		HashMap<IRI, Value> predicateValue = new HashMap<IRI, Value>();
		IRI predicateIRI;
		Value value;
		// Time case : 
		if (TIME.isRecognizedTimePredicate(predicateName)){
			value = XMLSchema.DATETIME;
			if (TIME.HASBEGINNING.getLocalName().equals(predicateName)){
				predicateIRI = TIME.HASBEGINNING;
			} else {
				predicateIRI = TIME.HASEND;
			}
			predicateValue.put(predicateIRI, value);
			return(predicateValue);
		} else {
			HashMap<IRI, Value> predicatesValue = getPredicatesValueOfEvent(event);
			predicateIRI = EventOntology.getPredicateIRI(predicateName, predicatesValue);
			value = predicatesValue.get(predicateIRI);
			
			predicateValue.put(predicateIRI, value);
			return(predicateValue);
		}
	}
	
	
	/**
	 * Get all the subClassOf of an event IRI in the ontology
	 * @param con A connection to a repository
	 * @param eventIRI an eventIRI
	 * @return A set of eventIRI
	 */
	private static Set<IRI> getSubClassOfEvent(RepositoryConnection con, IRI eventIRI){
		Set<IRI> subEventIRI = new HashSet<IRI>(); 
		RepositoryResult<Statement> statements = con.getStatements(null, RDFS.SUBCLASSOF, eventIRI);
		while(statements.hasNext()){
			Statement stat = statements.next();
			IRI subIRI = (IRI)stat.getSubject();
			subEventIRI.add(subIRI);
			subEventIRI.addAll(getSubClassOfEvent(con, subIRI)); // get children recursively
		}
		statements.close();
		return(subEventIRI);
	}
	
	private static HashSet<IRI> getSusClassOfEvent(RepositoryConnection con, IRI eventIRI){
		HashSet<IRI> subEventIRI = new HashSet<IRI>(); 
		RepositoryResult<Statement> statements = con.getStatements(eventIRI, RDFS.SUBCLASSOF, null);
		while(statements.hasNext()){
			Statement stat = statements.next();
			IRI subIRI = (IRI)stat.getObject();
			subEventIRI.add(subIRI);
			subEventIRI.addAll(getSusClassOfEvent(con, subIRI)); // get children recursively
		}
		statements.close();
		return(subEventIRI);
	}
	
	
	static {
		HashSet<Event> tempEvents = new HashSet<Event>();
		
		logger.info("loading " + MainResources.ontologyFileName);
		// File containing the model : 
		InputStream ontologyInput = Util.classLoader.getResourceAsStream(MainResources.ontologyFileName);
		
		
		
		// p RDF triple in memory : 
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		RepositoryConnection con = rep.getConnection();
		try {
			con.add(ontologyInput, EIG.NAMESPACE, RDFFormat.TURTLE);
			ontologyInput.close();
		} catch (RDFParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (RepositoryException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		   
		
		// Step 2 : list all classes rdf:SubClassOf eig:Event 
		Set<IRI> eventsIRI = new HashSet<IRI>();
		IRI eventIRI = Util.vf.createIRI(EIG.NAMESPACE,EIG.eventClassName);
		eventsIRI.add(eventIRI); // eig:Event itself
		eventsIRI.addAll(getSubClassOfEvent(con, eventIRI)); // allSubClassOf

		// Step 3 : create a new Instance of class Event for each eventIRI
		for (IRI unIRI : eventsIRI){
			System.out.println(unIRI);
			Event event = new Event(unIRI); 			
			
			// Step 4 : predicates : type and expected value according to the ontology 
			RepositoryResult<Statement> statements = con.getStatements(null, RDFS.DOMAIN, unIRI);
			RepositoryResult<Statement> values;
			while(statements.hasNext()){
				Statement stat = statements.next();
				System.out.print("\t predicate : " + stat.getSubject().stringValue());
				
				IRI predicateIRI = (IRI)stat.getSubject();
				// Ask if predicate is a DataTypeProperty
				String queryString = "ASK { " + "<" + predicateIRI.toString() + "> a <" + OWL.DATATYPEPROPERTY.toString() + ">}";
				BooleanQuery isDataTypeQuery = con.prepareBooleanQuery(queryString);
				boolean isDataType = isDataTypeQuery.evaluate();
				event.addPredicateIsDataType(predicateIRI, isDataType);
				
				values = con.getStatements(predicateIRI, RDFS.RANGE, null);
				if (!values.hasNext()){
					System.out.println("Range not set for " + predicateIRI.stringValue());
				} else {
					Value value = values.next().getObject();
					
					if (!isRecognizedDatatype((IRI)value)){
						System.out.print(" (Datatype inconnu)");
					}
					
					event.addPredicateValue(predicateIRI, value);
					System.out.println("\t" + value.stringValue());
				}
				values.close();
			}
			
			// Step 5 : list all parents of each event
			HashSet<IRI> parentsIRI= getSusClassOfEvent(con,unIRI);
			for (IRI parent : parentsIRI){
				event.addParent(parent);
				System.out.println("\t parents : " + parent.getLocalName());
			}
			
			tempEvents.add(event);

		} // close event loop
		
		events=tempEvents; 
}

	
	public static boolean isRecognizedDatatype(IRI datatypeIRI){ 
		return(Terminology.isRecognizedClassName(datatypeIRI) || new XMLSchemaDatatypeHandler().isRecognizedDatatype(datatypeIRI));
	}
	
}
