package queryFiles;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.datatypes.XMLDatatypeUtil;
import org.eclipse.rdf4j.model.vocabulary.RDFS;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.sail.memory.MemoryStore;

import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;
import terminology.Terminology;

public class GetComments implements FileQuery{

	public enum ValueCategory {
		NUMERIC, DATE, FACTOR, TERMINOLOGY;
	}
	
	public final static String fileName = "predicatesDescription.csv";
	private final static String MIMEtype = "text/csv";
	private final static String ontologyFileName = MainResources.ontologyFileName;
	
	public String getFileName(){
		return(fileName);
	}
	
	public String getMIMEtype(){
		return(MIMEtype);
	}
	
	private Set<IRI> predicates = new HashSet<IRI>();
	
	private HashMap<IRI, String> predicateComment = new HashMap<IRI, String>();
	
	private HashMap<IRI, Value> predicateValue = new HashMap<IRI, Value>();
	
	public void addPredicateComment(IRI predicate, String comment) {
		predicateComment.put(predicate, comment);
	}
	
	public void addPredicateValue (IRI predicate, Value value) {
		predicateValue.put(predicate, value);
	}
	
	private void setPredicatesValue(RepositoryConnection ontologyCon){
		// Predicates : 
		RepositoryResult<Statement> values = ontologyCon.getStatements(null, RDFS.RANGE, null);
		while(values.hasNext()){
			Statement statement = values.next();
			IRI predicateIRI = (IRI) statement.getSubject();
			if (predicateIRI.getNamespace().equals(EIG.NAMESPACE)){
				predicates.add(predicateIRI);
				Value value = statement.getObject();
				predicateValue.put(predicateIRI,value);
			}
		}
		values.close();
	}
	
	private void setPredicateComment(RepositoryConnection ontologyCon){
		RepositoryResult<Statement> values = ontologyCon.getStatements(null, RDFS.COMMENT, null);
		while(values.hasNext()){
			Statement statement = values.next();
			IRI predicateIRI = (IRI) statement.getSubject();
			if (predicates.contains(predicateIRI)){
				String comment = statement.getObject().stringValue();
				predicateComment.put(predicateIRI, comment);
			}
		}
		values.close();
	}
	
	public GetComments() throws IOException{
		InputStream ontologyInput = Util.classLoader.getResourceAsStream(ontologyFileName);
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		RepositoryConnection ontologyCon = rep.getConnection();		
		ontologyCon.add(ontologyInput, EIG.NAMESPACE, RDFFormat.TURTLE);
		
		setPredicatesValue(ontologyCon);
		setPredicateComment(ontologyCon);
		
		ontologyInput.close();
		ontologyCon.close();
		rep.shutDown();
	}
	
	private ValueCategory getValueCategory (Value value){
		IRI valueIRI = (IRI) value;
		if (XMLDatatypeUtil.isCalendarDatatype(valueIRI)){
			return(ValueCategory.DATE);
		}
		if (XMLDatatypeUtil.isNumericDatatype(valueIRI)){
			return(ValueCategory.NUMERIC);
		}
		if (Terminology.isRecognizedClassName(valueIRI)){
			return(ValueCategory.TERMINOLOGY);
		}
		return(ValueCategory.FACTOR); // default
	}
	
	public void sendBytes(OutputStream os) throws IOException{
		//EventOntology.is
		
		StringBuilder line = new StringBuilder();
		//header
		line.append("predicate");
		line.append("\t");
		line.append("comment");
		line.append("\t");
		line.append("valueCategory");
		line.append("\t");
		line.append("valueType");
		line.append("\n");
		os.write(line.toString().getBytes());
		line.setLength(0);
		
		for (IRI predicateIRI : predicates){
			line.append(predicateIRI.getLocalName());
			line.append("\t");
			line.append(predicateComment.get(predicateIRI));
			line.append("\t");
			ValueCategory category = getValueCategory(predicateValue.get(predicateIRI));
			line.append(category);
			line.append("\t");
			line.append(predicateValue.get(predicateIRI).stringValue());
			line.append("\n");
			os.write(line.toString().getBytes());
			line.setLength(0);
		}
	}
}
