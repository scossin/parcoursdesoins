package query;

import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.query.impl.SimpleDataset;
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
import servlet.DockerDB;
import servlet.DockerDB.Endpoints;

public class XMLCountQuery implements Query {

	private XMLFile xml;
	private String sparqlQuery;
	public XMLCountQuery(XMLFile xml){
		this.xml = xml;
		setSparqlQuery();
	}
	
	private void setSparqlQuery(){
		// Assuming the ontology sparqlEndpoint is in the same DB
		String queryString = "SELECT ?event (count(?s) as ?count) WHERE { GRAPH ?context { ?s a ?event . \n"+
				"SERVICE serviceURL { \n" +
				"?event a ?o . \n" + 
				"FILTER(regex(str(?event)," +
				" \"NAMESPACE\"" + 
				"))\n}}} \n" + 
				"group by ?event \n" ;
		String serviceURL = "<http://127.0.0.1:8080" + Endpoints.ONTOLOGY.getURL() + ">";
		String namespace = EIG.NAMESPACE;
		queryString = queryString.replaceAll("serviceURL", serviceURL);
		queryString = queryString.replaceAll("NAMESPACE", namespace);
		this.sparqlQuery = queryString;
	}
	public String getSPARQLQueryString() {
		return(sparqlQuery);
	}

	@Override
	public SimpleDataset getContextDataset() {
		return(xml.getContextDataSet());
	}

	public String[] getVariableNames() {
		String[] variablesNames = {"event","count"};
		return variablesNames;
	}

	public static void main (String[] args) throws NumberFormatException, UnfoundEventException, UnfoundPredicatException, IncomparableValueException, UnfoundTerminologyException, OperatorException, InvalidContextException, InvalidXMLFormat, ParserConfigurationException, SAXException, IOException, ParseException{
		//QueryClass queryClass = new QueryClass(new File(Util.queryFolder+"queryMCOSSR3day.xml"));
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "describeMCO.xml" );
		XMLFile xml = new XMLFile(xmlFile);
		Query query = new XMLCountQuery(xml);
		System.out.println(query.getSPARQLQueryString());
		System.out.println(xml.getContextDataSet().hashCode());
		Results result = new Results(DockerDB.getEndpointIPadress(Endpoints.TIMELINES),query);
		result.serializeResult();
	}
}

/**
// * SELECT ?eventType ?p (count(?p) as ?count) ?comment WHERE { 
//  ?s a ?eventType .
//  ?s ?p ?o .
//SERVICE <http://127.0.0.1:8080/bigdata/namespace/ontology/sparql> { 
//?p rdfs:comment ?comment .
//FILTER(regex(str(?p), "http://www.eigsante2017.fr#"))
//}}
//GROUP BY ?eventType ?p ?comment
 */
 
