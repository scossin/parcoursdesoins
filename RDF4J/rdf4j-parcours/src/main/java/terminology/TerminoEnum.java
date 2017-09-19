package terminology;

import ontologie.EIG;
import servlet.DockerDB.Endpoints;

public enum TerminoEnum {

	RPPS(new Terminology("RPPS","http://esante.gouv.fr#","asip","RPPS", "RPPS-ontology.owl","RPPS.ttl",
			Endpoints.RPPS)),
	
	// FINESS code is a french terminology for healthcare institution
	FINESS(new Terminology("Etablissement","https://www.data.gouv.fr/FINESS#","datagouv","Etablissement","FINESS-ontology.owl",
			"FINESS.ttl", Endpoints.FINESS)),
	
	EVENTS(new Terminology("Event",EIG.NAMESPACE,EIG.PREFIX,EIG.eventClassName,"events-ontology.owl",
			null, Endpoints.TIMELINES)),
	
	CONTEXT(new Terminology("Graph",EIG.NAMESPACE,EIG.PREFIX,EIG.GRAPH,"Context-ontology.owl",
			"context.ttl", Endpoints.CONTEXT));
	
	private Terminology terminology;
	
	private TerminoEnum(Terminology terminology){
		this.terminology = terminology;
	}
	
	public Terminology getTermino(){
		return(terminology);
	}
	
	public String getTerminologyName(){
		return(terminology.getTerminologyName());
	}
}