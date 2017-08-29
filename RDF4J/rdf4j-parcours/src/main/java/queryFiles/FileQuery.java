package queryFiles;

import java.io.IOException;
import java.io.OutputStream;

import org.eclipse.rdf4j.model.IRI;

import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;

public interface FileQuery {
	
	public void sendBytes(OutputStream os) throws IOException;
	
	public String getFileName();
	
	public String getMIMEtype();
	
	public static boolean isKnownFileName(String fileName){
		for (FilesAvailable FileAvailable : FilesAvailable.values()){
			if (fileName.equals(FileAvailable.getFileName())){
				return(true);
			}
		}
		return(false);
	}
	
	public static FileQuery getFileQuery(String fileName) throws IOException {
		if (fileName.equals(GetPredicateDescription.fileName)){
			return(new GetPredicateDescription());
		} else if (fileName.equals(GetEventPredicateFrequency.fileName)){
			return(new GetEventPredicateFrequency());
		} else if (fileName.equals(GetSunburstHierarchy.fileName)){
			IRI classNameIRI = Util.vf.createIRI(EIG.NAMESPACE, EIG.eventClassName);
			return(new GetSunburstHierarchy(MainResources.ontologyFileName,classNameIRI));
		}
		throw new IOException();
	}
}
