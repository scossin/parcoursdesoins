package queryFiles;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.vocabulary.RDFS;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.sail.memory.MemoryStore;

import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;

public class GetComments implements FileQuery{

	
	public final static String fileName = "comments.csv";
	private final static String MIMEtype = "text/csv";
	private final static String ontologyFileName = MainResources.ontologyFileName;
	
	public String getFileName(){
		return(fileName);
	}
	
	public String getMIMEtype(){
		return(MIMEtype);
	}
	
	private static HashMap<String, String> predicateComment = new HashMap<String, String>();
	
	public void addPredicateComment(String predicateName, String comment) {
		predicateComment.put(predicateName, comment);
	}
	
	private void setComment() throws RDFParseException, RepositoryException, IOException{
		InputStream ontologyInput = Util.classLoader.getResourceAsStream(ontologyFileName);
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		RepositoryConnection ontologyCon = rep.getConnection();
		ontologyCon.add(ontologyInput, EIG.NAMESPACE, RDFFormat.TURTLE);
		RepositoryResult<Statement> values = ontologyCon.getStatements(null, RDFS.COMMENT, null);
		while(values.hasNext()){
			Statement statement = values.next();
			IRI predicateIRI = (IRI) statement.getSubject();
			if (predicateIRI.getNamespace().equals(EIG.NAMESPACE)){
				String comment = statement.getObject().stringValue();
				predicateComment.put(predicateIRI.getLocalName(), comment);
			}
		}
		ontologyInput.close();
		ontologyCon.close();
		rep.shutDown();
	}
	
	public GetComments() throws IOException{
		setComment();
	}
	
	public void sendBytes(OutputStream os) throws IOException{
		StringBuilder line = new StringBuilder();
		//header
		line.append("predicate");
		line.append("\t");
		line.append("comment");
		line.append("\n");
		os.write(line.toString().getBytes());
		line.setLength(0);
		
		for (String predicateName : predicateComment.keySet()){
			line.append(predicateName);
			line.append("\t");
			line.append(predicateComment.get(predicateName));
			line.append("\n");
			os.write(line.toString().getBytes());
			line.setLength(0);
		}
	}
}
