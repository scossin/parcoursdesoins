package integration;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Model;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.impl.LinkedHashModel;
import org.eclipse.rdf4j.model.vocabulary.XMLSchema;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.rio.Rio;
import org.eclipse.rdf4j.sail.memory.MemoryStore;

public class TimelineFile {
	
	private final static Repository rep ; 
	private final static RepositoryConnection con;
	private static Model model;
	
	private static void modelInitialize(){
		model = new LinkedHashModel();
		model.setNamespace(TIME.PREFIX, TIME.NAMESPACE);
		model.setNamespace(EIG.PREFIX, EIG.NAMESPACE);
		model.setNamespace(XMLSchema.PREFIX, XMLSchema.NAMESPACE);
		model.setNamespace(FINESS.PREFIX, FINESS.NAMESPACE);
	}
	
	static {
		rep = new SailRepository(new MemoryStore());
		rep.initialize();
		con = rep.getConnection();
		modelInitialize();
	}
	
	// add RDF triples from disk file if file already exists
	public static void addTriplesInFile(IRI contextIRI, Model newModel) throws RDFParseException, RepositoryException, IOException{
		model.addAll(newModel); 	
		File file = new File(Util.timelinesFolder + "/" + contextIRI.getLocalName() + ".ttl");
		if (file.exists()){
			con.add(file, EIG.NAMESPACE, RDFFormat.TURTLE,contextIRI);
			RepositoryResult<Statement> statementsContext = con.getStatements(null, null, null);
			while(statementsContext.hasNext()){
				Statement nextStatement = statementsContext.next();
				model.add(nextStatement); // duplicates are not added, no need to check				
			}
		}
		try{
			FileOutputStream out = new FileOutputStream(file);
			Rio.write(model, out, RDFFormat.TURTLE);
			System.out.println(file.getName() + " successfully created/updated");
		} finally{
			model.clear(); // clear the model for the next call
			con.clear(); // clear the Repository Connection for the next call
		}
	}

}
