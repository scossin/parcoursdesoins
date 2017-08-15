package ontologie;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Namespace;
import org.eclipse.rdf4j.model.impl.SimpleNamespace;

import parameters.MainResources;
import parameters.Util;

public class FINESS {
	public static final String NAMESPACE = "https://www.data.gouv.fr/FINESS#";

	/**
	 * Recommended prefix for my ontology namespace: "eig"
	 */
	public static final String PREFIX = "datagouv";

	/**
	 * An immutable {@link Namespace} constant that represents my Ontology namespace.
	 */
	public static final Namespace NS = new SimpleNamespace(PREFIX, NAMESPACE);
	
	/**
	 * Every instance of the terminology is rdf:type <https://www.data.gouv.fr/FINESS#Etablissement>
	 */
	public static final String className = "Etablissement";
	
	/**
	 * Get the class name IRI
	 * @return IRI className
	 */
	public static IRI getClassNameIRI(){
		return(Util.vf.createIRI(NAMESPACE,className));
	}
	
}
