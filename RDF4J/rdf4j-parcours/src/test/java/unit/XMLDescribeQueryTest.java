package unit;

import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.ParserConfigurationException;

import org.junit.Test;
import org.xml.sax.SAXException;

import exceptions.InvalidContextException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;
import query.XMLDescribeTimelinesQuery;
import query.XMLFile;

public class XMLDescribeQueryTest {
	
	@Test
	public void testQueryString() throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, InvalidContextException, UnfoundTerminologyException{
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "describeMCO.xml" );
		XMLFile file = new XMLFile(xmlFile);
		XMLDescribeTimelinesQuery describe = new XMLDescribeTimelinesQuery(file);
		System.out.println(describe.getSPARQLQueryString());
		assertTrue(true);
	}
}
