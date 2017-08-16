package ontologie;

import org.eclipse.rdf4j.model.IRI;

import exceptions.UnfoundTerminologyException;
import parameters.Util;


public class Terminology {
	
	public enum TerminoEnum {

		RPPS(new Terminology("http://esante.gouv.fr#","asip","RPPS")),
		
		// FINESS code is a french terminology for healthcare institution
		FINESS(new Terminology("https://www.data.gouv.fr/FINESS#","datagouv","Etablissement"));
		
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
	
	 public Terminology(String NAMESPACE, String PREFIX, String className){
		 this.NAMESPACE = NAMESPACE;
		 this.PREFIX = PREFIX;
		 this.className = className;
		 //this.NS = new SimpleNamespace(PREFIX, NAMESPACE);
	 }
	
	 public String getPrefix(){
		 return(this.PREFIX);
	 }
	 
	 public String getNAMESPACE(){
		 return(this.NAMESPACE);
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
		throw new UnfoundTerminologyException(className.stringValue() + "does not belong to a terminology");
	}
	
	public IRI makeInstanceIRI (String instanceName){
		return(Util.vf.createIRI(NAMESPACE,className + instanceName));
	}
}
