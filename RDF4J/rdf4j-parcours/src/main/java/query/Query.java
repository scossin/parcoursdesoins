package query;

import org.eclipse.rdf4j.model.IRI;

/**
 * The goal is to transform a user query (XML, JSON...) into a valid SPARQL QueryString
 * @author cossin
 *
 */
public interface Query {
	public String getSPARQLQueryString();

	/**
	 * Return the good format of a IRI for a SPARQL query
	 * @param oneIRI a IRI (subject, predicate or object)
	 * @return String for a SPARQL query
	 */
	public static String formatIRI4query (IRI oneIRI){
		return("<" + oneIRI.stringValue()+">");
	}
}
