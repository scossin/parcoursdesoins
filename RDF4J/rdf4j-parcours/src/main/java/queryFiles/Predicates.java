package queryFiles;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Literal;
import org.eclipse.rdf4j.model.Value;
import org.omg.PortableServer.ServantRetentionPolicyValue;

import queryFiles.GetPredicateDescription.ValueCategory;

public class Predicates{

	private Set<Literal> labels = new HashSet<Literal>();
	private Set<Literal> comments = new HashSet<Literal>();
	private Value expectedValue ;
	boolean isObjectProperty ;
	
	private ValueCategory category;
	
	public  void setValueCategory(ValueCategory category){
		this.category = category;
	}
	
	public ValueCategory getCategory(){
		return(category);
	}
	
	private IRI predicateIRI;
	
	public void addLabel (Literal literal){
		labels.add(literal);
	}
	
	public Set<Literal> getComments(){
		return(comments);
	}
	
	public Set<Literal> getLabels(){
		return(labels);
	}
	
	public void addComment (Literal literal){
		comments.add(literal);
	}
	
	public void setValue (Value value){
		this.expectedValue = value ;
	}
	
	public Value getExpectedValue(){
		return(expectedValue);
	}
	
	public IRI getPredicateIRI(){
		return(predicateIRI);
	}
	
	public Predicates(IRI predicateIRI){
		this.predicateIRI = predicateIRI;
	}
}
