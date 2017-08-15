package query;

import java.io.File;
import java.io.IOException;
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
	
	private XMLQuery queryClass ;
	
	private SimpleDataset dataSet;
	
	public Results (String sparqlEndpoint, XMLQuery queryClass){
		this.con = new DBconnection(sparqlEndpoint);
		this.queryClass = queryClass;
	}
	public Results (String sparqlEndpoint, XMLQuery queryClass, SimpleDataset dataSet){
		this(sparqlEndpoint,queryClass);
		this.dataSet = dataSet;
	}
	
	public TupleQueryResult sendQuery(){
		TupleQuery keywordQuery = con.getDBcon().prepareTupleQuery(queryClass.getSPARQLQueryString());
		keywordQuery.setDataset(dataSet);
		TupleQueryResult keywordQueryResult = keywordQuery.evaluate();
		return(keywordQueryResult);
	}
	
	public static void main(String[] args) throws NumberFormatException, ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, ParseException, IncomparableValueException, UnfoundTerminologyException, OperatorException {
		SimpleDataset dataset = new SimpleDataset();
		int n = 1;
		IRI patients[] = new IRI[n];
		for (int i = 0; i<n ; i++){
			String patient_n = "p" + (i+1);
			IRI patient1 = Util.vf.createIRI(EIG.NAMESPACE,patient_n);
			System.out.println(patient1);
			patients[i] = patient1;
			dataset.addNamedGraph(patients[i]);
		}
		
		
		XMLQuery queryClass = new XMLQuery(new File(MainResources.queryFolder+"queryMCOSSRafter.xml"));
		Results results = new Results(Util.sparqlEndpoint,queryClass,dataset);
		TupleQueryResult keywordQueryResult = results.sendQuery();
		while(keywordQueryResult.hasNext()){
			BindingSet set = keywordQueryResult.next();
			System.out.println("resultat : " + set.getValue("context"));
			break;
		}
	}

}
