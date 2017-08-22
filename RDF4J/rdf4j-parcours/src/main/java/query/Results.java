package query;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;

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
import exceptions.InvalidContextException;
import exceptions.InvalidXMLFormat;
import exceptions.OperatorException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import integration.DBconnection;
import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;

/**
 * This class manages the results of a SPARQL query. <br>
 * The results are written on disk in the cache folder to improve performance. <br>
 * FileName is the concatenation of SPARQL string query hash and context hash. <br>
 * @author cossin
 *
 */
public class Results {

	final static Logger logger = LoggerFactory.getLogger(Results.class);
	
	/**
	 * A connection to SPARQL endpoint
	 */
	private DBconnection con;
	
	/**
	 *  Contains the SPARQL query string, the variablesNames and the context 
	 */
	private Query query ;
	
	/**
	 * To write file on disk
	 */
	private BufferedWriter bufferWriter;
	
	/**
	 * variables of the results. 
	 */
	
	/**
	 * FileName is the concatenation of SPARQL string query hash and context hash.
	 */
	private File resultFile;
	
	
	public BufferedWriter getBufferedWriter(){
		return(bufferWriter);
	}
	

	/******************** Getter ****************/
	public DBconnection getCon(){
		return(con);
	}
	
	public File getFile(){
		return(resultFile);
	}
	
	/**
	 * Check if a result file already exists for this specific query (SPARQL query + context)
	 * @return
	 */
	public boolean isFileAlreadyExists(){
		return(resultFile.exists());
	}
	
	/**
	 * Write the result of a SPARQL query to file
	 * @param tupleResult a result of a SPARQL query 
	 * @throws IOException
	 */
	private void writeResults(TupleQueryResult tupleResult) throws IOException{
		logger.info("Writing results to file : "+ resultFile.getAbsolutePath());
		
		setUpBufferWriter(); // create a new instance
		
		// Headers : 
		StringBuilder sb = new StringBuilder();
		for (String eventName : query.getVariableNames()){
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
			for (String variable : query.getVariableNames()){
				try{
					IRI variableIRI = (IRI) set.getValue(variable);
					sb.append(variableIRI.getLocalName());
				} catch (ClassCastException e){
					sb.append(set.getValue(variable).stringValue());
				}
				sb.append("\t");
			}
			sb.setLength(sb.length()-1); // remove last \t
			sb.append("\n"); 
			bufferWriter.write(sb.toString());
		}
		
		tupleResult.close();
		bufferWriter.close();
	}

	/**
	 * Create a new instance of BufferedWriter to write file on disk
	 */
	private void setUpBufferWriter() throws IOException{
    	FileWriter fw = new FileWriter(resultFile,true);
    	this.bufferWriter = new BufferedWriter(fw);
	}
	
	/**
	 * Results of SPARQL queries are stored on disk in the cache folder
	 * @param query
	 */
	private void setFile(Query query){
		String cacheFolder = MainResources.cacheFolder ;
		String timelinesFolderPath = Util.classLoader.getResource(cacheFolder).getPath();
		int queryHashCode = query.getSPARQLQueryString().hashCode(); // queryString hash
		int contextHashCode = query.getContextDataset().getNamedGraphs().hashCode(); // same query in a different context is possible
		String fileName = timelinesFolderPath + queryHashCode + "_" + contextHashCode  + ".csv";
		resultFile = new File(fileName);
	}
	
	/**
	 * Construct
	 * @param sparqlEndpoint
	 * @param query
	 * @throws IOException
	 */
	public Results (String sparqlEndpoint, Query query) throws IOException{
		this.con = new DBconnection(sparqlEndpoint);
		this.query = query;
		setFile(query);
	}
	
	/**
	 * Send the SPARQL query to a SPARQLendpoint and retrieve the result. <br>
	 * The SPARQL query doesn't need to be sent if results already exists on disk. <br>
	 * See also {@link serializeResult}. <br>
	 * @return TupleQueryResult
	 */
	public TupleQueryResult sendQuery(){
		logger.info("Sending request : \t" + query.getSPARQLQueryString() + "with " 
				+ query.getContextDataset().getNamedGraphs().size() + " contexts");
		TupleQuery keywordQuery = con.getDBcon().prepareTupleQuery(query.getSPARQLQueryString());
		keywordQuery.setDataset(query.getContextDataset());
		TupleQueryResult keywordQueryResult = keywordQuery.evaluate();
		return(keywordQueryResult);
	}
	
	/**
	 * Check if a result file already exists or send the query and save result on disk.
	 * @throws IOException
	 */
	public void serializeResult() throws IOException{
		if (isFileAlreadyExists()){
			logger.info("Query not sent : file already exists");
		} else {
			TupleQueryResult tupleResult = sendQuery();
			writeResults(tupleResult);
		}
	}
	
	public static void main(String[] args) throws NumberFormatException, ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException, ParseException, IncomparableValueException, UnfoundTerminologyException, OperatorException, InvalidContextException, InvalidXMLFormat {
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
		results.serializeResult();

		results.getCon().close();
	}
}
