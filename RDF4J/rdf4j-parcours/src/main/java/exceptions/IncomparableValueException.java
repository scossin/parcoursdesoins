package exceptions;

import org.slf4j.Logger;

public class IncomparableValueException extends MyExceptions {
	public IncomparableValueException(Logger logger, String msg){
		super(logger, msg);
	}
}
