package exceptions;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.slf4j.Logger;

public class UnfoundEventException extends Exception {
	
	public UnfoundEventException(String event){
		super(event);
		//System.out.println("\"" + event + "\""+ " non trouvé dans la liste des events");
	}
	
	public UnfoundEventException(Logger logger, String event){
		String msg = "\"" + event + "\""+ " non trouvé dans la liste des events";
		  StringWriter sw = new StringWriter();
		  this.printStackTrace(new PrintWriter(sw));
		  String exceptionDetails = sw.toString();
		logger.error(exceptionDetails);
	}

}
