package parameters;

import java.io.File;
import java.nio.charset.Charset;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.ZoneOffset;
import java.util.Date;
import java.util.TimeZone;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Literal;
import org.eclipse.rdf4j.model.ValueFactory;
import org.eclipse.rdf4j.model.datatypes.XMLDatatypeUtil;
import org.eclipse.rdf4j.model.impl.SimpleValueFactory;
import org.eclipse.rdf4j.model.util.LiteralUtilException;
import org.eclipse.rdf4j.model.vocabulary.XMLSchema;
import org.eclipse.rdf4j.rio.RDFFormat;

import exceptions.InvalidContextException;
import exceptions.InvalidContextFormatException;
import integration.DBconnection;
import ontologie.EIG;

/**
 * Static object for this project
 * 
 * @author cossin
 *
 */

public class Util {
	
	/**
	 * To load resources with a classpath relative path
	 */
	public final static ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
	
	/**
	 * The default format of the RDF files. Every timeline file must be in this format
	 */
	public final static RDFFormat DefaultRDFformat = RDFFormat.TURTLE ;
	
	/**
	 * Every timeline filename contains the "context" aka the named graph in the triplestore
	 *  So a valid timeline filename must begin with this pattern expressed as a regex :
	 */
	public final static String contextRegex = "^p[0-9]+$";
	
	/**
	 * Check if a timeline filename is valid. It must end according to the {@link DefaultRDFformat} and 
	 * begin by {@link contextRegex}
	 * @param file A timeline file
	 * @return true if the fileName is a valid timeline file
	 */
	public static boolean isValidContextFileFormat(File file) {
		// remove File extension : 
		String fileName = file.getName();
		String contextName = fileName.replaceAll(Util.fileExtensionRegex, "");
		// check ContextName : 
		return(isValidContextName(contextName));
	}
	
	/**
	 * Check if contextName is valid according to {@link contextRegex}
	 * @param contextName A string of local context name
	 * @return true if the context name is valid
	 */
	public static boolean isValidContextName(String contextName){
		contextName = contextName.replaceAll(Util.contextRegex, "");
		if (contextName.equals("")){
			return(true);
		}
		return(false);
	}
	
	
	/**
	 * timeZone may be used to describe a date as a universal date format
	 */
	public final static TimeZone timeZone = TimeZone.getTimeZone(ZoneOffset.ofOffset("GMT", ZoneOffset.ofHours(1)));
	
	/**
	 * IO functions will use this charset
	 */
	public final static Charset charset = Charset.forName("UTF-8");
	
	/**
	 * An immutable URL to the sparqlEndpoint used by {@link DBconnection}
	 */
	public final static String sparqlEndpoint = "http://127.0.0.1:8889/bigdata/namespace/timelines/sparql";


	/** [.]ttl$ */ 
	public final static String fileExtensionRegex = "[.]" + DefaultRDFformat.getDefaultFileExtension() + "$";
	

	/**
	 * Add the namespace of the ontology used {@link EIG} to a String
	 * @param localName The name of a resource (event, predicate, values) in my ontology
	 * @return an IRI in the namespace of my ontology
	 */
	public static IRI getIRI (String localName){
		IRI myIRI = Util.vf.createIRI(EIG.NAMESPACE, localName);
		return myIRI;
	}
		
	/**
	 * Given the datatypeUri and a literal string (numeric, date...) return a well formatted Literal for RDF statement
	 * @param datatypeUri Must be a primitive or derived datatype. See {@link org.eclipse.rdf4j.model.datatypes.XMLDatatypeUtil#isBuiltInDatatype}}
	 * @param literal A value expected for this datatypeUri
	 * @return A literal well formatted
	 * @throws ParseException If error during Literal construction
	 */
	public static Literal makeLiteral(IRI datatypeUri, String literal) throws LiteralUtilException, ParseException{
		// check if this datatypeUri is recognized : 
		if (!XMLDatatypeUtil.isBuiltInDatatype(datatypeUri)){
			throw new LiteralUtilException("Could not normalise XMLSchema literal");
		}
		// I don't want to normalize date value with XMLDatatypeUtil.normalize but this dateStringToLiteral function
		if (datatypeUri.equals(XMLSchema.DATE) || datatypeUri.equals(XMLSchema.DATETIME)){
			return(Util.dateStringToLiteral(literal));
		} else {
			return Util.vf.createLiteral(XMLDatatypeUtil.normalize(literal, datatypeUri),
					datatypeUri);
		}
}
	
	/**
	 * An immutable instance to create IRI, values ...
	 */
	public final static ValueFactory vf = SimpleValueFactory.getInstance();
	
	
	/* Handling Date ..................... */
	
	
	/**
	 * dateFormat of this project
	 */
	public final static SimpleDateFormat dateFormat ;
	
	static {
		dateFormat = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss");
		dateFormat.setLenient(false); // check if date is valid
		dateFormat.setTimeZone(Util.timeZone); // default GMT = 0
	}
	
	/**
	 * Authorized dateString format are the following : 
	 * <ul>
	 * <li> YYYY_MM_DD
	 * <li> YYYY_MM_DD_HH
	 * <li> YYYY_MM_DD_HH_MM
	 * <li> YYYY_MM_DD_HH_MM_SS
	 * </ul>
	 * This function returns a date or throws a ParseException 
	 * @param dateString The string of a date
	 * @return a Date
	 * @throws ParseException If format is incorrect or date invalid
	 */
	public static Date parseDate(String dateString) throws ParseException{
		int longueur = dateString.length();
		switch (longueur) {
		case 16:
			dateString = dateString + "_00";
		case 13:
			dateString = dateString + "_00_00";
		case 10:
			dateString = dateString + "_00_00_00";
		default: break;
		}
		Date date = dateFormat.parse(dateString);
		return(date);
	}
	
	/**
	 * Transform dateString to date {@link parseDate} then date to Literal
	 * @param dateString The string of a date
	 * @return a date Literal
	 * @throws ParseException If format is incorrect or date invalid
	 */
	public static Literal dateStringToLiteral (String dateString) throws ParseException{
		Date date = parseDate(dateString);
		Literal l = Util.vf.createLiteral(date);
		return(l);
	}
			
}
