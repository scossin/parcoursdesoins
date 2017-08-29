package ontologie;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Namespace;
import org.eclipse.rdf4j.model.ValueFactory;
import org.eclipse.rdf4j.model.impl.SimpleNamespace;
import org.eclipse.rdf4j.model.impl.SimpleValueFactory;

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
	
	/** http://www.eigsante2017.fr#hasNum  : number each event of a timeline */
	public static final IRI HASNUM;
	
	/** http://www.eigsante2017.fr#hasDuration  : time duration of event of a timeline */
	public static final IRI HASDURATION;

	/** http://www.eigsante2017.fr#hasType  : original type of event */
	public static final IRI HASTYPE ;
	
	static {
		ValueFactory factory = SimpleValueFactory.getInstance();
		HASNUM = factory.createIRI(EIG.NAMESPACE, "hasNum");
		HASDURATION = factory.createIRI(EIG.NAMESPACE, "hasDuration");
		HASTYPE = factory.createIRI(EIG.NAMESPACE, "hasType");
	}
}
