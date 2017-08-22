package exceptions;

import org.slf4j.Logger;

public class UnfoundPredicatException extends MyExceptions  {
	public UnfoundPredicatException(Logger logger, String predicat){
		super(logger, getMessage(predicat));
	}
	
	private static String getMessage (String predicat){
		String message = "\"" + predicat + "\""+ " non trouvé dans la liste des prédicats" ;
		return(message);
	}
}
