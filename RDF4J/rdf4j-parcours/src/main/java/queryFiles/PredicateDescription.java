package queryFiles;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Literal;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.datatypes.XMLDatatypeUtil;
import org.eclipse.rdf4j.model.vocabulary.OWL;
import org.eclipse.rdf4j.model.vocabulary.RDFS;
import org.eclipse.rdf4j.query.BooleanQuery;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.sail.memory.MemoryStore;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundPredicatException;
import ontologie.EIG;
import parameters.Util;
import query.Query;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class PredicateDescription {

	final static Logger logger = LoggerFactory.getLogger(PredicateDescription.class);
	
	public enum ValueCategory {
		NUMERIC, DURATION, DATE, FACTOR, TERMINOLOGY, SPATIALPOLYGON;
	}
	
	private HashMap<IRI, Predicates> predicatesMap = new HashMap<IRI, Predicates>();
	
	public HashMap<IRI, Predicates> getPredicatesMap(){
		return(predicatesMap);
	}
	
	public Predicates getPredicate(IRI predicateIRI) throws UnfoundPredicatException{
		if (predicatesMap.containsKey(predicateIRI)){
			return(predicatesMap.get(predicateIRI));
		} else {
			throw new UnfoundPredicatException(logger, predicateIRI.getLocalName());
		}
	}
	
	public Predicates getPredicate(String predicateName) throws UnfoundPredicatException{
		for (IRI predicateIRI : predicatesMap.keySet()){
			if (predicateIRI.getLocalName().equals(predicateName)){
				return(predicatesMap.get(predicateIRI));
			}
		}
		throw new UnfoundPredicatException(logger, predicateName);
	}
	
	public PredicateDescription(Terminology terminology) throws IOException{
		String path = terminology.getOntologyFileName();
		InputStream ontologyInput = Util.classLoader.getResourceAsStream(path);
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		RepositoryConnection ontologyCon = rep.getConnection();		
		ontologyCon.add(ontologyInput, terminology.getNAMESPACE(), Util.DefaultRDFformat);
		
		setPredicates(ontologyCon);
		setPredicateComment(ontologyCon);
		setPredicateLabel(ontologyCon);
		setPredicateIsObjectProperty(ontologyCon);
		setValueCategory();

		
		ontologyInput.close();
		ontologyCon.close();
		rep.shutDown();
	}
	
	private void setPredicates(RepositoryConnection ontologyCon){
		// Predicates : 
		RepositoryResult<Statement> values = ontologyCon.getStatements(null, RDFS.RANGE, null);
		while(values.hasNext()){
			Statement statement = values.next();
			IRI predicateIRI = (IRI) statement.getSubject();
				if (!predicatesMap.containsKey(predicateIRI)){
					predicatesMap.put(predicateIRI, new Predicates(predicateIRI));
				}
				Value value = statement.getObject();
				predicatesMap.get(predicateIRI).setValue(value);
		}
		values.close();
	}
	
	private void setPredicateIsObjectProperty (RepositoryConnection ontologyCon){
	    Iterator<Entry<IRI, Predicates>> iter = predicatesMap.entrySet().iterator();
	    while (iter.hasNext()) {
	    	Entry<IRI, Predicates> entry = iter.next();
	    	IRI predicateIRI = entry.getKey();
			String queryString = "ASK { " + Query.formatIRI4query(predicateIRI) + "a" +
					Query.formatIRI4query(OWL.DATATYPEPROPERTY) + "}";
			BooleanQuery isDataTypeQuery = ontologyCon.prepareBooleanQuery(queryString);
			boolean isDataType = isDataTypeQuery.evaluate();
			entry.getValue().setIsObjectProperty(!isDataType);
	    }
	}
	
	private void setPredicateComment(RepositoryConnection ontologyCon){
		RepositoryResult<Statement> values = ontologyCon.getStatements(null, RDFS.COMMENT, null);
		while(values.hasNext()){
			Statement statement = values.next();
			IRI predicateIRI = (IRI) statement.getSubject();
			if (predicatesMap.containsKey(predicateIRI)){
				Literal comment = (Literal) statement.getObject();
				predicatesMap.get(predicateIRI).addComment(comment);
			}
		}
		values.close();
	}
	
	private void setPredicateLabel(RepositoryConnection ontologyCon){
		RepositoryResult<Statement> values = ontologyCon.getStatements(null, RDFS.LABEL, null);
		while(values.hasNext()){
			Statement statement = values.next();
			IRI predicateIRI = (IRI) statement.getSubject();
			if (predicatesMap.containsKey(predicateIRI)){
				Literal label = (Literal) statement.getObject();
				predicatesMap.get(predicateIRI).addLabel(label);
			}
		}
		values.close();
	}
	
	private void setValueCategory(){
		Iterator<Predicates> iter = getPredicatesMap().values().iterator();
		while(iter.hasNext()){
			Predicates predicate = iter.next();
			predicate.setValueCategory(getValueCategory(predicate.getPredicateIRI(), predicate.getExpectedValue()));
		}
	}
	
	private ValueCategory getValueCategory (IRI predicateIRI, Value value){
		IRI valueIRI = (IRI) value;
		
		if (predicateIRI.equals(EIG.HASPOLYGON)){
			return(ValueCategory.SPATIALPOLYGON);
		}
		
		if (XMLDatatypeUtil.isNumericDatatype(valueIRI)){
			// Special case : 
			if (predicateIRI.equals(EIG.HASDURATION)){
				return(ValueCategory.DURATION);
			}
			return(ValueCategory.NUMERIC);
		}
		
		if (XMLDatatypeUtil.isCalendarDatatype(valueIRI)){
			return(ValueCategory.DATE);
		}

		if (TerminologyInstances.isRecognizedClassName(valueIRI)){
			return(ValueCategory.TERMINOLOGY);
		}
		return(ValueCategory.FACTOR); // default
	}
}
