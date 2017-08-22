package terminology;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;


public class Terminology {
	final static Logger logger = LoggerFactory.getLogger(Terminology.class);
	
	public enum TerminoEnum {

		RPPS(new Terminology("http://esante.gouv.fr#","asip","RPPS","RPPS.ttl")),
		
		// FINESS code is a french terminology for healthcare institution
		FINESS(new Terminology("https://www.data.gouv.fr/FINESS#","datagouv","Etablissement","FINESS.ttl"));
		
		private Terminology terminology;
		
		private TerminoEnum(Terminology terminology){
			this.terminology = terminology;
		}
		
		public Terminology getTermino(){
			return(terminology);
		}
	}
	
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
	 private String className ;
	 
	 private String fileName ;
	
	 public Terminology(String NAMESPACE, String PREFIX, String className, String fileName){
		 this.NAMESPACE = NAMESPACE;
		 this.PREFIX = PREFIX;
		 this.className = className;
		 this.fileName = fileName;
		 //this.NS = new SimpleNamespace(PREFIX, NAMESPACE);
	 }
	
	 public String getPrefix(){
		 return(this.PREFIX);
	 }
	 
	 public String getNAMESPACE(){
		 return(this.NAMESPACE);
	 }
	 
	 public String getFileName(){
		 return(fileName);
	 }
	 
	/**
	 * Get the class name IRI
	 * @return IRI className
	 */
	public IRI getClassNameIRI(){
		return(Util.vf.createIRI(NAMESPACE,className));
	}
	
	public static boolean isRecognizedClassName(IRI className){
		for (TerminoEnum enumTermino : TerminoEnum.values()) {
			if (enumTermino.getTermino().getClassNameIRI().equals(className)){
				return(true);
			}
		}
		return(false);
	}
	
	public static Terminology getTerminology(IRI className) throws UnfoundTerminologyException{
		for (TerminoEnum enumTermino : TerminoEnum.values()) {
			if (enumTermino.getTermino().getClassNameIRI().equals(className)){
				return(enumTermino.getTermino());
			}
		}
		throw new UnfoundTerminologyException(logger, className.stringValue() + "does not belong to a terminology");
	}
	
	public static Set<IRI> getClassNames(){
		Set<IRI> classNamesIRI = new HashSet<IRI>();
		for (TerminoEnum terminology : TerminoEnum.values()){
			classNamesIRI.add(terminology.getTermino().getClassNameIRI());
		}
		return(classNamesIRI);
	}
	
	public IRI makeInstanceIRI (String instanceName){
		return(Util.vf.createIRI(NAMESPACE,className + instanceName));
	}
	
	public static final String terminologiesFolder = MainResources.terminologiesFolder;
}
