package query;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import exceptions.InvalidContextException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundFilterException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;

/**
 * The describe event query return predicate and value of a particular event
 * @author cossin
 *
 */
public class XMLDescribeTimelinesQuery extends XMLDescribeQuery implements Query {
	final static Logger logger = LoggerFactory.getLogger(XMLDescribeTimelinesQuery.class);
	
	
	public XMLDescribeTimelinesQuery (XMLFile xml) throws ParserConfigurationException, SAXException, IOException, UnfoundPredicatException, 
	                                                      InvalidContextException, UnfoundTerminologyException, UnfoundEventException, RDFParseException, RepositoryException, UnfoundFilterException {
		super(xml);
		setBasicQuery("SELECT ?context ?event ?predicate ?value WHERE { graph ?context { \n"+
				"VALUES ?event {" +             eventReplacementString                           + "} \n"+
				"VALUES ?predicate {" +             basicReplacementString            +"} . \n" + 
				"?event ?predicate ?value . \n" + 
				"}}") ;
		replacePredicatesValues();
	}
	
	public String[] getVariableNames() {
		// TODO Auto-generated method stub
		String[] variablesNames = {"context","event","predicate","value"};
		return(variablesNames);
	}

	public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, InvalidContextException, UnfoundTerminologyException, RDFParseException, RepositoryException, UnfoundFilterException{
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "describeMCO.xml" );
		XMLFile file = new XMLFile(xmlFile);
		XMLDescribeTimelinesQuery describe = new XMLDescribeTimelinesQuery(file);
		System.out.println(describe.getSPARQLQueryString());
		xmlFile.close();
	}
}
