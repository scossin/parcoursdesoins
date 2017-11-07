package terminology;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.sail.memory.MemoryStore;

import ontologie.EIG;
import parameters.Util;
import queryFiles.GetSunburstHierarchy;
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
			"context.ttl", Endpoints.CONTEXT)),
	
	CIM10(new Terminology("CIM10","http://www.atih.sante.fr/codeCIM10#","atih","ICD10FR","CIM10-ontology.owl",
			"InstancesCIM10.ttl", Endpoints.CIM10));
	
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