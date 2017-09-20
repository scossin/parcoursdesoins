package queryFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Iterator;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Literal;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;

import terminology.PredicateDescription;
import terminology.Predicates;
import terminology.TerminoEnum;
import terminology.Terminology;

public class GetPredicateDescription extends PredicateDescription implements FileQuery{

	public final static String fileName = "predicatesDescription.csv";
	private final static String MIMEtype = "text/csv";
	
	public String getFileName(){
		return(fileName);
	}
	
	public String getMIMEtype(){
		return(MIMEtype);
	}
	
	public GetPredicateDescription(Terminology terminology) throws IOException{
		super(terminology);
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
		
		Iterator<Predicates> iter = getPredicatesMap().values().iterator();
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
		
		Iterator<Predicates> iter = getPredicatesMap().values().iterator();
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
		
		Iterator<Predicates> iter = getPredicatesMap().values().iterator();
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
	
	public void sendBytes(OutputStream os) throws IOException{
		os.write(getComments().getBytes());
		os.write("DATAFRAMESEPARATOR".getBytes());
		os.write(getLabels().getBytes());
		os.write("DATAFRAMESEPARATOR".getBytes());
		os.write(getCategory().getBytes());
	}
	
	public static void main(String[] args) throws RDFParseException, RepositoryException, IOException{
		GetPredicateDescription comments = new GetPredicateDescription(TerminoEnum.EVENTS.getTermino().initialize());
		File file = new File("commentaires.csv");
		OutputStream os = new FileOutputStream(file);
		comments.sendBytes(os);
		os.close();
	}
	
}
