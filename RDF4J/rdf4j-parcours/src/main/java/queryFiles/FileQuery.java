package queryFiles;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundFilterException;
import exceptions.UnfoundResultVariable;
import exceptions.UnfoundTerminologyException;
import terminology.Terminology;
import terminology.TerminologyInstances;

public interface FileQuery {
	
	final static Logger logger = LoggerFactory.getLogger(FileQuery.class);
	
	public void sendBytes(OutputStream os) throws IOException;
	
	public String getFileName();
	
	public String getMIMEtype();
	
	@Deprecated
	public static boolean isKnownFileName(String fileName){
		for (FilesAvailable FileAvailable : FilesAvailable.values()){
			if (fileName.equals(FileAvailable.getFileName())){
				return(true);
			}
		}
		return(false);
	}
	
	public static FileQuery getHierarchy(String terminologyName) throws RDFParseException, RepositoryException, UnfoundTerminologyException, IOException{
		Terminology terminology = TerminologyInstances.getTerminology(terminologyName);
		return(new GetSunburstHierarchyLabel(terminology));
	}
	
	public static FileQuery getPredicateDescription(String terminologyName) throws IOException, UnfoundTerminologyException, UnfoundFilterException {
		Terminology terminology = TerminologyInstances.getTerminology(terminologyName);
		return(new GetPredicateDescription(terminology));
	}
	
	public static FileQuery getPredicateFrequency(String terminologyName) throws IOException, UnfoundResultVariable, RDFParseException, RepositoryException, UnfoundTerminologyException {
		Terminology terminology = TerminologyInstances.getTerminology(terminologyName);
		return(new GetEventPredicateFrequency(terminology));
	}
	
}
