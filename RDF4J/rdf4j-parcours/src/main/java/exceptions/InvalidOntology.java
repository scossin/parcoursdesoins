package exceptions;

import org.slf4j.Logger;

public class InvalidOntology extends MyExceptions {
	public InvalidOntology(Logger logger, String msg){
		super(logger, msg);
	}
}
