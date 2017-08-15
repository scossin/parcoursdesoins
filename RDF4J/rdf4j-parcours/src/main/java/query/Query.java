package query;

/**
 * The goal is to transform a user query (XML, JSON...) into a valid SPARQL QueryString
 * @author cossin
 *
 */
public interface Query {
	 public String getSPARQLQueryString();
}
