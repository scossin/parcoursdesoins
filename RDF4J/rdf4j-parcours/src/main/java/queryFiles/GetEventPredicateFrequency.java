package queryFiles;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundResultVariable;
import exceptions.UnfoundTerminologyException;
import query.PreparedQuery;
import query.Query;
import query.Results;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class GetEventPredicateFrequency implements FileQuery{
	final static Logger logger = LoggerFactory.getLogger(GetEventPredicateFrequency.class);
	
	public static final String fileName = "predicateFrequency.csv";
	private final String MIMEType = "text/csv";
	
	private String sparqlQueryString  = "SELECT ?eventType ?predicate (count(?predicate) as ?frequency) WHERE { \n" +
		  "?s a ?eventType . \n" + 
				  "?s ?predicate ?o . } \n" + 
				"GROUP BY ?predicate ?eventType \n" + 
				  "#TERMINOLOGY"; // each query will be different for cache
	
	private void setSparqlQueryString (String terminologyName){
		sparqlQueryString = sparqlQueryString.replace("#TERMINOLOGY", "#"+terminologyName);
	}
	
	private final String[] variableNames = {"predicate","eventType","frequency"};
	
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
	
	public GetEventPredicateFrequency(Terminology terminology) throws IOException, UnfoundResultVariable{
		setSparqlQueryString(terminology.getNAMESPACE() + terminology.getTerminologyName());
		Query query = new PreparedQuery(sparqlQueryString, variableNames);
		String sparqlEndpoint = terminology.getEndpoint().getEndpointIPadress();
		Results results = new Results(sparqlEndpoint, query);
		results.serializeResult();
		this.fileToSend = results.getFile();
	}
	
	public static void main(String[] args) throws IOException, UnfoundResultVariable, UnfoundTerminologyException{
		Terminology terminology = TerminologyInstances.getTerminology("CONTEXT");
		GetEventPredicateFrequency eventPredicateFrequency = new GetEventPredicateFrequency(terminology);
		File file = new File("commentaires.csv");
		OutputStream os = new FileOutputStream(file);
		eventPredicateFrequency.sendBytes(os);
		os.close();
	}

}
