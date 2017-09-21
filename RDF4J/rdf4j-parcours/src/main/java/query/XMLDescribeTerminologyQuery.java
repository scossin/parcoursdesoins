package query;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.ParserConfigurationException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import exceptions.InvalidContextException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;

/**
 * The describe event query return predicate and value of a particular event
 * @author cossin
 *
 */
public class XMLDescribeTerminologyQuery extends XMLDescribeQuery implements Query {
	final static Logger logger = LoggerFactory.getLogger(XMLDescribeTerminologyQuery.class);
	
	public XMLDescribeTerminologyQuery (XMLFile xml) throws ParserConfigurationException, SAXException, IOException, UnfoundPredicatException, InvalidContextException, UnfoundTerminologyException, UnfoundEventException{
		super(xml);
		setBasicQuery("SELECT ?event ?predicate ?value WHERE { \n"+
		"VALUES ?event {" +             eventReplacementString                           + "} \n"+
		"VALUES ?predicate {" +             basicReplacementString            +"} . \n" + 
		"?event ?predicate ?value . \n" + 
		"}") ;
		replacePredicatesValues();
	}
	
	/**
	 * The list of variable for the XML describe query : 
	 * <ul>
	 * <li> ?event : the event instance
	 * <li> ?predicate : the predicateIRI
	 * <li> ?value : datatype or object
	 * <ul>
	 */
	public String[] getVariableNames() {
		// TODO Auto-generated method stub
		String[] variablesNames = {"event","predicate","value"};
		return(variablesNames);
	}

	public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, InvalidContextException, UnfoundTerminologyException{
		//InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "describeMCO.xml" );
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "XMLquerydescribeTerminologyFINESSlong.xml" );
		//InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "XMLquerydescribeSpatialPoint.xml" );
		
		XMLFile file = new XMLFile(xmlFile);
		XMLDescribeTerminologyQuery describe = new XMLDescribeTerminologyQuery(file);
		System.out.println(describe.getSPARQLQueryString());
		xmlFile.close();
	}

}
