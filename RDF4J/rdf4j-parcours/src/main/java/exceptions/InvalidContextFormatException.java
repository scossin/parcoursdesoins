package exceptions;

import org.slf4j.Logger;

public class InvalidContextFormatException extends InvalidContextException{

	public InvalidContextFormatException(Logger logger, String fileName){
		super(logger,fileName);
	}
}
