package terminology;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import parameters.MainResources;
import parameters.Util;
import servlet.DockerDB.Endpoints;

public class Terminology {
	final static Logger logger = LoggerFactory.getLogger(Terminology.class);
	
	private final String NAMESPACE ;

	/**
	 * Recommended prefix for my ontology namespace: "eig"
	 */
	private final String PREFIX ;

	/**
	 * An immutable {@link Namespace} constant that represents my Ontology namespace.
	 */
	//private final Namespace NS ;
	
	/**
	 * Every instance of the terminology is rdf:type <https://www.data.gouv.fr/FINESS#Etablissement>
	 */
	 private String mainClassName ;
	 
	 private String terminologyName ;
	 
	 private String dataFileName ;
	 
	 private String ontologyFileName ; 
	 
	 private Endpoints endpoint ; 
	 
	 private PredicateDescription predicateDescription ; 
	 
	 private ClassDescription classDescription ;
	 
	 private TerminologyServer terminologyServer ;
	 
	 public String getTerminologyName(){
		 return(terminologyName);
	 }
	 
	 public PredicateDescription getPredicateDescription(){
		 return(predicateDescription);
	 }
	 
	 public ClassDescription getClassDescription(){
		 return(classDescription);
	 }
	 
	 public TerminologyServer getTerminologyServer(){
		 return(terminologyServer);
	 }
	 
	 public Terminology(String terminologyName, String NAMESPACE, String PREFIX, String className, String ontologyFileName, 
			 String dataFileName, Endpoints endpoint){
		 this.terminologyName = terminologyName ;
		 this.NAMESPACE = NAMESPACE;
		 this.PREFIX = PREFIX;
		 this.mainClassName = className;
		 this.ontologyFileName = ontologyFileName;
		 this.dataFileName = dataFileName;
		 this.endpoint = endpoint;
	 }
	 
	 public Terminology initialize() throws RDFParseException, RepositoryException, IOException{
		 this.classDescription = new ClassDescription(this);
		 this.predicateDescription = new PredicateDescription(this);
		 this.terminologyServer = new TerminologyServer(this);
		 return(this);
	 }
	 
	 /**
	  * Get all the predicates and expected value (for each predicate) for this class and its parents
	  * @param class An instance of class {@link OneClass}
	  * @return a HashMap : predicateIRI and its associate expected value
	  * @throws UnfoundPredicatException 
	  * @throws UnfoundEventException 
	  */
	 public HashSet<Predicates> getPredicatesOfClass(OneClass oneClass) throws UnfoundEventException, UnfoundPredicatException{
		 HashSet<Predicates> predicates = new HashSet<Predicates>();
		 Set<IRI> predicatesIRI = oneClass.getPredicatesIRI();
		 for (IRI parent : oneClass.getParents()){ // get all parent predicates recursively
			 OneClass parentClass = classDescription.getClass(parent);
			 predicatesIRI.addAll(parentClass.getPredicatesIRI());
		 }
		 
		 for (IRI predicateIRI : predicatesIRI){
			 predicates.add(predicateDescription.getPredicate(predicateIRI));
		 }
		 return(predicates);
	 }
	
	 public boolean isPredicateOfClass (String predicateName, OneClass oneClass) throws UnfoundEventException, UnfoundPredicatException{
		 HashSet<Predicates> predicates = getPredicatesOfClass(oneClass);
		 for (Predicates predicate : predicates){
			 if (predicate.getPredicateIRI().getLocalName().equals(predicateName)){
				 return(true);
			 }
		 }
		 return(false);
	 }
	 
	 public Predicates getOnePredicate(String predicateName, OneClass oneClass) throws UnfoundPredicatException, UnfoundEventException{
		 HashSet<Predicates> predicates = getPredicatesOfClass(oneClass);
		 for (Predicates predicate : predicates){
			 if (predicate.getPredicateIRI().getLocalName().equals(predicateName)){
				 return(predicate);
			 }
		 }
		 throw new UnfoundPredicatException(logger, predicateName);
	 }
	 
	 public Endpoints getEndpoint() {
		 return endpoint;
	 }
	 
	 public String getPrefix(){
		 return(this.PREFIX);
	 }
	 
	 public String getNAMESPACE(){
		 return(this.NAMESPACE);
	 }
	 
	 public String getDataFileName(){
		 return(dataFileName);
	 }
	 
	 public String getOntologyFileName(){
		 return(MainResources.terminologiesFolder + ontologyFileName);
	 }
	 
	/**
	 * Get the class name IRI
	 * @return IRI className
	 */
	public IRI getMainClassIRI(){
		return(Util.vf.createIRI(NAMESPACE,mainClassName));
	}
	
	public String getClassName(){
		return(this.mainClassName);
	}
	
	
	public IRI makeInstanceIRI (String instanceName){
		return(Util.vf.createIRI(NAMESPACE,instanceName));
	}
	
	public static final String terminologiesFolder = MainResources.terminologiesFolder;
}
