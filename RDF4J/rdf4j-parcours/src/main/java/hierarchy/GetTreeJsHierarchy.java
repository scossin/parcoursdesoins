package hierarchy;

import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundFilterException;
import exceptions.UnfoundInstanceOfTerminologyException;
import queryFiles.FileQuery;
import terminology.Terminology;

/**
 *  This class is used to generate data for Treejs datavizualisation
 *  Input : a number of instances per code of a hierarchical terminology
 *  Output : a json well formated for Treejs to display this terminology and to show number of instances
 * @author cossin
 *
 */

public class GetTreeJsHierarchy implements FileQuery {

	final static Logger logger = LoggerFactory.getLogger(GetTreeJsHierarchy.class);
	
	/**
	 * Name of the file sent
	 */
	public final String fileName = "TreeJsJson.json";
	
	/**
	 * Treejs needs a json file
	 */
	private final String MIMEtype = "application/json";
	
	private Terminology terminology;
	
	private LinkedHashMap<IRI, Code> mapIRIcodes ;
	
	/**
	 * 
	 * @param terminology
	 * @throws RDFParseException
	 * @throws RepositoryException
	 * @throws IOException
	 * @throws UnfoundFilterException 
	 */
	
	public GetTreeJsHierarchy(Terminology terminology) throws RDFParseException, RepositoryException, IOException, UnfoundFilterException {
		this.terminology = terminology;
		this.mapIRIcodes = terminology.getHierarchy().getMapIRIcode();
	}
	
	/****************************** Methods to change instances number  ***********************
	
	/**
	 * Set the number of instances of a codeIRI
	 * @param codeIRI
	 * @param number
	 * @throws IOException 
	 * @throws UnfoundFilterException 
	 * @throws RepositoryException 
	 * @throws RDFParseException 
	 */
	public void setNumber(IRI codeIRI, int number) throws RDFParseException, RepositoryException, UnfoundFilterException, IOException{
		mapIRIcodes.get(codeIRI).setNumber(number);
	}
	
	/**
	 * reset the number of all {@link hierarchy.Code} instances to initial value 0
	 */
	public void resetNumbers(){
		Iterator<Code> iter = mapIRIcodes.values().iterator();
		while(iter.hasNext()){
			Code code = iter.next();
			code.setNumber(0);
		}
	}
	
	/**
	 * Set the number of instances of a codeIRI received from the client
	 * @param codeName the local name of a codeIRI.  
	 * @param number the number of instances of this code
	 * @throws UnfoundInstanceOfTerminologyException
	 */
	public void setCodeNumber (String codeName, int number) throws UnfoundInstanceOfTerminologyException{
		IRI codeIRI = terminology.makeInstanceIRI(codeName);
		if (!mapIRIcodes.containsKey(codeIRI)){
			throw new UnfoundInstanceOfTerminologyException(logger, codeName, terminology.getTerminologyName());
		}
		mapIRIcodes.get(codeIRI).setNumber(number);
	}
	
	/**
	 * Recursively calculate the number of instances in a hierarchy (the number of instances of a code depends on the number of its children)
	 */
	public void setAllCodesNumber(){
		IRI mainClassIRI = terminology.getMainClassIRI();
		setCodeNumber(mapIRIcodes.get(mainClassIRI)); // recursive function
	}
	
	private void setCodeNumber(Code code){
		// update children first : 
		for (IRI childIRI : code.getChildren()){
			setCodeNumber(mapIRIcodes.get(childIRI)); // set the number of all its children first
		}
		
		// when all children of this code are set, then calculate the number  
		int number = 0 ; 
		for (IRI childIRI : code.getChildren()){
			Code childClass = mapIRIcodes.get(childIRI);
			number = number + childClass.getNumber();
		}
		
		if (number != 0){ // it seems useless to test this because default value is 0 and if all children have 0 then it's 0
			// but ! if user set a number of instances for a parent code, we must not replace this number
			// but if children have number != 0 then the number of instances of a parent will be calculated and may replace a previous value set by the user
			code.setNumber(number);
		}
	}
	
	
	/****************************** Methods to set the JSON file  ***********************
	/** Creating the right Json for shinyTree is not trivial and very tricky
	 * We must understand well the expected format of the json file
	 * @return
	 */
	private JSONObject getShinyTreeJson(){
		IRI mainClassIRI = terminology.getMainClassIRI();
		Code mainCode = mapIRIcodes.get(mainClassIRI);
		JSONObject childObject = (JSONObject) getJsonPart(mainCode); // get JSONObject recursively
		JSONObject obj = new JSONObject(); 
		obj.put(mainCode.getLabelNumber(), childObject);
		return(obj);
	}
	
	/**
	 * Get the right object (JSONObject or JSONArray) for a code
	 * @param code A terminology {@link hierarchy.Code}
	 * @return Object : JSONObject or JSONArray
	 */
	private Object getJsonPart(Code code){
		if (code.getNumber() == 0){ // if code has 0 instances, return null so it'll not be sent and displayed on the dataviz
			return(null);
		}
		
		if (code.getChildren().size() == 0){ // if code has no child : we must return an array
			return(getChildArray(code));
		}
		
		// else we must return a JSONObject
		JSONObject childObject = new JSONObject(); 
		int iter = 0;
		for (IRI childIRI : code.getChildren()){
			Code childCode = mapIRIcodes.get(childIRI);
			if (childCode.getNumber() == 0){
				continue;
			}
			childObject.put(childCode.getLabelNumber(), getJsonPart(childCode));
			iter ++ ;
		}
		if (iter == 0){ // but if all children have 0 instances, childObject is empty => the parent have no children ; the parent is considered as a child
			return(getChildArray(code)); // so we must return an array
		} else {
			return(childObject); // return an object if this parent has at least one child with number greater than 0 
		}
	}
	
	private JSONArray getChildArray(Code code){
		JSONArray childArray = new JSONArray();
		childArray.add(code.getLabel());
		return(childArray);
	}
	
	
	
	/******************************************* Methods expected by the FileQuery interface *******************/
	@Override
	public void sendBytes(OutputStream os) throws IOException {
		JSONObject obj = getShinyTreeJson();
		os.write(obj.toString().getBytes());
	}
	
	@Override
	public String getFileName() {
		return fileName;
	}

	@Override
	public String getMIMEtype() {
		return(MIMEtype);
	}
}
