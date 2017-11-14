package ontologie;

import java.io.IOException;
import java.io.InputStream;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;

import integration.DBconnection;
import parameters.MainResources;
import parameters.Util;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class LoadOntology {

	public static void main(String[] args) throws Exception {
		Terminology terminology = TerminologyInstances.getTerminology(EIG.TerminologyName);
		String sparlqEndpoint = terminology.getEndpoint().getEndpointIPadress();
		DBconnection con = new DBconnection(sparlqEndpoint);
		// TODO Auto-generated method stub
		String ontologyFile = MainResources.ontologyFileName;
		System.out.println("Trying to load " + ontologyFile);
		String ontologyNameSpace = EIG.NAMESPACE;
		
		InputStream in = Util.classLoader.getResourceAsStream(ontologyFile);
		try {
			con.getDBcon().add(in, ontologyNameSpace, Util.DefaultRDFformat);
			System.out.println("successful");
		} catch (RDFParseException | RepositoryException | IOException e) {
			// TODO Auto-generated catch block
			throw e;
		} finally{
			in.close();
		}
	}

}
