package exceptions;

import org.slf4j.Logger;

public class UnfoundInstanceOfTerminologyException extends MyExceptions{
	
	public UnfoundInstanceOfTerminologyException(Logger logger, String instanceName, String terminologyName){
		super(logger, "\"" + instanceName + "\"" + " instance unfound in terminology : \" " 
	+ terminologyName + "\"" );
}
}
