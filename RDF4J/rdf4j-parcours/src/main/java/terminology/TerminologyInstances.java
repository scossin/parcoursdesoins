package terminology;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import exceptions.IncomparableValueException;
import exceptions.InvalidContextException;
import exceptions.UnfoundClassException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundFilterException;
import exceptions.UnfoundInstanceOfTerminologyException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import integration.CheckInstances;
import parameters.MainResources;
import parameters.Util;
import servlet.Initialize;

public class TerminologyInstances {
	
	final static Logger logger = LoggerFactory.getLogger(TerminologyInstances.class);
	
	public static Set<Terminology> terminologies = new HashSet<Terminology>();
	
	static {
		URL urlXMLfile = Util.classLoader.getResource(MainResources.terminologiesFolder + MainResources.terminologyFileXMLname);
		File xmlFile = new File(urlXMLfile.getFile());
		
		URL urlDTDfile = Util.classLoader.getResource(MainResources.terminologiesFolder + MainResources.terminologyFileDTDname);
		File dtdFile = new File(urlDTDfile.getFile());
		
		TerminologyXML terminologyXML = null;
		try {
			terminologyXML = new TerminologyXML(xmlFile,dtdFile);
			terminologies = terminologyXML.getTerminologies();
		} catch (InvalidContextException | UnfoundEventException | ParserConfigurationException | SAXException
				| IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public static Terminology getTerminologyByMainClassIRI(IRI mainClassIRI) throws UnfoundTerminologyException{
		for (Terminology terminology : terminologies) {
			if (terminology.getMainClassIRI().equals(mainClassIRI)){
				return(terminology);
			}
		}
		throw new UnfoundTerminologyException(logger, mainClassIRI.stringValue() + " does not belong to a terminology");
	}
	
	public static Terminology getTerminology(String terminologyName) throws UnfoundTerminologyException{
		for (Terminology terminology : terminologies) {
			if (terminology.getTerminologyName().equals(terminologyName)){
				return(terminology);
			}
		}
		throw new UnfoundTerminologyException(logger, terminologyName + " does not belong to a terminology");
	}
	
	public static Set<IRI> getClassNames() throws RDFParseException, RepositoryException, IOException{
		Set<IRI> classNamesIRI = new HashSet<IRI>();
		for (Terminology terminology : terminologies){
			classNamesIRI.add(terminology.getMainClassIRI());
		}
		return(classNamesIRI);
	}
	
	public static void closeConnections() throws RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		Iterator<Terminology> iter = TerminologyInstances.terminologies.iterator();
		while(iter.hasNext()){
			Terminology terminology = iter.next();
			terminology.closeConnection();
		}
	}
	
	public static void main(String[] args) throws Exception{
//		System.out.println("Initializing");
//		new Initialize().init();
		
		
		for (Terminology terminology : TerminologyInstances.terminologies){
			if (!terminology.getTerminologyName().equals("Graph")){
				continue;
			}
			terminology.getTerminologyServer().countInstances();
			terminology.getTerminologyServer().loadTerminology();
			terminology.getTerminologyServer().countInstances();
			terminology.closeConnection();
		}
		
		
		
//		Terminology terminology = TerminologyInstances.getTerminology("Graph");
//		terminology.getTerminologyServer().countInstances();
//		terminology.getTerminologyServer().loadTerminology();
//		terminology.closeConnection();
		//System.out.println(terminology.getClassName());
		
//		Terminology event = TerminologyInstances.getTerminology("Event");
//		OneClass aphasie = event.getClassDescription().getClass("SejourMCO");
//		Set<IRI> predicatesIRI = event.getClassDescription().getPredicatesOfClass(aphasie);
//		for (IRI predicateIRI : predicatesIRI){
//			System.out.println(predicateIRI.getLocalName());
//		}
		
	}
}
