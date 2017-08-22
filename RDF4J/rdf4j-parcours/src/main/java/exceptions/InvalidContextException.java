package exceptions;

import org.slf4j.Logger;

public class InvalidContextException extends MyExceptions{

	public InvalidContextException(Logger logger, String fileName){
		super(logger, getMessage(fileName));
	}
	
	private static String getMessage (String fileName){
		String message = "\"" + fileName + "\""+ " incorrect context file format" ;
		return(message);
	}
}
