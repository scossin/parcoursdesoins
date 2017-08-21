package query;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;

import javax.swing.filechooser.FileNameExtensionFilter;
import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import exceptions.IncomparableValueException;
import exceptions.OperatorException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import integration.DBconnection;
import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;

public class Results {

	final static Logger logger = LoggerFactory.getLogger(Results.class);
	
	private DBconnection con;
	
	public DBconnection getCon(){
		return(con);
	}
	
	private Query query ;
	
	private BufferedWriter bufferWriter;
	
	private String[] eventNames;
	
	public BufferedWriter getBufferedWriter(){
		return(bufferWriter);
	}
	
	private File file;
	
	public File getFile(){
		return(file);
	}
	
	public boolean isFileAlreadyExists(){
		return(file.exists());
	}
	
	private void writeResults(TupleQueryResult tupleResult) throws IOException{
		logger.info("Writing results to file : "+ file.getAbsolutePath());
		
		setUpBufferWriter();
		
		// Headers : 
		StringBuilder sb = new StringBuilder();
		for (String eventName : eventNames){
			sb.append(eventName);
			sb.append("\t");
		}
		sb.setLength(sb.length()-1); // remove last \t
		sb.append("\n"); 
		bufferWriter.write(sb.toString());
		// lines : 
		while(tupleResult.hasNext()){
			sb.setLength(0);
			BindingSet set = tupleResult.next();
			for (String variable : eventNames){
				IRI variableIRI = (IRI) set.getValue(variable);
				sb.append(variableIRI.getLocalName());
				sb.append("\t");
			}
			sb.setLength(sb.length()-1); // remove last \t
			sb.append("\n"); 
			bufferWriter.write(sb.toString());
		}
		
		tupleResult.close();
		bufferWriter.close();
	}

	private void setUpBufferWriter() throws IOException{
    	FileWriter fw = new FileWriter(file,true);
    	this.bufferWriter = new BufferedWriter(fw);
	}
	
	private void setFile(Query query){
		String cacheFolder = MainResources.cacheFolder ;
		String timelinesFolderPath = Util.classLoader.getResource(cacheFolder).getPath();
		int queryHashCode = query.getSPARQLQueryString().hashCode();
		int contextHashCode = query.getContextDataset().getNamedGraphs().hashCode(); // same query in a different context is possible
		String fileName = timelinesFolderPath + queryHashCode + "_" + contextHashCode  + ".csv";
		file = new File(fileName);
	}
	
	public Results (String sparqlEndpoint, Query query) throws IOException{
		this.con = new DBconnection(sparqlEndpoint);
		this.query = query;
		this.eventNames = query.getVariableNames();
		setFile(query);
	}
		
	public TupleQueryResult sendQuery(){
		logger.info("Sending request : \t" + query.getSPARQLQueryString() + "with " 
				+ query.getContextDataset().getNamedGraphs().size() + " contexts");
		TupleQuery keywordQuery = con.getDBcon().prepareTupleQuery(query.getSPARQLQueryString());
		keywordQuery.setDataset(query.getContextDataset());
		TupleQueryResult keywordQueryResult = keywordQuery.evaluate();
		return(keywordQueryResult);
	}
	
	public void setUpFile() throws IOException{
		if (isFileAlreadyExists()){
			logger.info("Query not sent : file already exists");
		} else {
			TupleQueryResult tupleResult = sendQuery();
			writeResults(tupleResult);
		}
	}
	
	public static void main(String[] args) throws NumberFormatException, ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, ParseException, IncomparableValueException, UnfoundTerminologyException, OperatorException {
		SimpleDataset dataset = new SimpleDataset();
		int n = 10;
		IRI patients[] = new IRI[n];
		for (int i = 0; i<n ; i++){
			String patient_n = "p" + (i+1);
			IRI patient1 = Util.vf.createIRI(EIG.NAMESPACE,patient_n);
			System.out.println(patient1);
			patients[i] = patient1;
			dataset.addNamedGraph(patients[i]);
		} 
		
		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "queryMCOContext.xml" );
		InputStream dtdFile = Util.classLoader.getResourceAsStream(MainResources.dtdSearchFile);
		Query query = new XMLSearchQuery(new XMLFile(xmlFile, dtdFile));
		
		Results results = new Results(Util.sparqlEndpoint,query);
		results.setUpFile();

		results.getCon().close();
	}
}
