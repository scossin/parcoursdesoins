package exceptions;

import org.eclipse.rdf4j.model.IRI;

public class UnfoundTerminologyException extends Exception {
	
	public UnfoundTerminologyException(IRI terminology){
		super("\"" + terminology.getNamespace() + "\"" + " non trouvé dans la liste des terminologies");
}
}
