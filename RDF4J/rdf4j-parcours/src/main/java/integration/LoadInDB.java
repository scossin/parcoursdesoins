package integration;

import java.io.File;
import java.io.IOException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.InvalidContextFormatException;
import ontologie.EIG;
import ontologie.EventOntology;
import parameters.MainResources;
import parameters.Util;

/**
 * This class aims to load timeLines files in triplestore
 * It connects to a sparqlEndpoint with {@link DBconnection}
 * @author cossin
 *
 */
public class LoadInDB {

	final static Logger logger = LoggerFactory.getLogger(LoadInDB.class);
	
	
	private DBconnection con;
	
	public DBconnection getCon(){
		return(con);
	}
	
	public LoadInDB(String sparqlEndpoint){
		con = new DBconnection(sparqlEndpoint);
	}
	
	public void loadTimelineFile(File file) throws RDFParseException, RepositoryException, IOException, InvalidContextFormatException{
		if (!Util.isValidContextFileFormat(file)){
			throw new InvalidContextFormatException(logger,file.getName());
		}
		IRI contextIRI = EventOntology.getContextIRI(file);
		con.getDBcon().clear(contextIRI); // remove previous statements
		con.getDBcon().add(file, EIG.NAMESPACE, Util.DefaultRDFformat,contextIRI);
	}
	
	public void loadAllTimelineFiles(File folder) throws IOException, InvalidContextFormatException{
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
	
	public static void main(String[] args) throws RDFParseException, RepositoryException, IOException, InvalidContextFormatException {
		// TODO Auto-generated method stub
		String timelinesFolderPath = Util.classLoader.getResource(MainResources.timelinesFolder).getPath();
		File timelinesFolder = new File(timelinesFolderPath);
		LoadInDB load = new LoadInDB(Util.sparqlEndpoint);
		
		//String fichier = MainResources.directoryMainResources + MainResources.terminologiesFolder + "p9999.ttl";
		//load.loadTimelineFile(new File(fichier));
		load.loadAllTimelineFiles(timelinesFolder);
		load.getCon().close();
	}
}
