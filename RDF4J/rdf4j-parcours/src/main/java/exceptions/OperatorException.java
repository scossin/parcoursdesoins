package exceptions;

import org.slf4j.Logger;

public class OperatorException extends MyExceptions {
	public OperatorException(Logger logger, String msg){
		super(logger, msg);
	}
}
