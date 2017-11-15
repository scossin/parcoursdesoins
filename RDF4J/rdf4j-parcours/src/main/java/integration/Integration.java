package integration;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.ParseException;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Model;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.query.QueryResults;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.sail.memory.MemoryStore;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.InvalidContextException;
import exceptions.MyExceptions;
import exceptions.UnfoundEventException;
import exceptions.UnfoundFilterException;
import exceptions.UnfoundInstanceOfTerminologyException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;
import terminology.TerminologyInstances;

/**
 * This class transforms a CSV file containing statements in RDF with {@link LineStatement}
 * Then it writes on disk these RDF statement
 * 
 * The algorithm is the following : 
 * <ul> 
 * <li> Read the CSV line by line
 * <li> Make a new instance of {@link LineStatement} for each line
 * <li> Save all statements in a temporary repository
 * <li> Loop over all context (named graph), retrieve all statements for a specific context
 * <li> Check if a file already exists on disk for this context :
 * <ul> 
 * <li> if a file already exists : load and merge statements in this file
 * <li> if a file doesn't exist : create it
 * </ul>
 * </ul>
 * 
 * @author cossin
 *
 */
public class Integration {
	
	final static Logger logger = LoggerFactory.getLogger(Integration.class);
	
	/**
	 * all contexts in the Repository of statements 
	 */
	private Set<IRI> contexts = new HashSet<IRI>();
	
	/**
	 * A temporary repository of statements
	 */
	private Repository rep;
	
	/**
	 * A connection to this repository
	 */
	private RepositoryConnection con;
	

	
	/**
	 * add a contextIRI to the collections of contextIRI to loop over all contexts then
	 * @param contextIRI a contextIRI
	 */
	private void addContext(IRI contextIRI){
		contexts.add(contextIRI);
	}
	
	/**
	 * Constructor
	 */

	
	public Integration(){
		this.rep = new SailRepository(new MemoryStore());
		rep.initialize();
		this.con = rep.getConnection();
	}
	
	/* getters ......*/
	public RepositoryConnection getCon() {
		return con;
	}
	
	private Set<IRI> getContexts(){
		return(contexts);
	}
	
	public void close() throws IOException{
		this.con.close();
		this.rep.shutDown();
		output.close();
	}
	
	private HashSet<File> files = new HashSet<File>();
	
	public void setFiles(File folderFile) throws IOException{
		if (!folderFile.isDirectory()){
			String msg = "unfound folder : " + folderFile.toString();
			MyExceptions.logMessage(logger, msg);
			throw new IOException(msg);
		}
		
		logger.info("Searching CSV files in : " + folderFile.toString());
		
		File[] filesCSV = folderFile.listFiles();
		for (File fileCSV : filesCSV){
			if (fileCSV.getName().endsWith(".csv")){
				files.add(fileCSV);
			}
		}
		System.out.println(files.size() + " files to read");
		
		rejectedFile = new File(folderFile.getAbsolutePath() + "/rejectedFile.txt");
		System.out.println("rejectedFile:" + rejectedFile.getAbsolutePath());
		if (rejectedFile.exists()){
			rejectedFile.createNewFile();
		}
		output = new BufferedWriter(new FileWriter(rejectedFile,true));  //clears file every time
	}
	
	private File rejectedFile ; 
	private BufferedWriter output;
	
	private void addRejectedLine (String rejectedLine) throws IOException{
		output.append(rejectedLine);
	}
	
	public void readFiles() throws IOException, UnfoundTerminologyException {
		for (File file : files){
			System.out.println(file.getName());
			Path filePath = Paths.get(file.getAbsolutePath());
			BufferedReader br = Files.newBufferedReader(filePath,Util.charset);
	        // first line from the text file
			String line = br.readLine();
			// loop until all lines are read
			int numLine = 1 ;
			int rejectedLine = 0 ; 
			LineStatement lineStatement = new LineStatement("\t",TerminologyInstances.getTerminology(EIG.TerminologyName));
			while (line != null) {
				try {
					lineStatement.addLineStatement(line);
					getCon().add(lineStatement.getStatements());
					addContext(lineStatement.getContext());
				} catch (ParseException | UnfoundEventException | UnfoundTerminologyException 
						| UnfoundPredicatException | RDFParseException | RepositoryException | InvalidContextException | UnfoundInstanceOfTerminologyException | UnfoundFilterException e) {
					// TODO Auto-generated catch block
					//System.out.println("An error occured line : " + numLine);
					addRejectedLine("\n" + line + "\t" + e.getMessage());
					rejectedLine ++;
					//e.printStackTrace();
				}
				
				line = br.readLine(); // next line
				numLine++;	
			}
			System.out.println("number of lines read : " + numLine);
			System.out.println("number of lines rejected : " + rejectedLine);
			br.close();
			addTriplesInFiles();
		}
	}
	
	private void addTriplesInFiles() throws RDFParseException, RepositoryException, IOException{
		for (IRI contextIRI : getContexts()){
			RepositoryResult<Statement> statementsContext = getCon().getStatements(null, null, null,contextIRI);
			Model model = QueryResults.asModel(statementsContext);
			TimelineFile.addTriplesInFile(contextIRI, model);
			getCon().remove(statementsContext,contextIRI);
		}
	}
	
	public static void main(String[] args) throws Exception {
		// TODO Auto-generated method stub
		Integration integration = new Integration();
		URL folder = Util.classLoader.getResource(MainResources.terminologiesFolder + "chargement");
		File folderFile = new File(folder.toURI());
		integration.setFiles(folderFile);
		integration.readFiles();
		TimelineFile.close();
		integration.close();
		TerminologyInstances.closeConnections();
		System.out.println("End!");
}
}
