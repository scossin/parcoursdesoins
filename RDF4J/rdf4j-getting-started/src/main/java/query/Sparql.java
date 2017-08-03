package query;

/*
 *  Interroger un sparqle endpoint + ajouter le contexte
 * 
 */

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Resource;
import org.eclipse.rdf4j.model.ValueFactory;
import org.eclipse.rdf4j.model.impl.SimpleValueFactory;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.sparql.SPARQLRepository;

public class Sparql {
	
	
	public static void main(String[] args) {
		String sparqlEndpoint = "http://127.0.0.1:8889/bigdata/namespace/timelines/sparql";
		Repository repo = new SPARQLRepository(sparqlEndpoint);
		repo.initialize();
		String patientNamespace = "http://127.0.0.1:8889/bigdata/namespace/timelines/";
		String namespace = "http://www.eigsante2017.fr/CNTROavc#";

		ValueFactory vf = SimpleValueFactory.getInstance();
		// IRI for patient1
		

		
		try {
			RepositoryConnection con = repo.getConnection();
			// query : 
			String keyword = "AppelCentre15";
			TupleQuery keywordQuery = con.prepareTupleQuery(""
					+ "SELECT ?resource WHERE  "
					+ "{ ?resource a ?type . } LIMIT 1");
			
			
			SimpleDataset dataset = new SimpleDataset();
			int n = 12;
			IRI patients[] = new IRI[n];
			for (int i = 11; i<n ; i++){
				String patient_n = "patient" + (i+1);
				//System.out.println(patient_n);
				IRI patient1 = vf.createIRI(patientNamespace,patient_n);
				System.out.println(patient1);
				patients[i] = patient1;
				dataset.addDefaultGraph(patients[i]);
			}
			
			keywordQuery.setDataset(dataset);
			
			keywordQuery.setBinding("type", vf.createIRI(namespace,keyword));
			System.out.println(keywordQuery.toString());
			
			// We then evaluate the prepared query and can process the result:
			TupleQueryResult keywordQueryResult = keywordQuery.evaluate();
			while(keywordQueryResult.hasNext()){
				BindingSet set = keywordQueryResult.next();
				System.out.println("resultat : " + set.getValue("resource"));
			}


	} finally{
		repo.shutDown();
	}
	}
}

