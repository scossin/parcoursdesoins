package exceptions;

import javax.xml.parsers.ParserConfigurationException;

public class InvalidXMLFormat extends ParserConfigurationException {
    
	public InvalidXMLFormat(String msg) {
		super(msg);
    } 

}
