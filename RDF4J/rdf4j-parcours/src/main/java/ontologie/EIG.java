package ontologie;

import java.io.File;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Namespace;
import org.eclipse.rdf4j.model.ValueFactory;
import org.eclipse.rdf4j.model.impl.SimpleNamespace;
import org.eclipse.rdf4j.model.impl.SimpleValueFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.InvalidContextException;
import exceptions.InvalidContextFormatException;
import parameters.Util;

/**
 * A class containing static fields to describe the ontology
 * 
 * @author cossin
 *
 */

public class EIG {
	final static Logger logger = LoggerFactory.getLogger(EIG.class);
	
	public static final String NAMESPACE = "http://www.eigsante2017.fr#";

	
	public static final String TerminologyName = "Event";
	
	/**
	 * Recommended prefix for my ontology namespace: "eig"
	 */
	public static final String PREFIX = "eig";

	/**
	 * An immutable {@link Namespace} constant that represents the Ontology namespace.
	 */
	public static final Namespace NS = new SimpleNamespace(PREFIX, NAMESPACE);
	
	/**
	 * The name of the class of Events in the Ontology
	 */
	public static final String eventClassName = "Event";
	
	/** http://www.eigsante2017.fr#hasNum  : number each event of a timeline */
	public static final IRI HASNUM;
	
	/** http://www.eigsante2017.fr#hasDuration  : time duration of event of a timeline */
	public static final IRI HASDURATION;
	
	/** http://www.eigsante2017.fr#hasPolygon  : a reference to a spatial polygon */
	public static final IRI HASPOLYGON;

	/** http://www.eigsante2017.fr#hasType  : original type of event */
	public static final IRI HASTYPE ;
	
	public static final IRI HASNEXT;
	
	public static final String GRAPH;
	
	public static final IRI HASBEGINNING;
	public static final IRI HASEND;
	
	public static final IRI HASCOORDINATE;
	
	static {
		ValueFactory factory = SimpleValueFactory.getInstance();
		HASBEGINNING = factory.createIRI(EIG.NAMESPACE, "hasBeginning");
		HASEND = factory.createIRI(EIG.NAMESPACE, "hasEnd");
		HASNUM = factory.createIRI(EIG.NAMESPACE, "hasNum");
		HASDURATION = factory.createIRI(EIG.NAMESPACE, "hasDuration");
		HASTYPE = factory.createIRI(EIG.NAMESPACE, "hasType");
		HASPOLYGON = factory.createIRI(EIG.NAMESPACE, "hasPolygon");
		HASCOORDINATE = factory.createIRI(EIG.NAMESPACE, "hasCoordinate");
		HASNEXT = factory.createIRI(EIG.NAMESPACE, "hasNext");
		GRAPH = "Graph";
	}
	
	/**
	 * Check if the context String is correct and return the IRI of the context (named graph)
	 * @param contextName A string of the context localName (ex : p20)
	 * @return an IRI of the contextName in the namespace of my ontology
	 * @throws InvalidContextException if contextName is not valid
	 */
	public static IRI getContextIRI(String contextName) throws InvalidContextException{
		if (Util.isValidContextName(contextName)){
			IRI contextIRI = Util.vf.createIRI(EIG.NAMESPACE, contextName);
			return contextIRI;
		} else {
			throw new InvalidContextException(logger, contextName);
		}
	}
	
	public static IRI getContextIRI (File file) throws InvalidContextFormatException{
	if (Util.isValidContextFileFormat(file)){
		String context = file.getName().replaceAll(Util.fileExtensionRegex, "");
		IRI contextIRI = Util.vf.createIRI(EIG.NAMESPACE, context);
		return contextIRI;
	} else {
		throw new InvalidContextFormatException(logger, file.getName());
	}
}
}
