package hierarchy;

import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;

import terminology.OneClass;

public class Code extends OneClass {

	private String label = null;
	
	private Set<IRI> children = new LinkedHashSet<IRI>();
	
	private int number = 0 ;
	
	public Code(IRI classIRI) {
		super(classIRI);
	}
	
	private Set<IRI> parents = new LinkedHashSet<IRI>();
	/**
	 * setter
	 * @param parent A parent IRI of this class
	 */
	public void addChild (IRI childIRI){
		children.add(childIRI);
	}
	
	public void addParent (IRI parentIRI){
		if (parentIRI != null){
			parents.add(parentIRI);
		} 		
	}
	
	public Set<IRI> getChildren(){
		return(children);
	}
	
	public void setLabel(String label){
		this.label = label;
	}
	
	public String getLabel(){
		return(label);
	}
	
	public String getLabelNumber(){
		return(label + " (" + number + ")");
	}
	
	public void setNumber(int number){
		this.number = number;
	}
	
	public int getNumber(){
		return(this.number);
	}
	
}
