package exceptions;

import org.slf4j.Logger;

public class UnfoundClassException extends MyExceptions {
	
	public UnfoundClassException(Logger logger, String className, String terminologyName){
		super(logger, "\"" + terminologyName + "\""+ " unfound class " + className);
	}

}
