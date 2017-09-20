package unit;

import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;

import javax.xml.parsers.ParserConfigurationException;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.xml.sax.SAXException;

import exceptions.IncomparableValueException;
import exceptions.InvalidContextException;
import exceptions.InvalidXMLFormat;
import exceptions.OperatorException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;
import query.XMLFile;
import query.XMLSearchQueryTimeLines;

public class XMLQueryTest {

	@Rule
	public ExpectedException thrown = ExpectedException.none();
	
	@Test
	public void testDTD() throws ParserConfigurationException, SAXException, IOException, NumberFormatException, UnfoundEventException, UnfoundPredicatException, ParseException, IncomparableValueException, UnfoundTerminologyException, OperatorException, InvalidContextException, InvalidXMLFormat{
		thrown.expect(UnfoundEventException.class);
		
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "UnfoundEvent.xml" );
		XMLFile file = new XMLFile(xmlFile);
		new XMLSearchQueryTimeLines(file);
		xmlFile.close();
	}
}
