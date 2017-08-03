package integration;

import org.eclipse.rdf4j.model.Namespace;
import org.eclipse.rdf4j.model.impl.SimpleNamespace;

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
	
}
