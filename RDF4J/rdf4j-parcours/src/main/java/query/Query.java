package query;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.query.impl.SimpleDataset;

import servlet.DockerDB.Endpoints;

/**
 * The goal is to transform a user query (XML, JSON...) into a valid SPARQL QueryString
 * @author cossin
 *
 */
public interface Query {
	public String getSPARQLQueryString();

	public SimpleDataset getContextDataset();
	
	public String[] getVariableNames();
	
	public Endpoints getEndpoint();
	/**
	 * Return the good format of a IRI for a SPARQL query
	 * @param oneIRI a IRI (subject, predicate or object)
	 * @return String for a SPARQL query
	 */
	public static String formatIRI4query (IRI oneIRI){
		return("<" + oneIRI.stringValue()+">");
	}
}
