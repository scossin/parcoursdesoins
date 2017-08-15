package ontologie;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Namespace;
import org.eclipse.rdf4j.model.ValueFactory;
import org.eclipse.rdf4j.model.impl.SimpleNamespace;
import org.eclipse.rdf4j.model.impl.SimpleValueFactory;

/**
 * Constants for TIME ontology and for the TIME namespace.
 * @author cossin
 *
 */
public class TIME {
	/** http://www.w3.org/1999/02/22-rdf-syntax-ns# */
	public static final String NAMESPACE = "http://www.w3.org/2006/time#";

	/**
	 * Recommended prefix for the TIME Ontology namespace: "time"
	 */
	public static final String PREFIX = "time";

	/**
	 * An immutable {@link org.eclipse.rdf4j.model.Namespace} constant that represents the TIME Ontology namespace.
	 */
	public static final Namespace NS = new SimpleNamespace(PREFIX, NAMESPACE);
	
	/** http://www.w3.org/2006/time#Interval */
	public static final IRI INTERVAL;
	
	/** http://www.w3.org/2006/time#Instant */
	public static final IRI INSTANT;

	/** http://www.w3.org/2006/time#hasBeginning */
	public static final IRI HASBEGINNING;
	 
	/** http://www.w3.org/2006/time#hasEnd */
	public static final IRI HASEND;

	/** http://www.w3.org/2006/time#inXSDDateTime */
	public static final IRI INXSDDATETIME;

	/**
	 * 2 predicates of the TimeOntology to describe time attributes of the events
	 */
	public static IRI[] timePredicates ;
	
	/**
	 * Check if the predicate name match a time predicate of the TimeOntology
	 * @param predicateName
	 * @return true if match
	 */
	public static boolean isRecognizedTimePredicate(String predicateName){
		
		for (IRI timePredicat : timePredicates){
			if (predicateName.equals(timePredicat.getLocalName())){
				return(true);
			}
		}
		return(false);
	}
		
	static {
		ValueFactory factory = SimpleValueFactory.getInstance();
		INTERVAL = factory.createIRI(TIME.NAMESPACE, "Interval");
		INSTANT = factory.createIRI(TIME.NAMESPACE, "Instant");
		HASBEGINNING = factory.createIRI(TIME.NAMESPACE, "hasBeginning");
		HASEND = factory.createIRI(TIME.NAMESPACE, "hasEnd");
		INXSDDATETIME = factory.createIRI(TIME.NAMESPACE, "inXSDDateTime");
		timePredicates = new IRI[] {TIME.HASBEGINNING, TIME.HASEND};
	}
}
