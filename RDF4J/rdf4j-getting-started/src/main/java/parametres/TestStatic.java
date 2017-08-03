package parametres;
import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.rio.datatypes.XMLSchemaDatatypeHandler;

import exceptions.UnfoundEventException;
import integration.Util;

public class TestStatic {

	public static void main(String[] args) throws UnfoundEventException {
		// TODO Auto-generated method stub
		
		
		String localNameEvent = "SejourMCO";
		/*
		Event SejourMCO = Ontologie.getEvent(localNameEvent);
		if (SejourMCO == null){
			System.out.println(localNameEvent + " n'a été pas récupéré via la méthode String");
		} else {
			System.out.println(localNameEvent + " a été récupéré via la méthode String");
		}
		
		IRI eventIRI = Ontologie.vf.createIRI(Global.monOntologieIRI, localNameEvent);
		SejourMCO = Ontologie.getEvent(eventIRI);
		if (SejourMCO == null){
			System.out.println(localNameEvent + " n'a été pas récupéré via la méthode IRI");
		} else {
			System.out.println(localNameEvent + " a été récupéré via la méthode IRI");
		}
		
		Set<IRI> predicats = Ontologie.getPredEvent(SejourMCO);
		System.out.println("prédicats de " + localNameEvent + " :");
		for (IRI pred : predicats){
			System.out.println("\t" + pred.getLocalName());
		}
		*/
		
		/*
		Event SejourMCO = Ontologie.getEvent(localNameEvent);
		Map<IRI, Value> predsValue = Ontologie.getPredsValueEvent(SejourMCO);
		for (Value val : predsValue.values()){
			
			
		}
		*/ 
		String iri = "http://www.w3.org/2001/XMLSchema#integer";
		IRI test = Util.vf.createIRI(iri);
		XMLSchemaDatatypeHandler xmlschema = new XMLSchemaDatatypeHandler();
		if (xmlschema.isRecognizedDatatype(test)) {
			System.out.println("oui, datatype connu");
			xmlschema.normalizeDatatype("10", test, Util.vf);
		} else {
			System.out.println("non");
		}
		
		//IRI predicatIRI = Ontologie.getPredIRI(predicat, predsValue);

	}

}
