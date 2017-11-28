package terminology;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.sail.memory.MemoryStore;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundEventException;
import exceptions.UnfoundFilterException;
import exceptions.UnfoundPredicatException;
import hierarchy.GetTreeJsHierarchy;
import hierarchy.Hierarchy;
import parameters.MainResources;
import parameters.Util;
import servlet.Endpoint;

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
	 
	 private Endpoint endpoint ; 
	 
	 private PredicateDescription predicateDescription ; 
	 
	 private ClassDescription classDescription ;
	 
	 private TerminologyServer terminologyServer ;
	 
	 private Hierarchy hierarchy;
	 
	 private File terminologyFolder ; 
	 
	 private File ontologyFile ;
	 
	 private Repository rep ; 
	 private RepositoryConnection ontologyCon;
	 
	 public RepositoryConnection getOntologyCon(){
		 return(ontologyCon);
	 }
	 
	 private File instancesFile = null ;

	 public File getInstancesFile(){
		 return(instancesFile);
	 }
	 
	 private boolean isInitialized = false;
	 
	 public String getTerminologyName(){
		 return(terminologyName);
	 }
	 
	 public PredicateDescription getPredicateDescription() throws RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		 checkInitialization();
		 return(predicateDescription);
	 }
	 
	 public ClassDescription getClassDescription() throws RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		 checkInitialization();
		 return(classDescription);
	 }
	 
	 public TerminologyServer getTerminologyServer() throws RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		 checkInitialization();
		 return(terminologyServer);
	 }
	 
	 public Hierarchy getHierarchy() throws RDFParseException, RepositoryException, UnfoundFilterException, IOException{
		 checkInitialization();
		 return(hierarchy);
	 }
	 
	 public void closeConnection() throws RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		 if (!isInitialized){
			 return;
		 }
		 getOntologyCon().close();
		 rep.shutDown();
		 getTerminologyServer().getCon().close();
	 }
	 
	 public Terminology(String terminologyName, String NAMESPACE, String PREFIX, String className, String ontologyFileName, 
			 String dataFileName, Endpoint endpoint) throws IOException{
		 this.terminologyName = terminologyName ;
		 this.NAMESPACE = NAMESPACE;
		 this.PREFIX = PREFIX;
		 this.mainClassName = className;
		 this.ontologyFileName = ontologyFileName;
		 this.dataFileName = dataFileName;
		 this.endpoint = endpoint;
		 checkTerminologyDirectory();
		 checkOntologyFile();
		 checkInstancesFile();
	 }
	 
	 public void checkInitialization() throws RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		 if (!isInitialized){
			 logger.info("Initializing " + terminologyName);
			 initialize();
			 this.isInitialized = true;
		 }
	 }
	 
	 private void initialize() throws RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		 rep = new SailRepository(new MemoryStore());
		 rep.initialize();
		 this.ontologyCon = rep.getConnection();
		 logger.info("Connection to ontology... ");
		 ontologyCon.add(ontologyFile, this.NAMESPACE, Util.DefaultRDFformat);
		 logger.info("done");
		 this.classDescription = new ClassDescription(this);
		 this.predicateDescription = new PredicateDescription(this);
		 this.terminologyServer = new TerminologyServer(this);
		 this.hierarchy = new Hierarchy(this);
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
	
	 
	 public boolean isPredicateOfClass (IRI predicateIRI, OneClass oneClass) throws UnfoundEventException, UnfoundPredicatException{
		 HashSet<Predicates> predicates = getPredicatesOfClass(oneClass);
		 for (Predicates predicate : predicates){
			 if (predicate.getPredicateIRI().equals(predicateIRI)){
				 return(true);
			 }
		 }
		 return(false);
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
	 
	 public Endpoint getEndpoint() {
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
	 
	 private void checkTerminologyDirectory() throws IOException{
		 URL urlTerminologies = Util.classLoader.getResource(MainResources.terminologiesFolder);
		 if (urlTerminologies == null){
			 throw new IOException("Unfound terminologies folder in "  + MainResources.terminologiesFolder);
		 }
		 URL urlTerminology = Util.classLoader.getResource(MainResources.terminologiesFolder + terminologyName);
		 if (urlTerminology == null){
			 throw new IOException("Unfound terminology folder : " + terminologyName + " in " + urlTerminologies.toString());
		 }
		 terminologyFolder = new File(urlTerminology.getFile());
	 }
	 
	 private void checkOntologyFile () throws IOException{
		 String pathName = terminologyFolder.getAbsolutePath() + "/" + ontologyFileName ; 
		 File file = new File(pathName);
		 if (!file.isFile()){
			 throw new IOException("Unfound file : " + ontologyFileName + " in " + pathName + " of terminology : " + terminologyName);
		 }
		 this.ontologyFile = file;
	 }
	 
	 private void checkInstancesFile () throws IOException{
		 if (dataFileName.equals("")){
			 return;
		 }
		 String pathName = terminologyFolder.getAbsolutePath() + "/" + dataFileName ; 
		 File file = new File(pathName);
		 if (!file.isFile()){
			 throw new IOException("Unfound file : " + dataFileName + " in " + pathName + " of terminology : " + terminologyName);
		 }
		 instancesFile = file ;
	 }
	 
	 public File getOntologyFile(){
		 return(ontologyFile);
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
	
	public static void main (String[] args) throws IOException{
		new Terminology("Etablissement","https://www.data.gouv.fr/FINESS#","datagouv","Etablissement","FINESS-ontology.owl",
				"FINESS.ttl", new Endpoint("/bigdata/namespace/FINESS/sparql"));
	}
}
