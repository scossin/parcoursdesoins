package query;

import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import exceptions.IncomparableValueException;
import exceptions.InvalidContextException;
import exceptions.InvalidXMLFormat;
import exceptions.OperatorException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;
import query.XMLFile.XMLelement;
import servlet.DockerDB.Endpoints;
import terminology.Predicates;
import terminology.Terminology;


/**
 * A class to produce SPARQL query to search events and links between events. <br>
 * The XML file is handled by {@link XMLFile}. <br>
 * The events elements of the XML query are handled by {@link ClassInXMLfile}
 * @author cossin
 *
 */
public class XMLSearchQueryTimeLines extends XMLSearchQuery implements Query {

	final static Logger logger = LoggerFactory.getLogger(XMLSearchQueryTimeLines.class);
	
	/**
	 * 
	 * @param xmlFile A user query XML file well formed and validated against a DTD file
	 * @throws ParserConfigurationException
	 * @throws SAXException
	 * @throws IOException
	 * @throws UnfoundEventException
	 * @throws UnfoundPredicatException
	 * @throws ParseException
	 * @throws NumberFormatException
	 * @throws IncomparableValueException
	 * @throws UnfoundTerminologyException
	 * @throws OperatorException 
	 * @throws InvalidContextException 
	 * @throws InvalidXMLFormat 
	 */
	public XMLSearchQueryTimeLines(XMLFile xmlFile) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, ParseException, NumberFormatException, IncomparableValueException, UnfoundTerminologyException, OperatorException, InvalidContextException, InvalidXMLFormat{
		super(xmlFile);
	}
	
	public String[] getVariableNames() {
		ArrayList<String> eventNumber = new ArrayList<String>();
		eventNumber.add("context");
		for (int numberEvent : eventQuery.keySet()){
			eventNumber.add("event" + numberEvent);
		}
		return(eventNumber.toArray(new String[eventNumber.size()]));
	}
	
	/**
	 * Add the numbering of this oneClass in the timeline in the SPARQL statement where (ex : ?oneClass0 hasNum ?oneClass0hasNum)
	 * It's only used to order the results. 
	 */
	private void setHasNumStatement (){
		for (ClassInXMLfile classInXMLfile : eventQuery.values()){
			String numVariable = classInXMLfile.getVariableName(EIG.HASNUM.getLocalName()) ; 
			classInXMLfile.addWhereStatement(classInXMLfile.getOneClassVariable(), Query.formatIRI4query(EIG.HASNUM), 
					numVariable);
		}

	}
	
	/**
	 * main function of this class : return a SPARQL query String
	 * @return a SPARQL query string
	 */
	public String getSPARQLQueryString(){
		setHasNumStatement();
		
		String queryString = "";
		
		   // Select Statements
		String part1 = "SELECT ?context ";
		
  	      // ?event0hasNum : the event number in the timeline
		for (int numberEvent : eventQuery.keySet()){
			part1 += "?event" + numberEvent + " "; // ?event0
			part1 += "?event" + numberEvent + EIG.HASNUM.getLocalName() + " "; 
		}
		queryString += part1 ; 
		
		// Where Statements
		String part2 = " WHERE {graph ?context { \n";
		part2 += mergeWhereStatements();
		
		// Bind variables :
		for(String statement : getBindStatements()){
			part2 += statement + "\n";
		}
		
		// Filter of events statement :
		part2 += mergeFilterStatements();
		
		// Filter of bind variables :
		for(String statement : getFilterStatements()){
			part2 += statement + "\n";
		}

		part2 += "}}\n";
		
		queryString += part2;
		
		
		// Order by : 
		queryString += "ORDER BY ?context ";
		
		// and numEvent : 
		for (int numberEvent : eventQuery.keySet()){
			queryString += "?event" + numberEvent + EIG.HASNUM.getLocalName() + " "; // ?event0hasNum : the event number in the timeline
		}
		
		return(queryString);
	}
	
	public static void main(String[] args) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, ParseException, NumberFormatException, IncomparableValueException, UnfoundTerminologyException, OperatorException, InvalidContextException, InvalidXMLFormat {
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "queryMCOSSR3day.xml" );
		XMLSearchQueryTimeLines queryClass = new XMLSearchQueryTimeLines(new XMLFile(xmlFile));
		System.out.println(queryClass.getSPARQLQueryString());
	}

}
