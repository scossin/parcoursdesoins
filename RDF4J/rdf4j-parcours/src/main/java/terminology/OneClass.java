package terminology;

import java.util.HashSet;
import java.util.Set;
import org.eclipse.rdf4j.model.IRI;

/**
 * 
 * 
 * This class represents the Class class in the ontology. An class is a child in a parent-child hierarchy. 
 * Each class has one or many attributes and inherits his parents'attributes. 
 * 
 * @author cossin
 */

public class OneClass {
	
	/**
	 * A combination of a Namespace and name of the class
	 */
	
	private IRI classIRI;
	
	/**
	 * List of attributes and values of the class
	 */
	
	private Set<IRI> predicatesIRI = new HashSet<IRI>();
	
	/**
	 * List of parents in the ontology hierarchy
	 */
	
	private Set<IRI> parents = new HashSet<IRI>();
	
	/**
	 * Construct an Class object 
	 * @param classIRI : a combination of a Namespace and name of the class
	 */
	
	public OneClass (IRI classIRI){
		this.classIRI = classIRI;
	}
	
	/**
	 * getter
	 * @return the IRI of this class
	 */
	
	public IRI getClassIRI(){
		return(classIRI);
	}
	
	/**
	 * getter
	 * @return predicates of this class
	 */
	
	public Set<IRI> getPredicatesIRI(){
		return(predicatesIRI);
	}
	
	/**
	 * setter
	 * @param parent A parent IRI of this class
	 */
	public void addParent (IRI parent){
		parents.add(parent);
	}
	
	/**
	 * 
	 * @return The list of parents IRI of this class
	 */
	public Set<IRI> getParents(){
		return(parents);
	}

	public void addPredicateIRI(IRI predicateIRI) {
		predicatesIRI.add(predicateIRI);
	}
	
}
