package ontologie;

import org.eclipse.rdf4j.model.IRI;

import exceptions.UnfoundTerminologyException;
import integration.DBconnection;
import query.Query;
import servlet.DockerDB;
import servlet.DockerDB.Endpoints;

public class TerminologyServer {

	private String sparlqEndpoint ;
	public TerminologyServer(String ipAdress, String port){
		sparlqEndpoint = DockerDB.getEndpointIPadress(ipAdress, port, Endpoints.TERMINOLOGIES);
	}
	
	
	private String makeBooleanQuery (IRI instanceIRI, IRI classNameIRI){
		String query = Query.formatIRI4query(instanceIRI) + " a " + Query.formatIRI4query(classNameIRI);
		return(query);
	}
	
	public boolean isInstanceOfTerminology(String instanceName, IRI classNameIRI) throws UnfoundTerminologyException{
		IRI instanceIRI = Terminology.getTerminology(classNameIRI).makeInstanceIRI(instanceName);
		DBconnection con = new DBconnection(sparlqEndpoint);
		String query = makeBooleanQuery(instanceIRI, classNameIRI);
		boolean answer = con.getDBcon().prepareBooleanQuery(query).evaluate();
		return(answer);
	}
}
