package terminology;

import java.io.IOException;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;

import ontologie.EIG;
import servlet.DockerDB.Endpoints;

public enum TerminoEnum {

	RPPS(new Terminology("RPPS","http://esante.gouv.fr#","asip","RPPS", "RPPS-ontology.owl","RPPS.ttl",
			Endpoints.RPPS)),
	
	// FINESS code is a french terminology for healthcare institution
	FINESS(new Terminology("Etablissement","https://www.data.gouv.fr/FINESS#","datagouv","Etablissement","FINESS-ontology.owl",
			"FINESS33.ttl", Endpoints.FINESS)),
	
	EVENTS(new Terminology(EIG.TerminologyName,EIG.NAMESPACE,EIG.PREFIX,EIG.eventClassName,"events-ontology.owl",
			null, Endpoints.TIMELINES)),
	
	CONTEXT(new Terminology("Graph",EIG.NAMESPACE,EIG.PREFIX,EIG.GRAPH,"Context-ontology.owl",
			"context.ttl", Endpoints.CONTEXT));
	
	private Terminology terminology;
	
	private TerminoEnum(Terminology terminology){
		this.terminology = terminology;
	}
	
	public Terminology getTermino() throws RDFParseException, RepositoryException, IOException{
		return(terminology.initialize());
	}
	
	public String getTerminologyName(){
		return(terminology.getTerminologyName());
	}
}