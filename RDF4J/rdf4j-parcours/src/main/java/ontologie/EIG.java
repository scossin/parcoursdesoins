package ontologie;

import org.eclipse.rdf4j.model.Namespace;
import org.eclipse.rdf4j.model.impl.SimpleNamespace;

/**
 * A class containing static fields to describe the ontology
 * 
 * @author cossin
 *
 */

public class EIG {
	public static final String NAMESPACE = "http://www.eigsante2017.fr#";

	/**
	 * Recommended prefix for my ontology namespace: "eig"
	 */
	public static final String PREFIX = "eig";

	/**
	 * An immutable {@link Namespace} constant that represents the Ontology namespace.
	 */
	public static final Namespace NS = new SimpleNamespace(PREFIX, NAMESPACE);
	
	/**
	 * The name of the class of Events in the Ontology
	 */
	public static final String eventClassName = "Event";
	
	/**
	 * The name of the predicate that number each event of a timeline
	 */
	public static final String hasNum = "hasNum";
}
