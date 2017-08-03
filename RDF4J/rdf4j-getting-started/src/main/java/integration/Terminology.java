package integration;

import org.eclipse.rdf4j.model.IRI;

public interface Terminology {

	public boolean isInstance(String instanceName);
	
	public IRI getTerminologyIRI ();
	
}
