package servlet;

import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.util.HashMap;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.vocabulary.RDFS;
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

import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;

public class SunburstHierarchy {

	final static Logger logger = LoggerFactory.getLogger(SunburstHierarchy.class);
	
	private HashMap<IRI,IRI> childParent= new HashMap<IRI,IRI>();
	
	public void setChildParent(RepositoryConnection con, IRI eventIRI) throws Exception{
		RepositoryResult<Statement> statements = con.getStatements(null, RDFS.SUBCLASSOF, eventIRI);
		while(statements.hasNext()){
			Statement stat = statements.next();
			IRI subIRI = (IRI)stat.getSubject();
			if (childParent.containsKey(subIRI)){
				throw new Exception ("This class does not handle multiaxial terminology");
			}
			childParent.put(subIRI, eventIRI);
			setChildParent(con, subIRI); // get children recursively
		}
		statements.close();
	}
	
	public IRI getParent(IRI child){
		return(childParent.get(child));
	}
	
	public HashMap<String,String> getHierarchy(){
		HashMap<String,String> classLocation = new HashMap<String,String>();
		for (IRI child : childParent.keySet()){
			String childName = child.getLocalName();
			StringBuilder sb = new StringBuilder();
			sb.insert(0,child.getLocalName());
			sb.insert(0,"-");
			while ((child = getParent(child)) != null){
				sb.insert(0,child.getLocalName());
				sb.insert(0,"-");
			}
			sb.deleteCharAt(0); // remove first -
			classLocation.put(childName, sb.toString());
			System.out.println(sb.toString());
		}
		return(classLocation);
	}
	
	public IRI test (){
		return(null);
	}
	
	public static void main(String[] args) throws Exception {
		// TODO Auto-generated method stub
		
		InputStream ontologyInput = Util.classLoader.getResourceAsStream(MainResources.ontologyFileName);
		
		// p RDF triple in memory : 
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		RepositoryConnection con = rep.getConnection();
		try {
			con.add(ontologyInput, EIG.NAMESPACE, RDFFormat.TURTLE);
			ontologyInput.close();
		} catch (RDFParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (RepositoryException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		IRI eventIRI = Util.vf.createIRI(EIG.NAMESPACE,EIG.eventClassName);
		
		SunburstHierarchy test = new SunburstHierarchy();
		test.setChildParent(con, eventIRI);
		HashMap<String,String> hierarchy = test.getHierarchy();
		
		FileWriter fw = new FileWriter("hierarchy4sunburst.txt");
		StringWriter writer = new StringWriter();
		for (String className : hierarchy.keySet()){
			writer.write(className + "\t" + hierarchy.get(className) + "\n");
		}
		fw.write(writer.toString());
		writer.close();
		fw.close();
		con.close();
		rep.shutDown();
		
}
}
