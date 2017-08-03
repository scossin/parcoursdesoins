package query;

/*
 * Interroger un fichier local
 */

import java.io.File;
import java.io.IOException;

import org.eclipse.rdf4j.RDF4JException;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.ValueFactory;
import org.eclipse.rdf4j.model.impl.SimpleValueFactory;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.sail.memory.MemoryStore;

public class Localfile {
	
	

	public static void main(String[] args) {
		String fichier = "/home/cossin/Documents/EIG/parcoursdesoins/flux/blazegraph/triplets/timelines/patient1.xml";
		File file = new File(fichier);
		String baseURI = "http://www.eigsante2017.fr";
		ValueFactory vf = SimpleValueFactory.getInstance();
		String namespace = "http://www.eigsante2017.fr/CNTROavc#";

		// 
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		
		try {
			RepositoryConnection con = rep.getConnection();
			try {
				con.add(file, baseURI, RDFFormat.RDFXML);
				RepositoryResult<Statement> statements = con.getStatements(null, null, null);
				while(statements.hasNext()){
					Statement un = statements.next();
					System.out.println(un.getSubject().stringValue());
				}
				statements.close();

				// query : 
				String keyword = "AppelCentre15";
				TupleQuery keywordQuery = con.prepareTupleQuery(""
						+ "SELECT ?resource WHERE { "
						+ "{ ?resource a ?type . }");
				System.out.println(keywordQuery.getClass());
				keywordQuery.setBinding("type", vf.createIRI(namespace,keyword));
				
				
				// We then evaluate the prepared query and can process the result:
				TupleQueryResult keywordQueryResult = keywordQuery.evaluate();
				while(keywordQueryResult.hasNext()){
					BindingSet set = keywordQueryResult.next();
					System.out.println(set.getValue("resource"));
				}
				

			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}		   
			finally {
				con.close();
			}
		}
		
		catch (RDF4JException e) {
		   // handle exception
		}

	}

}
