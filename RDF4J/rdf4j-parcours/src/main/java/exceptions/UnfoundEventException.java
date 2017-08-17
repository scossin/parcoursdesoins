package exceptions;

import org.slf4j.Logger;

public class UnfoundEventException extends MyExceptions {
	
	public UnfoundEventException(Logger logger){
		super(logger);
	}


	public UnfoundEventException(Logger logger, String event){
		super(logger, "\"" + event + "\""+ " unfound event");
	}

}
