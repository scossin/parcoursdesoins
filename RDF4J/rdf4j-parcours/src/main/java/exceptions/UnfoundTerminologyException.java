package exceptions;

import org.eclipse.rdf4j.model.IRI;

public class UnfoundTerminologyException extends Exception {
	
	public UnfoundTerminologyException(String terminologyName){
		super("\"" + terminologyName + "\"" + " non trouvé dans la liste des terminologies");
}
}
