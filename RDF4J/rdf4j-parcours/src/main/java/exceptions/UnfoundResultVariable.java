package exceptions;

import org.slf4j.Logger;

import query.Query;

public class UnfoundResultVariable extends MyExceptions  {
	public UnfoundResultVariable(Logger logger, String variable, Query query){
		super(logger, getMessage(variable,query));
	}
	
	private static String getMessage (String variable, Query query){
		String message = "Unfound " + variable + " in query result \n";
		message = message + query.getSPARQLQueryString();
		return(message);
	}
}
