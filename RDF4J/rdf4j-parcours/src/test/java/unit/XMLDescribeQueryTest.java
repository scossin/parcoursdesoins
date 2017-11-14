package unit;

import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.junit.Test;
import org.xml.sax.SAXException;

import exceptions.InvalidContextException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundFilterException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;
import query.XMLDescribeTimelinesQuery;
import query.XMLFile;

public class XMLDescribeQueryTest {
	
	@Test
	public void testQueryString() throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, InvalidContextException, UnfoundTerminologyException, RDFParseException, RepositoryException, UnfoundFilterException{
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "describeMCO.xml" );
		XMLFile file = new XMLFile(xmlFile);
		XMLDescribeTimelinesQuery describe = new XMLDescribeTimelinesQuery(file);
		System.out.println(describe.getSPARQLQueryString());
		assertTrue(true);
	}
}
