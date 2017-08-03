package integration;

import java.io.File;
import java.io.IOException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;

import exceptions.InvalidContextFormatException;

/**
 * This class aims to load timeLines files in triplestore
 * It connects to a sparqlEndpoint with {@link DBconnection}
 * @author cossin
 *
 */
public class LoadInDB {

	
	
	private DBconnection con;

	
	public DBconnection getCon(){
		return(con);
	}
	
	public LoadInDB(String sparqlEndpoint){
		con = new DBconnection(sparqlEndpoint);
	}
	
	public void loadTimelineFile(File file) throws RDFParseException, RepositoryException, IOException{
		if (!Util.isValidContextFileFormat(file)){
			throw new InvalidContextFormatException(file.getName());
		}
		IRI contextIRI = Util.getContextIRI(file);
		con.getDBcon().add(file, EIG.NAMESPACE, Util.DefaultRDFformat,contextIRI);
	}
	
	public void loadAllTimelineFiles(File folder) throws IOException{
		if (!folder.isDirectory()){
			throw new IOException(folder.getAbsolutePath() + " is not a directory");
		}
		File files[] = folder.listFiles();
		for (File file : files){
			try {
				loadTimelineFile(file);
				System.out.println(file + " loaded in DB");
			} catch (RDFParseException | RepositoryException | IOException e) {
				System.out.println("Fail to load file: " + file.getName() + " in DB");
			}
		}
	}
	
	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		File timelinesFolder = new File(Util.timelinesFolder);
		LoadInDB load = new LoadInDB(Util.sparqlEndpoint);
		load.loadAllTimelineFiles(timelinesFolder);
		load.getCon().close();
	}
}
