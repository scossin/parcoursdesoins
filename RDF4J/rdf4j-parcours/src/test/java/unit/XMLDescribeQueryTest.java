package unit;

import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.ParserConfigurationException;

import org.junit.Test;
import org.xml.sax.SAXException;

import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import parameters.MainResources;
import parameters.Util;
import query.XMLDescribeQuery;
import query.XMLFile;

public class XMLDescribeQueryTest {
	
	@Test
	public void testQueryString() throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException{
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "describeMCO.xml" );
		InputStream dtdFile = Util.classLoader.getResourceAsStream(MainResources.dtdDescribeFile);
		XMLFile file = new XMLFile(xmlFile, dtdFile);
		XMLDescribeQuery describe = new XMLDescribeQuery(file);
		System.out.println(describe.getSPARQLQueryString());
		assertTrue(true);
	}
}
