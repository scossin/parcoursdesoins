package exceptions;

import org.slf4j.Logger;

public class UnfoundDTDFile extends MyExceptions{

	
	public UnfoundDTDFile(Logger logger, String dtdFileName) {
		super(logger,getMessage(dtdFileName));
	}
	
	private static String getMessage(String dtdFileName){
		return("Unfound \""+dtdFileName+"\" dtdFile");
	}

}
