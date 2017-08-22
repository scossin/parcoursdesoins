package exceptions;

import javax.xml.parsers.ParserConfigurationException;

import org.slf4j.Logger;

public class InvalidXMLFormat extends MyExceptions {
    
	public InvalidXMLFormat(Logger logger, String msg) {
		super(logger, msg);
    } 

}
