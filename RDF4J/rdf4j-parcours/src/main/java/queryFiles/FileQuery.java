package queryFiles;

import java.io.IOException;
import java.io.OutputStream;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;

import parameters.MainResources;
import terminology.Terminology.TerminoEnum;

public interface FileQuery {
	
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
	
	public static FileQuery getHierarchy() throws RDFParseException, RepositoryException, IOException{
		return(new GetSunburstHierarchy(MainResources.ontologyFileName,TerminoEnum.EVENTS.getTermino().getClassNameIRI()));
	}
	
	public static FileQuery getPredicateDescription(String className) throws IOException {
		for (TerminoEnum termino : TerminoEnum.values()){
			String localName = termino.getTerminologyName();
			if (localName.equals(className)){
				return(new GetPredicateDescription(termino));
			}
		}
		throw new IOException();
	}
	
	public static FileQuery getPredicateFrequency(String className) throws IOException {
		for (TerminoEnum termino : TerminoEnum.values()){
			String localName = termino.getTerminologyName();
			if (localName.equals(className)){
				return(new GetEventPredicateFrequency(termino));
			}
		}
		throw new IOException();
	}
}
