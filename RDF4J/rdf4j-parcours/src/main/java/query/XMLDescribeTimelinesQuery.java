package query;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashSet;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import exceptions.InvalidContextException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;
import query.XMLFile.XMLelement;
import servlet.DockerDB.Endpoints;
import terminology.Terminology;

/**
 * The describe event query return predicate and value of a particular event
 * @author cossin
 *
 */
public class XMLDescribeTimelinesQuery extends XMLDescribeQuery implements Query {
	final static Logger logger = LoggerFactory.getLogger(XMLDescribeTimelinesQuery.class);
	
	
	public XMLDescribeTimelinesQuery (XMLFile xml) throws ParserConfigurationException, SAXException, IOException, UnfoundPredicatException, InvalidContextException, UnfoundTerminologyException{
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

	public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, InvalidContextException, UnfoundTerminologyException{
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "describeMCO.xml" );
		XMLFile file = new XMLFile(xmlFile);
		XMLDescribeTimelinesQuery describe = new XMLDescribeTimelinesQuery(file);
		System.out.println(describe.getSPARQLQueryString());
		xmlFile.close();
	}
}
