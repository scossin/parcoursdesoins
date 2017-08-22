package exceptions;

import org.slf4j.Logger;

public class UnfoundInstanceOfTerminologyException extends MyExceptions{
	
	public UnfoundInstanceOfTerminologyException(Logger logger, String instanceName, String terminologyName){
		super(logger, getMessage(instanceName,terminologyName));
	}


	private static String getMessage (String instanceName,String terminologyName){
		String message = "\"" + instanceName + "\"" + " instance unfound in terminology : \" " 
				+ terminologyName + "\"" ;
		return(message);
	}
}
