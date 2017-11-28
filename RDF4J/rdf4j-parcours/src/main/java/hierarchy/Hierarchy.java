package hierarchy;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.vocabulary.RDFS;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.rio.RDFParseException;

import query.Query;
import terminology.Terminology;

public class Hierarchy {
	
	/**
	 * Mapping the IRI code of a terminology to its {@link hierarchy.Code} representation
	 */
	private LinkedHashMap<IRI, Code> mapIRIcodes = new LinkedHashMap<IRI, Code>();
	
	public LinkedHashMap<IRI, Code> getMapIRIcode(){
		return(mapIRIcodes);
	}
	
	/******************************************** Constructor  **************************************
	 * 
	 * @param terminology
	 * @throws RDFParseException
	 * @throws RepositoryException
	 * @throws IOException
	 */
	
	public Hierarchy(Terminology terminology) throws RDFParseException, RepositoryException, IOException{
		setMapIRIcodes(terminology.getOntologyCon(), terminology.getMainClassIRI(),null); // set the map
	}
	
	
/********************************* private methods used to initialize MapIRIcodes **********/
	
	/**
	 * Create {@link Code} and add recursively all its children.
	 * This method should be called with the top class of the hierarchy. 
	 * @param terminologyCon A connection to the terminology hierarchy
	 * @param codeIRI
	 * @param parentIRI
	 */
	private void setMapIRIcodes(RepositoryConnection terminologyCon, IRI codeIRI, IRI parentIRI){
		if (mapIRIcodes.containsKey(codeIRI)){ // if class already known : another parent created it already
			mapIRIcodes.get(codeIRI).addParent(parentIRI);
			return;
		}
		
		Code code = new Code(codeIRI);
		code.setLabel(getLabel(terminologyCon,codeIRI));
		code.addParent(parentIRI);
		
		
		Set<IRI> childrenIRI = getSubClassOf(terminologyCon, codeIRI);
		
		for (IRI childIRI : childrenIRI){
			code.addChild(childIRI);
			setMapIRIcodes(terminologyCon, childIRI,codeIRI); // get children recursively
		}
		mapIRIcodes.put(codeIRI, code);
	}
	
	/**
	 * Get the label of a code IRI. 
	 * We expected each codeIRI to have a label with the RDF.LABEL relation
	 * @param terminologyCon A connection to the terminology hierarchy
	 * @param codeIRI A code IRI of the terminology 
	 * @return the label of the codeIRI or null
	 */
	private String getLabel(RepositoryConnection terminologyCon, IRI codeIRI){
		RepositoryResult<Statement> statements = terminologyCon.getStatements(codeIRI, RDFS.LABEL, null);
		String label = null;
		if (statements.hasNext()){
			Statement stat = statements.next();
			label = stat.getObject().stringValue();
		}
		statements.close();
		return(label);
	}
	
	/**
	 * Get all the children IRI of the codeIRI
	 * @param terminologyCon A connection to the terminology hierarchy
	 * @param codeIRI A code IRI of the terminology 
	 * @return
	 */
	private Set<IRI> getSubClassOf(RepositoryConnection terminologyCon, IRI codeIRI){
		String queryString = "SELECT ?code where { \n"
				+ "?code rdfs:subClassOf " + Query.formatIRI4query(codeIRI) + " . } \n" + 
				// + "?code rdfs:label ?label . }" + 
				"ORDER BY ?code";
		Set<IRI> childrenIRI = new LinkedHashSet<IRI>();
		TupleQuery query = terminologyCon.prepareTupleQuery(queryString);
		TupleQueryResult results = query.evaluate();
		while(results.hasNext()){
			BindingSet line = results.next();
			Value value = line.getBinding("code").getValue();
			IRI childIRI = (IRI) value ;
			childrenIRI.add(childIRI);
		}
		results.close();
		return(childrenIRI);
	}
	
}
