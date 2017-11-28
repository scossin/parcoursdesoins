package hierarchy;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundFilterException;
import parameters.MainResources;
import parameters.Util;
import queryFiles.FileQuery;
import servlet.GetTimeline;
import terminology.Terminology;

/**
 * This class is used to generate data for Sunburst datavizualisation
 * @author cossin
 *
 */
public class GetSunburstHierarchyLabel implements FileQuery{

	final static Logger logger = LoggerFactory.getLogger(GetSunburstHierarchyLabel.class);
	
	public final static String fileName = "Hierarchy4Sunburst.csv"; // name doesn't matter
	
	private final String MIMEtype = "text/csv";
	
	private File resultFile = null; // to save in cache and check if it already exists
	
	private Terminology terminology;
	
	private LinkedHashMap<IRI, Code> mapIRIcodes;
	
	/**
	 * Tree is a set of String because, in a multi-axial terminology, one child code can have multiple path to the top code
	 * {@link hierarchy.Code} is a class representation of a terminology code
	 */
	private HashMap<Code,HashSet<String>> mapCodeTree = new HashMap<Code,HashSet<String>>();
	
	
	/******************************************* Constructor 
	 * @throws UnfoundFilterException ******************************/
	public GetSunburstHierarchyLabel(Terminology terminology)
			throws RDFParseException, RepositoryException, IOException, UnfoundFilterException {
		this.terminology = terminology;
		mapIRIcodes = terminology.getHierarchy().getMapIRIcode();
		setResultFile(); // in the cache folder
	}
	
	private void setResultFile(){
		String cacheFolder = MainResources.cacheFolder ;
		String cacheFolderPath = Util.classLoader.getResource(cacheFolder).getPath();
		String fileResultName = cacheFolderPath + "Cache-" + terminology.getTerminologyName() + "-" + fileName;
		resultFile = new File(fileResultName);
	}
	
	/**
	 * called if file not found in the cache folder
	 * @throws IOException
	 */
	private void writeFile() throws IOException{
		OutputStream os = new FileOutputStream(resultFile);
		StringBuilder line = new StringBuilder();
		//header
		line.append("code");
		line.append("\t");
		line.append("label");
		line.append("\t");
		line.append("tree");
		line.append("\n");
		os.write(line.toString().getBytes());
		line.setLength(0);
		
		for (Code code : mapCodeTree.keySet()){
			String codeName = code.getClassIRI().getLocalName();
			String label = code.getLabel();
			for (String tree : mapCodeTree.get(code)){
				line.append(codeName);
				line.append("\t");
				line.append(label);
				line.append("\t");
				line.append(tree);
				line.append("\n");
				os.write(line.toString().getBytes());
				line.setLength(0);
			}
		}
		os.close();
	}

	
	/**
	 * 
	 * @param InitialCode => a code with no child
	 * @param sb
	 * @param code => same as initialCode in the first iteration, then a parent code in the hierarchy
	 */
	private void setTree(Code InitialCode, StringBuilder sb, Code code){
		sb.insert(0,code.getLabel()); // insert in first position this label
		sb.insert(0,"-"); // is then removed if code has not parent
		
		if (code.getParents().isEmpty()){ // we reach the top of the hierarchy
			sb.deleteCharAt(0); // remove first -
			String tree = sb.toString();
			mapCodeTree.get(InitialCode).add(tree); // we add the tree ( ex : Event-SejourHospitalier-SejourMCO)
			return;
		} else { // we don't add till reaching the top of the hierarchy
			for (IRI codeIRI : code.getParents()) { 
				Code codeParent = mapIRIcodes.get(codeIRI);
				setTree(InitialCode, sb, codeParent); // recursive function 
			}
		}
	}
	
	/**
	 * trees (ex : Event-SejourHospitalier-SejourMCO for SejourMCO code in the Event terminology); 
	 * example in multiaxial terminology :  Event-Hospitalisation-SejourMCO and Event-SejourHospitalier-SejourMCO
	 */
	private void setHierarchyLabel(){
		Iterator<Code> iter = mapIRIcodes.values().iterator();
		while(iter.hasNext()){
			Code code = iter.next();
			StringBuilder sb = new StringBuilder();
			HashSet<String> trees = new HashSet<String>();
			mapCodeTree.put(code, trees);
			setTree(code, sb, code);
		}
	}
	
	
	/************************************** Implementing FilQuery methods ********************************/
	public void sendBytes(OutputStream os) throws IOException {
		if (!resultFile.exists()){ // in the cache folder
			setHierarchyLabel();
			writeFile();
		}
		GetTimeline.sendFile(os, resultFile);
	}

	@Override
	public String getFileName() {
		return fileName;
	}

	@Override
	public String getMIMEtype() {
		return MIMEtype;
	}
	
}
