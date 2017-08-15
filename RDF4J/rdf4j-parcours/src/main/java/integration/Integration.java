package integration;

import java.io.BufferedReader;
import java.io.IOException;
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
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.sail.memory.MemoryStore;

import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;

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
	
	
	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		Integration integration = new Integration();
		
		Path filePath = Paths.get(MainResources.chargementFolder + "hospitToCSV.csv");
		BufferedReader br = Files.newBufferedReader(filePath,Util.charset);

        // first line from the text file
		String line = br.readLine();
		// loop until all lines are read
		int numLine = 1 ; 
		while (line != null) {
			LineStatement lineStatement;
			try {
				lineStatement = new LineStatement(line, "\t");
				integration.getCon().add(lineStatement.getStatements());
				integration.addContext(lineStatement.getContexte());
			} catch (ParseException | UnfoundEventException | UnfoundTerminologyException 
					| UnfoundPredicatException e) {
				// TODO Auto-generated catch block
				System.out.println("Erreur survenue ligne : " + numLine);
				e.getMessage();
				e.printStackTrace();
			}
			
			line = br.readLine(); // next line
			numLine++;
			//break;
			
		}
		
		for (IRI contextIRI : integration.getContexts()){
			RepositoryResult<Statement> statementsContext = integration.getCon().getStatements(null, null, null,contextIRI);
			Model oneContext = QueryResults.asModel(statementsContext);
			TimelineFile.addTriplesInFile(contextIRI, oneContext);
			integration.getCon().remove(statementsContext,contextIRI);
		}

}
}
