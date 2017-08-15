package query;

import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
import org.xml.sax.SAXException;

import exceptions.IncomparableValueException;
import exceptions.OperatorException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import integration.DBconnection;
import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;

public class Results {

	private DBconnection con;
	
	public DBconnection getCon(){
		return(con);
	}
	
	private Query query ;
	
	private SimpleDataset dataSet;
	
	public Results (String sparqlEndpoint, Query query){
		this.con = new DBconnection(sparqlEndpoint);
		this.query = query;
	}
	
	public Results (String sparqlEndpoint, Query query, SimpleDataset dataSet){
		this(sparqlEndpoint,query);
		this.dataSet = dataSet;
	}
	
	
	public TupleQueryResult sendQuery(){
		TupleQuery keywordQuery = con.getDBcon().prepareTupleQuery(query.getSPARQLQueryString());
		keywordQuery.setDataset(dataSet);
		TupleQueryResult keywordQueryResult = keywordQuery.evaluate();
		return(keywordQueryResult);
	}
	
	public static void main(String[] args) throws NumberFormatException, ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, ParseException, IncomparableValueException, UnfoundTerminologyException, OperatorException {
		SimpleDataset dataset = new SimpleDataset();
		int n = 10;
		IRI patients[] = new IRI[n];
		for (int i = 0; i<n ; i++){
			String patient_n = "p" + (i+1);
			IRI patient1 = Util.vf.createIRI(EIG.NAMESPACE,patient_n);
			System.out.println(patient1);
			patients[i] = patient1;
			dataset.addNamedGraph(patients[i]);
		}
		
		
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "queryMCOSSR3day.xml" );
		InputStream dtdFile = Util.classLoader.getResourceAsStream(MainResources.dtdFile);
		Query query = new XMLQuery(new XMLFile(xmlFile, dtdFile));
		
		Results results = new Results(Util.sparqlEndpoint,query,dataset);
		TupleQueryResult keywordQueryResult = results.sendQuery();
		while(keywordQueryResult.hasNext()){
			BindingSet set = keywordQueryResult.next();
			IRI context = (IRI) set.getValue("context");
			System.out.println(context.getLocalName());
			break;
		}
		
		keywordQueryResult.close();
		results.getCon().close();
	}
}
