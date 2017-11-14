package query;

import org.eclipse.rdf4j.query.impl.SimpleDataset;

import servlet.Endpoint;
import terminology.Terminology;

public class PreparedQuery implements Query {

	private String[] variableNames;
	
	private String sparqlQueryString;
	
	Terminology terminology ; 
	
	public PreparedQuery(String sparqlQueryString, String[] variableNames){
		this.variableNames = variableNames;
		this.sparqlQueryString = sparqlQueryString;
	}
	
	public String getSPARQLQueryString() {
		return sparqlQueryString;
	}

	public SimpleDataset getContextDataset() {
		return(new SimpleDataset());
	}

	public String[] getVariableNames() {
		return variableNames;
	}

	@Override
	public Endpoint getEndpoint() {
		return(terminology.getEndpoint());
	}

	@Override
	public Terminology getTerminology() {
		return(terminology);
	}

}
