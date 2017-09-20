package terminology;

import java.io.IOException;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.rio.datatypes.XMLSchemaDatatypeHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundEventException;
import exceptions.UnfoundTerminologyException;

public class TerminologyInstances {
	
	final static Logger logger = LoggerFactory.getLogger(TerminologyInstances.class);
	
	public static Set<Terminology> terminologies = new HashSet<Terminology>();
	
	static {
		for (TerminoEnum termino : TerminoEnum.values()){
			try {
				terminologies.add(termino.getTermino());
			} catch (RDFParseException | RepositoryException | IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	public static boolean isRecognizedType(IRI typeIRI){ 
		return(TerminologyInstances.isRecognizedClassName(typeIRI) || new XMLSchemaDatatypeHandler().isRecognizedDatatype(typeIRI));
	}
	
	public static boolean isRecognizedClassName(IRI className){
		for (Terminology terminology : terminologies) {
			if (terminology.getMainClassIRI().equals(className)){
				return(true);
			}
		}
		return(false);
	}

	public static Terminology getTerminologyByMainClassIRI(IRI mainClassIRI) throws UnfoundTerminologyException{
		for (Terminology terminology : terminologies) {
			if (terminology.getMainClassIRI().equals(mainClassIRI)){
				return(terminology);
			}
		}
		throw new UnfoundTerminologyException(logger, mainClassIRI.stringValue() + "does not belong to a terminology");
	}
	
	public static Terminology getTerminology(String terminologyName) throws UnfoundTerminologyException{
		for (Terminology terminology : terminologies) {
			if (terminology.getTerminologyName().equals(terminologyName)){
				return(terminology);
			}
		}
		throw new UnfoundTerminologyException(logger, terminologyName + "does not belong to a terminology");
	}
	
	public static Set<IRI> getClassNames() throws RDFParseException, RepositoryException, IOException{
		Set<IRI> classNamesIRI = new HashSet<IRI>();
		for (TerminoEnum terminology : TerminoEnum.values()){
			classNamesIRI.add(terminology.getTermino().getMainClassIRI());
		}
		return(classNamesIRI);
	}
	
	public static void closeConnections(){
		Iterator<Terminology> iter = TerminologyInstances.terminologies.iterator();
		while(iter.hasNext()){
			Terminology terminology = iter.next();
			terminology.getTerminologyServer().getCon().close();
		}
	}
	
	public static void main(String[] args) throws UnfoundTerminologyException, UnfoundEventException{
		for (Terminology terminology : TerminologyInstances.terminologies){
			System.out.println(terminology.getClassName());
		}
		
		Terminology event = TerminologyInstances.getTerminology("Event");
		OneClass aphasie = event.getClassDescription().getClass("SejourMCO");
		Set<IRI> predicatesIRI = event.getClassDescription().getPredicatesOfClass(aphasie);
		for (IRI predicateIRI : predicatesIRI){
			System.out.println(predicateIRI.getLocalName());
		}
		
	}
}
