package terminology;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.vocabulary.RDFS;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.sail.memory.MemoryStore;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import parameters.Util;

public class ClassDescription {

	
	final static Logger logger = LoggerFactory.getLogger(ClassDescription.class);

	/**
	 * A list of {@link OneClass} describing each class of the ontology/terminology
	 */
	private HashSet<OneClass> classes = new HashSet<OneClass>() ;
	
	private String terminologyNS;
	private String mainClassName;
	
	public boolean isClassName(String className){
		IRI classIRI = Util.vf.createIRI(terminologyNS, className);
		return(isClassName(classIRI));
	}
	
	public boolean isClassName(IRI classIRI){
		Iterator<OneClass> iter = classes.iterator();
		while (iter.hasNext()){
			OneClass oneClass = iter.next();
			boolean check = oneClass.getClassIRI().equals(classIRI);
			if (check){
				return(true);
			}
		}
		return(false);
	}
	
	/**
	 * Retrieve the instance of class {@link OneClass} with the IRI of the class
	 * @param classIRI The IRI of the class
	 * @return an instance of class {@link OneClass}
	 * @throws UnfoundEventException if the class is not in the ontology
	 */
	public OneClass getClass(IRI classIRI) throws UnfoundEventException{
		Iterator<OneClass> iter = classes.iterator();
		while (iter.hasNext()){
			OneClass classe = iter.next();
			boolean check = classe.getClassIRI().equals(classIRI);
			if (check){
				return(classe);
			}
		}
		throw new UnfoundEventException (logger, classIRI.getLocalName()) ;
	}
	
	/**
	 * Overload method of getClass 
	 * @param className The localName of the IRI of the class
	 * @return An instance of class {@link OneClass}
	 * @throws UnfoundEventException if the class is not in the ontology
	 */
	public OneClass getClass(String className) throws UnfoundEventException{
		IRI classIRI = Util.vf.createIRI(terminologyNS, className);
		return(getClass(classIRI));
	}
	
	/**
	 * Get all predicates of an class : look for this class predicates and its parent predicates
	 * @param class An instance of class {@link OneClass}
	 * @return A set of predicates IRI
	 * @throws UnfoundEventException 
	 */
	public Set<IRI> getPredicatesOfClass(OneClass classe) throws UnfoundEventException{
		Set<IRI> predicates = new HashSet<IRI>();
		predicates.addAll(classe.getPredicatesIRI());
		for (IRI parent : classe.getParents()){ // get all parent predicates recursively
			    OneClass parentClass = getClass(parent);
				Set<IRI> predicatessparents = getPredicatesOfClass(parentClass);
				predicates.addAll(predicatessparents);
		}
		return(predicates);
	}
	
	/**
	 * Search the predicateIRI from a list of predicatesValue. It's a way to check if a predicate belongs to an class.
	 * @param predicateName The localName of the IRI predicate
	 * @param predicatesValue An association of predicateIRI and expected value
	 * @return the predicateIRI 
	 * @throws UnfoundPredicatException If the predicate doesn't belong to this predicatesValue
	 */
	public IRI getPredicateIRI(String predicateName, Map<IRI, Value> predicatesValue) throws UnfoundPredicatException{
		for (IRI unIRI : predicatesValue.keySet()){
			if (unIRI.getLocalName().equals(predicateName)){
				return(unIRI);
			}
		}
		throw new UnfoundPredicatException(logger, predicateName);
	}
	
	/**
	 * Get all the subClassOf of an class IRI in the ontology
	 * @param con A connection to a repository
	 * @param classIRI an classIRI
	 * @return A set of classIRI
	 */
	private static Set<IRI> getSubClassOfClass(RepositoryConnection con, IRI classIRI){
		Set<IRI> subClassIRI = new HashSet<IRI>(); 
		RepositoryResult<Statement> statements = con.getStatements(null, RDFS.SUBCLASSOF, classIRI);
		while(statements.hasNext()){
			Statement stat = statements.next();
			IRI subIRI = (IRI)stat.getSubject();
			subClassIRI.add(subIRI);
			subClassIRI.addAll(getSubClassOfClass(con, subIRI)); // get children recursively
		}
		statements.close();
		return(subClassIRI);
	}
	
	private static HashSet<IRI> getSusClassOfClass(RepositoryConnection con, IRI classIRI){
		HashSet<IRI> subClassIRI = new HashSet<IRI>(); 
		RepositoryResult<Statement> statements = con.getStatements(classIRI, RDFS.SUBCLASSOF, null);
		while(statements.hasNext()){
			Statement stat = statements.next();
			IRI subIRI = (IRI)stat.getObject();
			subClassIRI.add(subIRI);
			subClassIRI.addAll(getSusClassOfClass(con, subIRI)); // get children recursively
		}
		statements.close();
		return(subClassIRI);
	}
	
	private void addClasses(RepositoryConnection con, Set<IRI> classesIRI){
		// Step 3 : create a new Instance of class OneClass for each classIRI
		for (IRI oneIRI : classesIRI){
			System.out.println(oneIRI);
			OneClass classe = new OneClass(oneIRI); 			

			RepositoryResult<Statement> statements = con.getStatements(null, RDFS.DOMAIN, oneIRI);
			while(statements.hasNext()){
				Statement stat = statements.next();
				System.out.println("\t predicate : " + stat.getSubject().stringValue());
				IRI predicateIRI = (IRI)stat.getSubject();
				classe.addPredicateIRI(predicateIRI);
			}
			statements.close();

			// Step 5 : list all parents of each class
			HashSet<IRI> parentsIRI = getSusClassOfClass(con,oneIRI);
			for (IRI parent : parentsIRI){
				classe.addParent(parent);
				System.out.println("\t parents : " + parent.getLocalName());
			}
			classes.add(classe);
		} // close loop
	}
	
	public ClassDescription(Terminology terminology) throws RDFParseException, RepositoryException, IOException{
		terminologyNS = terminology.getNAMESPACE();
		mainClassName = terminology.getClassName();
		
		// File containing the model : 
		String pathOntolgoy = terminology.getOntologyFileName();
		logger.info("loading " + pathOntolgoy);
		InputStream ontologyInput = Util.classLoader.getResourceAsStream(pathOntolgoy);
		
		// p RDF triple in memory : 
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		RepositoryConnection con = rep.getConnection();
		con.add(ontologyInput, terminologyNS, Util.DefaultRDFformat);
		ontologyInput.close();
		
		// list all classes rdf:SubClassOf of the main className 
		Set<IRI> classesIRI = new HashSet<IRI>();
		IRI classIRI = Util.vf.createIRI(terminologyNS,mainClassName);
		classesIRI.add(classIRI); // main className
		classesIRI.addAll(getSubClassOfClass(con, classIRI)); // allSubClassOf
		addClasses(con,classesIRI); // describing the class
		con.close();
		rep.shutDown();
	}
}
