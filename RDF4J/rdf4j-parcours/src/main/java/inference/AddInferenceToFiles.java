package inference;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import org.eclipse.rdf4j.common.iteration.Iterations;
import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Model;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.rio.Rio;
import org.eclipse.rdf4j.sail.memory.MemoryStore;

import exceptions.InvalidContextFormatException;
import integration.TimelineFile;
import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;

public class AddInferenceToFiles {
	
	private Repository rep ; 
	private RepositoryConnection con;
	private Model model;
	
	public AddInferenceToFiles(){
		rep = new SailRepository(new MemoryStore());
		rep.initialize();
		con = rep.getConnection();
		model = TimelineFile.modelInitialize();
	}

	
	public void addInference(File file) throws RDFParseException, RepositoryException, IOException{
		if (!Util.isValidContextFileFormat(file)){
			throw new InvalidContextFormatException(file.getName());
		}
		IRI contextIRI = Util.getContextIRI(file);
		con.add(file, EIG.NAMESPACE, Util.DefaultRDFformat,contextIRI);
		con.add(Inference.getSubClassOf(con));
		con.add(Inference.getNumbering(con));
		model.addAll(Iterations.asList(con.getStatements(null, null, null)));
		try{
			FileOutputStream out = new FileOutputStream(file);
			Rio.write(model, out, RDFFormat.TURTLE);
		} finally{
			model.clear(); // clear the model for the next call
			con.clear(); // clear the Repository Connection for the next call
		}
	}
	
	public void addInferenceToTimelines(File folder) throws IOException{
		if (!folder.isDirectory()){
			throw new IOException(folder.getAbsolutePath() + " is not a directory");
		}
		File files[] = folder.listFiles();
		for (File file : files){
			try {
				addInference(file);
				System.out.println(file.getPath() + " inferences added");
			} catch (RDFParseException | RepositoryException | IOException e) {
				System.out.println("Fail to add inference to file: " + file.getName() + "");
			}
		}
	}
	
	public static void main(String args[]) throws IOException{
		AddInferenceToFiles inferences = new AddInferenceToFiles();
		String timelinesFolderPath = Util.classLoader.getResource(MainResources.timelinesFolder).getPath();
		File timelinesFolder = new File(timelinesFolderPath);
		inferences.addInferenceToTimelines(timelinesFolder);
	}
}
