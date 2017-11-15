package queryFiles;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;

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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;
import query.Query;
import servlet.GetTimeline;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class GetSunburstHierarchyLabel implements FileQuery{

	final static Logger logger = LoggerFactory.getLogger(GetSunburstHierarchyLabel.class);
	
	public final String fileName = "Hierarchy4Sunburst.csv";
	private final String MIMEtype = "text/csv";
	
	private HashMap<String,String> childParentLabel = new HashMap<String,String>();

	private HashMap<String, String> hierarchy;
	
	private HashMap<String, IRI> codeIRIlabel = new HashMap<String,IRI>();

	private Terminology terminology;
	
	private String labelMainClass = null;
	
	File resultFile = null; 
	
	private void setFile(){
		String cacheFolder = MainResources.cacheFolder ;
		String cacheFolderPath = Util.classLoader.getResource(cacheFolder).getPath();
		String fileResultName = cacheFolderPath + "Cache-" + terminology.getTerminologyName() + "-" + fileName;
		resultFile = new File(fileResultName);
	}
	
	private String getQueryString(IRI classIRI){
		String queryString = "SELECT ?code ?labelSub ?label where { \n " +
				"?code rdfs:subClassOf " + Query.formatIRI4query(classIRI) + ". \n " +
				Query.formatIRI4query(classIRI) + "rdfs:label ?label . \n" + 
				"?code rdfs:label ?labelSub } \n";
		return(queryString);
	}
	
	private String getLabel(RepositoryConnection ontologyCon, IRI eventIRI){
		RepositoryResult<Statement> values = ontologyCon.getStatements(eventIRI, RDFS.LABEL, null);
		String label = null;
		while(values.hasNext()){
			Statement statement = values.next();
			label = statement.getObject().stringValue();
		}
		values.close();
		return(label);
	}
	
	private void setLabel(RepositoryConnection ontologyCon, IRI eventIRI){
		String label = getLabel(ontologyCon, eventIRI);
		codeIRIlabel.put(label, eventIRI);
	}
	
	private void setChildParent(RepositoryConnection con, IRI eventIRI){
		setLabel(con, eventIRI);
		String queryString = getQueryString(eventIRI);
		TupleQuery keywordQuery = con.prepareTupleQuery(queryString);
		TupleQueryResult tupleResult = keywordQuery.evaluate();
		while(tupleResult.hasNext()){
			BindingSet set = tupleResult.next();
			Value value = set.getValue("labelSub");
			String labelSub = value.stringValue();
			value = set.getValue("label");
			String label = value.stringValue();
			childParentLabel.put(labelSub, label);
			value = set.getValue("code");
			IRI subIRI = (IRI) value;
			setChildParent(con, subIRI); // get children recursively
		}
		tupleResult.close();
	}
	
	public String getParent(String childName){
		return(childParentLabel.get(childName));
	}
	
	public HashMap<String,String> getHierarchyLabel(){
		HashMap<String,String> classLocation = new HashMap<String,String>();
		for (String childName : childParentLabel.keySet()){
			String initialChildName = childName;
			StringBuilder sb = new StringBuilder();
			sb.insert(0,childName);
			sb.insert(0,"-");
			while ((childName = getParent(childName)) != null){
				sb.insert(0,childName);
				sb.insert(0,"-");
			}
			sb.deleteCharAt(0); // remove first -
			classLocation.put(initialChildName, sb.toString());
		}
		// add className
		classLocation.put(labelMainClass, labelMainClass);
		return(classLocation);
	}

	public boolean isFileAlreadyExists(){
		return(resultFile.exists());
	}
	
	public GetSunburstHierarchyLabel(Terminology terminology) throws RDFParseException, RepositoryException, IOException{
		// TODO Auto-generated method stub
		this.terminology = terminology;
		setFile();
		if (isFileAlreadyExists()){
			logger.info("File : " + resultFile.getName() + " already exist");
			return;
		}
		
		File ontologyFile = terminology.getOntologyFile();
		logger.info("loading " + ontologyFile.getName());
		// p RDF triple in memory :
		
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		RepositoryConnection con = rep.getConnection();
		con.add(ontologyFile, terminology.getNAMESPACE(), RDFFormat.TURTLE);
		setLabel(con, terminology.getMainClassIRI());
		labelMainClass = getLabel(con,  terminology.getMainClassIRI());
		IRI classNameIRI = terminology.getMainClassIRI();
		setChildParent(con, classNameIRI);
		this.hierarchy = getHierarchyLabel();
		con.close();
		rep.shutDown();
		writeFile();
	}

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
		
		for (String className : hierarchy.keySet()){
			System.out.println(className);
			String code = codeIRIlabel.get(className).getLocalName();
			line.append(code);
			line.append("\t");
			line.append(className);
			line.append("\t");
			line.append(hierarchy.get(className));
			line.append("\n");
			os.write(line.toString().getBytes());
			line.setLength(0);
		}
		os.close();
	}

	
	public void sendBytes(OutputStream os) throws IOException {
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
	
	public static void main (String[] args) throws RDFParseException, RepositoryException, IOException, UnfoundTerminologyException{
		Terminology terminology = TerminologyInstances.getTerminology("CIM10");
		GetSunburstHierarchyLabel getSunburstHierarchy = new GetSunburstHierarchyLabel(terminology);
		File file = new File("CIM10Hierarchy.csv");
		OutputStream os = new FileOutputStream(file);
		getSunburstHierarchy.sendBytes(os);
		os.close();
	}
}