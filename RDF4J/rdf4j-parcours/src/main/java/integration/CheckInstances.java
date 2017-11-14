package integration;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.vocabulary.OWL;
import org.eclipse.rdf4j.model.vocabulary.RDF;
import org.eclipse.rdf4j.model.vocabulary.RDFS;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.BooleanQuery;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.sail.memory.MemoryStore;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.IncomparableValueException;
import exceptions.MyExceptions;
import exceptions.UnfoundClassException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundFilterException;
import exceptions.UnfoundInstanceOfTerminologyException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import query.Query;
import terminology.OneClass;
import terminology.Predicates;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class CheckInstances {

	final static Logger logger = LoggerFactory.getLogger(CheckInstances.class);
	
	private String[] knownNS = {RDF.NAMESPACE, RDFS.NAMESPACE, OWL.NAMESPACE};
	
	private Repository rep ;
	private RepositoryConnection instancesCon ;
	private Terminology terminology;
	
	private Set<OneClass> classes = new HashSet<OneClass>();
	
	private Set<Predicates> predicates = new HashSet<Predicates>();
	
	public CheckInstances(Terminology terminology) throws RDFParseException, RepositoryException, IOException{
		this.terminology = terminology;
		// p RDF triple in memory : 
		rep = new SailRepository(new MemoryStore());
		rep.initialize();
		instancesCon = rep.getConnection();
		 logger.info("Connection to instances... ");
		InputStream instancesInput = new FileInputStream(terminology.getInstancesFile());
		instancesCon.add(instancesInput, terminology.getNAMESPACE(), RDFFormat.TURTLE);
		logger.info("done... ");
		instancesInput.close();
	}
	
	public void closeConnections(){
		instancesCon.close();
		rep.shutDown();
	}
	
	String queryStringType = "SELECT distinct ?type where { \n"
			+ "?s a ?type }"; 
	
	
	public String getQueryStringPredicate(OneClass oneClass){
		IRI classIRI = oneClass.getClassIRI();
		String queryStringPredicate = "SELECT distinct ?predicate where { \n" + 
				"?s a " + Query.formatIRI4query(classIRI) +  ". \n" + 
				"?s ?predicate ?o . }\n";
		return(queryStringPredicate);
	}
	
	public String getQueryStringValue(Predicates predicate){
		IRI predicateIRI = predicate.getPredicateIRI();
		String queryStringPredicate = "SELECT distinct ?value where { \n" + 
				"?s " + Query.formatIRI4query(predicateIRI) +  " ?value } " ;
		return(queryStringPredicate);
	}
	
	public TupleQueryResult getQueryResults(String queryString){
		TupleQuery query = instancesCon.prepareTupleQuery(queryString);
		TupleQueryResult results = query.evaluate();
		return(results);
	}
	
	public void checkType() throws UnfoundClassException, RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		System.out.println("checking type...");
		TupleQueryResult results = getQueryResults(queryStringType);
		while(results.hasNext()){
			BindingSet line = results.next();
			Value value = line.getBinding("type").getValue();
			IRI instanceIRI = (IRI) value ;
			System.out.println("\t" + instanceIRI.stringValue());
			try {
				classes.add(terminology.getClassDescription().getClass(instanceIRI.getLocalName()));
			} catch (UnfoundEventException e ) {
				throw new UnfoundClassException(logger,instanceIRI.stringValue(), terminology.getTerminologyName());
			}
		}
		results.close();
	}
	
	public void checkValue () throws IncomparableValueException, UnfoundTerminologyException, UnfoundInstanceOfTerminologyException, RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		for (Predicates predicate : predicates){
			checkExpectedValue(predicate);
		}
	}
	
	private Boolean checkDataType(Value expectedValue, Value value){
		String valueString = value.toString();
		String expectedValueString = "<" + expectedValue.toString() + ">";
		int lengthExpectedValueString = expectedValueString.length();
		String endValueString = valueString.substring(valueString.length() - lengthExpectedValueString, 
				valueString.length());
		Boolean isEqualDataType = endValueString.equals(expectedValueString);
		if (isEqualDataType){
			return(true);
		} else {
			return(false);
		}
	}
	
	private Boolean isInstance(IRI instanceIRI, IRI mainClassIRI){
		String askQueryString = "ASK { "  + Query.formatIRI4query(instanceIRI) + " a " + Query.formatIRI4query(mainClassIRI) + " . }" ; 
		BooleanQuery isInstanceQuery = instancesCon.prepareBooleanQuery(askQueryString);
		boolean isInstance = isInstanceQuery.evaluate();
		return(isInstance);
	}
	
	private Boolean checkObjectType (Value expectedValue, Value value) throws UnfoundTerminologyException, UnfoundInstanceOfTerminologyException, RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		IRI mainClassNameIRI = (IRI) expectedValue;
		IRI instanceIRI = (IRI) value;
		// check locally : 
		if (isInstance(instanceIRI,mainClassNameIRI)) {
			return(true);
		}
		// check in others terminologies
		Terminology terminologyTarget = TerminologyInstances.getTerminologyByMainClassIRI(mainClassNameIRI);
		boolean isInstance = terminologyTarget.getTerminologyServer().isInstanceOfTerminology(instanceIRI);
		if (isInstance){
			return(true);
		} else {
			throw new UnfoundInstanceOfTerminologyException(logger,instanceIRI.stringValue(), 
					expectedValue.stringValue());
		}
	}
	
	private void checkExpectedValue (Predicates predicate) throws IncomparableValueException, UnfoundTerminologyException, UnfoundInstanceOfTerminologyException, RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		System.out.println("checking expected values of " + predicate.getPredicateIRI().getLocalName());
		TupleQueryResult results = getQueryResults(getQueryStringValue(predicate));
		
		Value expectedValue = predicate.getExpectedValue();
		boolean isDataType = !predicate.getIsObjectProperty();
		System.out.println("expected:" + expectedValue.stringValue());
		
		while(results.hasNext()){
			BindingSet line = results.next();
			Value value = line.getBinding("value").getValue();
			// System.out.println("\t value : " + value.toString());
			
			Boolean isExpected ;
			if (isDataType){
				isExpected = checkDataType(expectedValue, value);
			} else {
				isExpected = checkObjectType(expectedValue, value);
			}
			
			if (!isExpected){
				String msg = "expected : " + expectedValue.toString() + " got : " + value.toString() + " for predicate: " +
			predicate.getPredicateIRI().getLocalName() + " in terminology : " + terminology.getTerminologyName();
				throw new IncomparableValueException(logger, msg);
			}
		}
		results.close();
	}
	
	public void checkPredicates() throws UnfoundClassException, UnfoundEventException, UnfoundPredicatException, RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		for (OneClass oneClass : classes){
			checkEachPredicate(oneClass);
		}
	}
	
	private Boolean isKnownNS(String predicateNS){
		for (String NS : knownNS){
			if (predicateNS.equals(NS)){
				return(true);
			}
		}
		return(false);
	}
	
	private void checkEachPredicate(OneClass oneClass) throws UnfoundClassException, UnfoundEventException, UnfoundPredicatException, RDFParseException, RepositoryException, IOException, UnfoundFilterException{
		System.out.println("checking predicates of " + oneClass.getClassIRI().getLocalName());
		TupleQueryResult results = getQueryResults(getQueryStringPredicate(oneClass));
		while(results.hasNext()){
			BindingSet line = results.next();
			Value value = line.getBinding("predicate").getValue();
			IRI predicateIRI = (IRI) value ;
			if (isKnownNS(predicateIRI.getNamespace())){
				continue;
			}
			System.out.println("\t" + predicateIRI.stringValue());
			if (!terminology.isPredicateOfClass(predicateIRI, oneClass)){
				String msg = predicateIRI.getLocalName() + " not a predicate of class " + oneClass.getClassIRI().getLocalName() + 
						" in terminology : " + terminology.getTerminologyName();
				MyExceptions.logMessage(logger, msg);
				throw new UnfoundPredicatException(logger,predicateIRI.stringValue());
			};
			predicates.add(terminology.getPredicateDescription().getPredicate(predicateIRI));
		}
		results.close();
	}
	
	
	public static void main(String[] args) throws RDFParseException, RepositoryException, IOException, UnfoundClassException, UnfoundEventException, UnfoundPredicatException, IncomparableValueException, UnfoundTerminologyException, UnfoundInstanceOfTerminologyException, UnfoundFilterException {
		for (Terminology terminology : TerminologyInstances.terminologies){
			CheckInstances checkInstances = new CheckInstances(terminology);
			checkInstances.checkType();
			checkInstances.checkPredicates();
			checkInstances.checkValue();
			checkInstances.closeConnections();
		}
		TerminologyInstances.closeConnections();
	}

}
