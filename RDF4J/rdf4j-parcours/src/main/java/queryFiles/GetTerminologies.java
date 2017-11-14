package queryFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;

import exceptions.UnfoundFilterException;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class GetTerminologies implements FileQuery {

	public static final String fileName = "terminologies.csv";
	private final String MIMEType = "text/csv";
	
	public File fileToSend ;
	
	byte[] bytesFile ; 
	
	public GetTerminologies(){
		StringBuilder sb = new StringBuilder();
		for (Terminology terminology : TerminologyInstances.terminologies){
			String terminologyName = terminology.getTerminologyName();
			String mainClassName  = terminology.getMainClassIRI().getLocalName();
			sb.append(terminologyName);
			sb.append("\t");
			sb.append(mainClassName);
			sb.append("\n");
		}
		bytesFile = sb.toString().getBytes();
	}
	
	public void sendBytes(OutputStream os) throws IOException {
		os.write(bytesFile);
	}

	@Override
	public String getFileName() {
		return fileName;
	}

	@Override
	public String getMIMEtype() {
		return MIMEType;
	}
	
	public static void main(String[] args) throws IOException, RDFParseException, RepositoryException, UnfoundFilterException{
		for (Terminology terminology : TerminologyInstances.terminologies){
			terminology.checkInitialization();
		}
		GetTerminologies getTerminologies = new GetTerminologies();
		File file = new File("terminologies.csv");
		OutputStream os = new FileOutputStream(file);
		getTerminologies.sendBytes(os);
		os.close();
	}
	
}
