package queryFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Iterator;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Literal;
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
import terminology.Terminology.TerminoEnum;

public class GetPredicateDescription implements FileQuery{

	public enum ValueCategory {
		NUMERIC, DURATION, DATE, FACTOR, TERMINOLOGY, SPATIALPOLYGON;
	}
	
	public final static String fileName = "predicatesDescription.csv";
	private final static String MIMEtype = "text/csv";
	
	public String getFileName(){
		return(fileName);
	}
	
	public String getMIMEtype(){
		return(MIMEtype);
	}
	
	private HashMap<IRI, Predicates> predicates = new HashMap<IRI, Predicates>();
	
	public HashMap<IRI, Predicates> getPredicates(){
		return(predicates);
	}
	
	
	private void setPredicates(RepositoryConnection ontologyCon){
		// Predicates : 
		RepositoryResult<Statement> values = ontologyCon.getStatements(null, RDFS.RANGE, null);
		while(values.hasNext()){
			Statement statement = values.next();
			IRI predicateIRI = (IRI) statement.getSubject();
			//if (predicateIRI.getNamespace().equals(EIG.NAMESPACE)){
				if (!predicates.containsKey(predicateIRI)){
					predicates.put(predicateIRI, new Predicates(predicateIRI));
				}
				Value value = statement.getObject();
				predicates.get(predicateIRI).setValue(value);
			//}
		}
		values.close();
	}
	
	
	
	private void setPredicateComment(RepositoryConnection ontologyCon){
		RepositoryResult<Statement> values = ontologyCon.getStatements(null, RDFS.COMMENT, null);
		while(values.hasNext()){
			Statement statement = values.next();
			IRI predicateIRI = (IRI) statement.getSubject();
			if (predicates.containsKey(predicateIRI)){
				Literal comment = (Literal) statement.getObject();
				predicates.get(predicateIRI).addComment(comment);
			}
		}
		values.close();
	}
	
	private void setPredicateLabel(RepositoryConnection ontologyCon){
		RepositoryResult<Statement> values = ontologyCon.getStatements(null, RDFS.LABEL, null);
		while(values.hasNext()){
			Statement statement = values.next();
			IRI predicateIRI = (IRI) statement.getSubject();
			if (predicates.containsKey(predicateIRI)){
				Literal label = (Literal) statement.getObject();
				predicates.get(predicateIRI).addLabel(label);
			}
		}
		values.close();
	}
	
	private void setValueCategory(){
		Iterator<Predicates> iter = getPredicates().values().iterator();
		while(iter.hasNext()){
			Predicates predicate = iter.next();
			predicate.setValueCategory(getValueCategory(predicate.getPredicateIRI(), predicate.getExpectedValue()));
		}
	}
	
	public String getComments(){
		StringBuilder line = new StringBuilder();
		//header
		line.append("predicate");
		line.append("\t");
		line.append("comment");
		line.append("\t");
		line.append("lang");
		line.append("\n");
		
		Iterator<Predicates> iter = getPredicates().values().iterator();
		while (iter.hasNext()){
			Predicates predicate = iter.next();
			for (Literal comment : predicate.getComments()){
				line.append(predicate.getPredicateIRI().getLocalName());
				line.append("\t");
				line.append(comment.stringValue());
				line.append("\t");
				line.append(comment.getLanguage().orElse(""));
				line.append("\n");
			}
		}
		return(line.toString());
	}
	
	public String getLabels(){
		StringBuilder line = new StringBuilder();
		//header
		line.append("predicate");
		line.append("\t");
		line.append("label");
		line.append("\t");
		line.append("lang");
		line.append("\n");
		
		Iterator<Predicates> iter = getPredicates().values().iterator();
		while (iter.hasNext()){
			Predicates predicate = iter.next();
			for (Literal label : predicate.getLabels()){
				line.append(predicate.getPredicateIRI().getLocalName());
				line.append("\t");
				line.append(label.stringValue());
				line.append("\t");
				line.append(label.getLanguage().orElse(""));
				line.append("\n");
			}
		}
		return(line.toString());
	}
	
	public String getCategory(){
		StringBuilder line = new StringBuilder();
		//header
		line.append("predicate");
		line.append("\t");
		line.append("category");
		line.append("\t");
		line.append("value");
		line.append("\n");
		
		Iterator<Predicates> iter = getPredicates().values().iterator();
		while (iter.hasNext()){
			Predicates predicate = iter.next();
			String category = predicate.getCategory().toString();
			Value value = predicate.getExpectedValue();
			IRI expectedValue =  (IRI) value;
			line.append(predicate.getPredicateIRI().getLocalName());
			line.append("\t");
			line.append(category);
			line.append("\t");
			line.append(expectedValue.getLocalName());
			line.append("\n");
		}
		return(line.toString());
	}
	
	public GetPredicateDescription(TerminoEnum terminoEnum) throws IOException{
		String path = MainResources.terminologiesFolder + terminoEnum.getTermino().getOntologyFileName();
		InputStream ontologyInput = Util.classLoader.getResourceAsStream(path);
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		RepositoryConnection ontologyCon = rep.getConnection();		
		ontologyCon.add(ontologyInput, terminoEnum.getTermino().getNAMESPACE(), RDFFormat.TURTLE);
		
		setPredicates(ontologyCon);
		setPredicateComment(ontologyCon);
		setPredicateLabel(ontologyCon);
		setValueCategory();
		
		ontologyInput.close();
		ontologyCon.close();
		rep.shutDown();
	}
	
	private ValueCategory getValueCategory (IRI predicateIRI, Value value){
		IRI valueIRI = (IRI) value;
		
		if (predicateIRI.equals(EIG.HASPOLYGON)){
			return(ValueCategory.SPATIALPOLYGON);
		}
		
		if (XMLDatatypeUtil.isNumericDatatype(valueIRI)){
			// Special case : 
			if (predicateIRI.equals(EIG.HASDURATION)){
				return(ValueCategory.DURATION);
			}
			return(ValueCategory.NUMERIC);
		}
		
		if (XMLDatatypeUtil.isCalendarDatatype(valueIRI)){
			return(ValueCategory.DATE);
		}

		if (Terminology.isRecognizedClassName(valueIRI)){
			return(ValueCategory.TERMINOLOGY);
		}
		return(ValueCategory.FACTOR); // default
	}
	
	public void sendBytes(OutputStream os) throws IOException{
		os.write(getComments().getBytes());
		os.write("DATAFRAMESEPARATOR".getBytes());
		os.write(getLabels().getBytes());
		os.write("DATAFRAMESEPARATOR".getBytes());
		os.write(getCategory().getBytes());
	}
	
	public static void main(String[] args) throws IOException{
		GetPredicateDescription comments = new GetPredicateDescription(TerminoEnum.EVENTS);
		File file = new File("commentaires.csv");
		OutputStream os = new FileOutputStream(file);
		comments.sendBytes(os);
		os.close();
	}
	
}
