package hierarchy;

import java.io.BufferedReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.vocabulary.RDFS;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.sail.memory.MemoryStore;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundInstanceOfTerminologyException;
import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;
import query.Query;
import queryFiles.FileQuery;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class HandleHierarchy implements FileQuery{

	final static Logger logger = LoggerFactory.getLogger(HandleHierarchy.class);
	
	public final String fileName = "shinyTreeJson.csv";
	
	private final String MIMEtype = "application/json";
	
	private HashMap<IRI, Code> classes = new HashMap<IRI, Code>();
	
	public HashMap getClasses(){
		return(classes);
	}
	
	private Terminology terminology ;
	
	private String getLabel(RepositoryConnection con, IRI classIRI){
		RepositoryResult<Statement> statements = con.getStatements(classIRI, RDFS.LABEL, null);
		Statement stat = statements.next();
		String label = stat.getObject().stringValue();
		statements.close();
		return(label);
	}
	
	private Set<IRI> getSubClassOf(RepositoryConnection con, IRI classIRI){
		String queryString = "SELECT ?code where { \n"
				+ "?code rdfs:subClassOf " + Query.formatIRI4query(classIRI) + " . \n"
				+ "?code rdfs:label ?label . }" + 
				"ORDER BY ?code";
		Set<IRI> childrenIRI = new HashSet<IRI>();
		TupleQuery query = con.prepareTupleQuery(queryString);
		TupleQueryResult results = query.evaluate();
		while(results.hasNext()){
			BindingSet line = results.next();
			Value value = line.getBinding("code").getValue();
			IRI childIRI = (IRI) value ;
			childrenIRI.add(childIRI);
		}
		results.close();
//		RepositoryResult<Statement> statements = con.getStatements(null, RDFS.SUBCLASSOF, classIRI);
//		while(statements.hasNext()){
//			Statement stat = statements.next();
//			IRI childIRI = (IRI)stat.getSubject();
//			childrenIRI.add(childIRI);
//		}
//		statements.close();
		return(childrenIRI);
	}
	
	public void setNumber(IRI codeIRI, int number){
		classes.get(codeIRI).setNumber(number);
	}
	
	private void setChildParent(RepositoryConnection con, IRI classIRI, IRI parentIRI){
		if (classes.containsKey(classIRI)){ // if class already known : another parent created it already
			classes.get(classIRI).addParent(parentIRI);
			return;
		}
		
		Code code = new Code(classIRI);
		code.addParent(parentIRI);
		code.setLabel(getLabel(con,classIRI));
		
		Set<IRI> childrenIRI = getSubClassOf(con, classIRI);
		
		for (IRI childIRI : childrenIRI){
			code.addChild(childIRI);
			setChildParent(con, childIRI,classIRI); // get children recursively
		}
		classes.put(classIRI, code);
	}
	
	public void setCodeNumber (String codeName, int number) throws UnfoundInstanceOfTerminologyException{
		IRI codeIRI = terminology.makeInstanceIRI(codeName);
		//System.out.println("recherche dans classes ce code : " + codeIRI.stringValue());
		if (!classes.containsKey(codeIRI)){
			throw new UnfoundInstanceOfTerminologyException(logger, codeName, terminology.getTerminologyName());
		}
		classes.get(codeIRI).setNumber(number);
	}
	
	public void setAllCodesNumber(){
		IRI mainClassIRI = terminology.getMainClassIRI();
		setCodeNumber(classes.get(mainClassIRI));
	}
	
	private void setCodeNumber(Code code){
		// update children first : 
		for (IRI childIRI : code.getChildren()){
			setCodeNumber(classes.get(childIRI));
		}
		// update number then 
		int number = 0 ; 
		// update children first : 
		for (IRI childIRI : code.getChildren()){
			Code childClass = classes.get(childIRI);
			number = number + childClass.getNumber();
		}
		if (number != 0){ // case no children too
			code.setNumber(number);	
		}
	}
	
	
	/** Creating the right Json for shinyTree is not trivial and very tricky
	 * 
	 * @return
	 */
	public Object getShinyTreeJson(){
		IRI mainClassIRI = terminology.getMainClassIRI();
		Code mainCode = classes.get(mainClassIRI);
		JSONObject childObject = (JSONObject) getJsonPart(mainCode); // get JSONObject recursively
		JSONObject obj = new JSONObject(); 
		obj.put(mainCode.getLabelNumber(), childObject);
		return(obj);
	}
	
	
	private JSONArray getChildArray(Code code){
		JSONArray childArray = new JSONArray();
		childArray.add(code.getLabel());
		return(childArray);
	}
	
	/**
	 * 
	 * @param code A terminology code
	 * @return Object : JSONObject or JSONArray
	 */
	private Object getJsonPart(Code code){
		if (code.getNumber() == 0){ // if code has 0 number, it'll not appear
			return(null);
		}
		
		if (code.getChildren().size() == 0){ // if code has no child : it must return an array
			//System.out.println(code.getLabel() + "has no child");
			return(getChildArray(code));
		}
		
		//System.out.println(code.getLabel() + "has children");
		
		JSONObject childObject = new JSONObject(); 
		int iter = 0;
		for (IRI childIRI : code.getChildren()){
			Code childCode = classes.get(childIRI);
			if (childCode.getNumber() == 0){
				continue;
			}
			//System.out.println(code.getLabel() + " has a child with number different of 0 : " + childCode.getLabel());
			childObject.put(childCode.getLabelNumber(), getJsonPart(childCode));
			iter ++ ;
		}
		if (iter == 0){ // no child has number != 0 ; as child with 0 will not appear, this parent code becomes a child
			return(getChildArray(code)); // so it must return array
		} else {
			return(childObject); // return an object if this parent has at least one child with number greater than 0 
		}
	}
	
	public void printNmainClass(){
		int number = classes.get(terminology.getMainClassIRI()).getNumber();
		System.out.println("mainClassNumber : " + number);
	}
	
	public HandleHierarchy(Terminology terminology) throws RDFParseException, RepositoryException, IOException{
		this.terminology = terminology;
		// TODO Auto-generated method stub
		InputStream ontologyInput = Util.classLoader.getResourceAsStream(terminology.getOntologyFileName());
		// p RDF triple in memory : 
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		RepositoryConnection con = rep.getConnection();
		con.add(ontologyInput, terminology.getNAMESPACE(), RDFFormat.TURTLE);
		ontologyInput.close();
		IRI classNameIRI = terminology.getMainClassIRI();
		setChildParent(con, classNameIRI,null);
		con.close();
		rep.shutDown();
	}
	
	public void showKeyset(){
		for (IRI codeIRI : classes.keySet()){
			System.out.println(codeIRI.stringValue());
		}
	}
	
	public static void main(String args[]) throws RDFParseException, RepositoryException, UnfoundTerminologyException, IOException, UnfoundInstanceOfTerminologyException{
		
		Path filePath = Paths.get(MainResources.chargementFolder + "test.csv");
		BufferedReader br = Files.newBufferedReader(filePath,Util.charset);

        // first line from the text file
		String line = br.readLine();
		String separator = "\t";
		String[] columns = line.split(separator);
		String terminologyName = columns[0];
		
		HandleHierarchy handleHierarchy = new HandleHierarchy(TerminologyInstances.getTerminology(terminologyName));
		
		while ((line = br.readLine()) != null) {
			//System.out.println(line);
			columns = line.split(separator);
			String codeName = columns[1];
			int number = Integer.parseInt(columns[2]);
			handleHierarchy.setCodeNumber(codeName, number);
		}
		
		br.close();
		handleHierarchy.setAllCodesNumber();
//		int number = 10;
//		try {
//			handleHierarchy.setCodeNumber("A90", number);
//			handleHierarchy.setCodeNumber("B25", number);
//			handleHierarchy.setCodeNumber("C10", number);
//			handleHierarchy.setCodeNumber("I50", number);
//			handleHierarchy.setCodeNumber("I51", number);
//			handleHierarchy.setCodeNumber("I52", number);
//			handleHierarchy.setCodeNumber("I53", number);
//		} catch (UnfoundInstanceOfTerminologyException e) {
//			// TODO Auto-generated catch block
//		}
//		try {
//			handleHierarchy.setCodeNumber("Coma", number);
//		} catch (UnfoundInstanceOfTerminologyException e) {
//			// TODO Auto-generated catch block
//		}
		

		JSONObject obj = (JSONObject) handleHierarchy.getShinyTreeJson();
		//System.out.println("\nJSON Object: " + obj.toJSONString());
		
		try (FileWriter file = new FileWriter("file1.json")) {
			file.write(obj.toString());
			System.out.println("Successfully Copied JSON Object to File...");
		}
		
	}

	@Override
	public void sendBytes(OutputStream os) throws IOException {
		JSONObject obj = (JSONObject) getShinyTreeJson();
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
