package exceptions;

import org.eclipse.rdf4j.model.IRI;
import org.slf4j.Logger;

public class UnfoundFilterException extends MyExceptions {
	
	public UnfoundFilterException(Logger logger, String filterName, IRI predicateIRI){
		super(logger, "\"" + filterName + "\""+ " not authorized filterName (described for : " + predicateIRI.stringValue()
		+ ")");
	}
}
