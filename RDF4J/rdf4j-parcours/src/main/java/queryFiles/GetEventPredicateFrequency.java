package queryFiles;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

import query.PreparedQuery;
import query.Query;
import query.Results;
import servlet.DockerDB;
import servlet.DockerDB.Endpoints;

public class GetEventPredicateFrequency implements FileQuery{

	public static final String fileName = "predicateFrequency.csv";
	private final String MIMEType = "text/csv";
	
	private final String sparqlQueryString  = "SELECT ?eventType ?predicate (count(?predicate) as ?freq) WHERE { \n" +
		  "?s a ?eventType . \n" + 
				  "?s ?predicate ?o . } \n"+
				"GROUP BY ?predicate ?eventType";
	
	private final String[] variableNames = {"eventType","predicate","freq"};
	
	public File fileToSend ;
	
	public void sendBytes(OutputStream os) throws IOException {
		FileInputStream fis = new FileInputStream(fileToSend);
		try {
			int BUFF_SIZE = 8*1024;
			byte[] buffer = new byte[BUFF_SIZE];
			int byteRead = 0;
			while ((byteRead = fis.read(buffer)) != -1) {
				os.write(buffer, 0, byteRead);
			}
		} finally{
			fis.close();
		}
	}

	public String getFileName() {
		return fileName;
	}

	public String getMIMEtype() {
		return MIMEType;
	}
	
	public GetEventPredicateFrequency() throws IOException{
		Query query = new PreparedQuery(sparqlQueryString, variableNames);
		String sparqlEndpoint = DockerDB.getEndpointIPadress(Endpoints.TIMELINES);
		Results results = new Results(sparqlEndpoint, query);
		results.serializeResult();
		this.fileToSend = results.getFile();
	}
	
	public static void main(String[] args) throws IOException{
		GetEventPredicateFrequency predicateFrequency = new GetEventPredicateFrequency();
		System.out.println(predicateFrequency.fileToSend.getAbsolutePath());
	}

}
