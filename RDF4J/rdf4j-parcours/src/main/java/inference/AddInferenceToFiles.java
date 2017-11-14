package inference;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.xml.datatype.DatatypeConfigurationException;

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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.InvalidContextFormatException;
import exceptions.InvalidOntology;
import exceptions.UnfoundFilterException;
import exceptions.UnfoundTerminologyException;
import integration.TimelineFile;
import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;

public class AddInferenceToFiles {
	
	final static Logger logger = LoggerFactory.getLogger(AddInferenceToFiles.class);
	
	private Repository rep ; 
	private RepositoryConnection con;
	private Model model;
	
	public AddInferenceToFiles(){
		rep = new SailRepository(new MemoryStore());
		rep.initialize();
		con = rep.getConnection();
		model = TimelineFile.modelInitialize();
	}

	
	public void addInference(File file) throws RDFParseException, RepositoryException, IOException, InvalidContextFormatException, DatatypeConfigurationException, InvalidOntology, UnfoundTerminologyException, UnfoundFilterException{
		if (!Util.isValidContextFileFormat(file)){
			throw new InvalidContextFormatException(logger, file.getName());
		}
		IRI contextIRI = EIG.getContextIRI(file);
		con.add(file, EIG.NAMESPACE, Util.DefaultRDFformat,contextIRI);
		con.add(Inference.hasDuration(con));
		con.add(Inference.setEIGtype(con));
		con.add(Inference.getSubClassOf(con));
		con.add(Inference.getNumbering(con));
		con.add(Inference.hasNext(con));
		model.addAll(Iterations.asList(con.getStatements(null, null, null)));
		try{
			FileOutputStream out = new FileOutputStream(file);
			Rio.write(model, out, RDFFormat.TURTLE);
		} finally{
			model.clear(); // clear the model for the next call
			con.clear(); // clear the Repository Connection for the next call
		}
	}
	
	public void addInferenceToTimelines(File folder) throws IOException, InvalidContextFormatException, InvalidOntology, DatatypeConfigurationException, UnfoundTerminologyException, UnfoundFilterException{
		if (!folder.isDirectory()){
			throw new IOException(folder.getAbsolutePath() + " is not a directory");
		}
		File files[] = folder.listFiles();
		for (File file : files){
			try {
				logger.info("trying to add inference to ..." + file.getPath());
				addInference(file);
				System.out.println(file.getPath() + " inferences added");
			} catch (RDFParseException | RepositoryException | IOException e) {
				System.out.println("Fail to add inference to file: " + file.getName() + "");
			}
		}
	}
	
	public static void main(String args[]) throws IOException, InvalidContextFormatException, InvalidOntology, DatatypeConfigurationException, UnfoundTerminologyException, UnfoundFilterException{
		AddInferenceToFiles inferences = new AddInferenceToFiles();
		String timelinesFolderPath = Util.classLoader.getResource(MainResources.timelinesFolder).getPath();
		File timelinesFolder = new File(timelinesFolderPath);
		inferences.addInferenceToTimelines(timelinesFolder);
	}
}
