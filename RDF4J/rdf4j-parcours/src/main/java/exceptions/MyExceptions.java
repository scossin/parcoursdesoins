package exceptions;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.slf4j.Logger;

public abstract class MyExceptions extends Exception {

	public MyExceptions(Logger logger){
		logException(logger, this);
	}
	
	public MyExceptions(Logger logger, String msg){
		logMessage(logger, msg);
		logException(logger, this);
	}
	
	public static void logMessage(Logger logger, String msg){
		logger.error(msg);
	}
	
	/*
	public void logThisException(Logger logger){
		StringWriter sw = new StringWriter();
		this.printStackTrace(new PrintWriter(sw));
		String exceptionDetails = sw.toString();
		logger.error(exceptionDetails);
	}*/
	
	public static void logException(Logger logger, Exception e){
		StringWriter sw = new StringWriter();
		e.printStackTrace(new PrintWriter(sw));
		String exceptionDetails = sw.toString();
		logger.error(exceptionDetails);
	}
}
