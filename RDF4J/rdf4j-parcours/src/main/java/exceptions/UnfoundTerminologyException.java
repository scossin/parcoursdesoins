package exceptions;

import org.slf4j.Logger;

public class UnfoundTerminologyException extends MyExceptions {
	
	public UnfoundTerminologyException(Logger logger, String terminologyName){
		super(logger, getMessage(terminologyName));
}
	
	private static String getMessage (String terminologyName){
		String message = "\"" + terminologyName + "\"" + " non trouvé dans la liste des terminologies" ;
		return(message);
	}
}
