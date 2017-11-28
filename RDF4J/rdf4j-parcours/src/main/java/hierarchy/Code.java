package hierarchy;

import java.util.LinkedHashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;

import terminology.OneClass;

/**
 * This class represents a code in a terminology. For a example, a ICD-10. 
 * @author cossin
 *
 */

public class Code extends OneClass {

	/**
	 * The label of the code. Ex : I50.20 => Unspecified systolic (congestive) heart failure
	 */
	private String label = null;
	
	/**
	 * A set of children IRI
	 */
	private LinkedHashSet<IRI> children = new LinkedHashSet<IRI>();
	
	/**
	 * A set of parents IRI
	 */
	private LinkedHashSet<IRI> parents = new LinkedHashSet<IRI>();
	
	/**
	 * Number of instances of this code (in a hierarchy, it will be equal to the sum of instances of its children)
	 * Initial value is 0
	 */
	private int number = 0 ;
	
	public LinkedHashSet<IRI> getParents(){
		return(parents);
	}

	
	
	
	/**
	 * Constructor
	 * @param classIRI : IRI of the code in the terminology
	 */
	public Code(IRI classIRI) {
		super(classIRI);
	}
	

	
	/********************************************* setters *************************************/  
	/**
	 * setter
	 * @param parent add a child IRI
	 */
	public void addChild (IRI childIRI){
		children.add(childIRI);
	}
	
	/**
	 * setter
	 * @param parent add a parent IRI
	 */
	public void addParent (IRI parentIRI){
		if (parentIRI != null){
			parents.add(parentIRI);
		} 		
	}
	
	/***
	 * 
	 * @param label set the label of the code
	 */
	public void setLabel(String label){
		this.label = label;
	}
	
	public void setNumber(int number){
		this.number = number;
	}
	
	
	/**************************************** getters *************************************/  
	
	public Set<IRI> getChildren(){
		return(children);
	}
	
	public String getLabel(){
		return(label);
	}
	
	public String getLabelNumber(){
		return(label + " (" + number + ")");
	}
	
	public int getNumber(){
		return(this.number);
	}
	
}
