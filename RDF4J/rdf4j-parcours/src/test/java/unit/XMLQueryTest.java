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
import exceptions.OperatorException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;
import query.XMLFile;
import query.XMLSearchQuery;

public class XMLQueryTest {

	@Rule
	public ExpectedException thrown = ExpectedException.none();
	
	@Test
	public void testDTD() throws ParserConfigurationException, SAXException, IOException, NumberFormatException, UnfoundEventException, UnfoundPredicatException, ParseException, IncomparableValueException, UnfoundTerminologyException, OperatorException{
		thrown.expect(UnfoundEventException.class);
		
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "UnfoundEvent.xml" );
		InputStream dtdFile = Util.classLoader.getResourceAsStream(MainResources.dtdSearchFile);
		XMLFile file = new XMLFile(xmlFile, dtdFile);
		new XMLSearchQuery(file);
	}
}
