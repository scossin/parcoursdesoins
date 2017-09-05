package query;

import org.eclipse.rdf4j.query.impl.SimpleDataset;

import servlet.DockerDB.Endpoints;

public class PreparedQuery implements Query {

	private String[] variableNames;
	
	private String sparqlQueryString;
	
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
	public Endpoints getEndpoint() {
		// TODO Auto-generated method stub
		return null;
	}

}
