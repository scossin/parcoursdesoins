//package ontologie;
//
//import java.util.HashMap;
//import java.util.HashSet;
//import java.util.Map;
//import java.util.Set;
//import org.eclipse.rdf4j.model.IRI;
//import org.eclipse.rdf4j.model.Value;
//import org.eclipse.rdf4j.model.vocabulary.OWL;
//
///**
// * 
// * 
// * This class represents the Event class in the ontology. An event is a child in a parent-child hierarchy. 
// * Each event has one or many attributes and inherits his parents'attributes. 
// * 
// * @author cossin
// */
//
//
//public class Event {
//	
//	/**
//	 * A combination of a Namespace and name of the event
//	 */
//	
//	private IRI eventIRI;
//	
//	/**
//	 * List of attributes and values of the event
//	 */
//	
//	private HashMap<IRI, Value> predicateValue = new HashMap<IRI, Value>() ;
//	
//	/**
//	 * OWL distinguishes between two main categories of properties that an ontology builder may want to define:
//	 * Object properties link individuals to individuals
//	 * Datatype properties link individuals to data values.
//	 */
//	
//	private HashMap<IRI, Boolean> predicateIsDataType = new HashMap<IRI,Boolean>() ;
//	
//	
//	/**
//	 * List of parents in the ontology hierarchy
//	 */
//	
//	private Set<IRI> parents = new HashSet<IRI>();
//	
//	/**
//	 * Construct an Event object 
//	 * @param eventIRI : a combination of a Namespace and name of the event
//	 */
//	
//	public Event (IRI eventIRI){
//		this.eventIRI = eventIRI;
//	}
//	
//	/**
//	 * getter
//	 * @return the IRI of this event
//	 */
//	
//	public IRI getEventIRI(){
//		return(eventIRI);
//	}
//	
//	/**
//	 * getter
//	 * @return attributes and values of this event
//	 */
//	
//	public HashMap<IRI, Value> getPredicateValue(){
//		return(predicateValue);
//	}
//	
//	/**
//	 * getter 
//	 * @return List of predicates of this event and boolean isDatatype
//	 */
//	public HashMap<IRI, Boolean> getPredicateIsDataType(){
//		return(predicateIsDataType);
//	}
//	
//	/**
//	 * setter
//	 * @param predicate A predicate (IRI) of this event
//	 * @param value The corresponding value expected (datatype, resource...)
//	 */
//
//	public void addPredicateValue(IRI predicate, Value value){
//		predicateValue.put(predicate, value);
//	}
//	
//	/**
//	 * 
//	 * @param predicateIRI A predicate (IRI) of this event
//	 * @param isDataType true if this predicate is a Datatype properties
//	 */
//	public void addPredicateIsDataType(IRI predicateIRI, boolean isDataType){
//		predicateIsDataType.put(predicateIRI, isDataType);
//	}
//	
//	/**
//	 * setter
//	 * @param parent A parent IRI of this event
//	 */
//	public void addParent (IRI parent){
//		parents.add(parent);
//	}
//	
//	/**
//	 * 
//	 * @return The list of parents IRI of this event
//	 */
//	public Set<IRI> getParents(){
//		return(parents);
//	}
//	
//	/**
//	 * 
//	 * @return the list of attributes/predicates of this event
//	 */
//	public Set<IRI> getPredicates(){
//		Set<IRI> preds = predicateValue.keySet();
//		return preds;
//	}
//}
