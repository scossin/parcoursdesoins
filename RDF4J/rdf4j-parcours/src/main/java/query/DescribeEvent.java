package query;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;

import exceptions.UnfoundEventException;
import ontologie.EIG;
import ontologie.Event;
import ontologie.EventOntology;
import parameters.Util;

public class DescribeEvent implements Query{

	String eventValues;
	
	String predicatesValues;
	
	String WhereStatements;
	
	/**
	 * Return the good format of a IRI for a SPARQL query
	 * @param oneIRI a IRI (subject, predicate or object)
	 * @return String for a SPARQL query
	 */
	private String formatIRI4query (IRI oneIRI){
		return(" <" + oneIRI.stringValue()+"> ");
	}
	
	private void setValues(Set<IRI> eventLists){
		StringBuilder sb = new StringBuilder();
		sb.append("VALUES ?event { ");
		for (IRI eventIRI : eventLists){
			sb.append(formatIRI4query(eventIRI));
		}
		sb.append("} . \n");
		this.eventValues = sb.toString();
	}
	
	private void setWhereStatement(Event event) throws UnfoundEventException{
		Set<IRI> predicatesIRI = EventOntology.getPredicatesOfEvent(event);
		
		StringBuilder sb = new StringBuilder();
		sb.append("VALUES ?predicate { ");
		for (IRI predicateIRI : predicatesIRI){
			sb.append(formatIRI4query(predicateIRI));
		}
		sb.append("} .\n");
		this.predicatesValues = sb.toString();
	}
	
	public DescribeEvent(Set<IRI> eventLists, Event event) throws UnfoundEventException{
		setValues(eventLists);
		setWhereStatement(event);
	}
	


	public String getSPARQLQueryString() {
		StringBuilder sb = new StringBuilder();
		sb.append("SELECT ?context ?event ?predicate ?value WHERE {graph ?context { \n ");
		sb.append(eventValues);
		sb.append(predicatesValues);
		sb.append("?event ?predicate ?value . \n");
		sb.append("}} \n");
		return(sb.toString());
	}

	public static void main(String[] args) throws UnfoundEventException, IOException {
		
		
		// Event IRI
		IRI eventIRI = Util.vf.createIRI(EIG.NAMESPACE, "SejourMCO");
		Event event = EventOntology.getEvent(eventIRI);
		
		// Arraylist
		Set<IRI> eventLists = new HashSet<IRI>();
        BufferedReader br = new BufferedReader(new FileReader("eventLists.txt"));
        String line ;
        while((line = br.readLine())!=null){
        	eventLists.add(Util.vf.createIRI(line));
        }
        System.out.println(eventLists.size() + " event à décrire");
        br.close();

        DescribeEvent describe = new DescribeEvent(eventLists, event);
    	System.out.println(describe.getSPARQLQueryString());
        
        Results results = new Results(Util.sparqlEndpoint, describe);
		TupleQuery keywordQuery = results.getCon().getDBcon().prepareTupleQuery(describe.getSPARQLQueryString());
		TupleQueryResult keywordQueryResult = keywordQuery.evaluate();
		System.out.println("fin de l'évaluation");
        int counter=0;
        

        while(keywordQueryResult.hasNext()){
    		BindingSet set = keywordQueryResult.next();
    		IRI event0 = (IRI) set.getValue("event");
        	eventLists.remove(event0);
        	counter++;
        }
        System.out.println("total lignes de description : " + counter);
        System.out.println("nombre d'events non décrits : " + eventLists.size());
        for (IRI unIRI : eventLists){
        	System.out.println(unIRI.stringValue());
        }
        keywordQueryResult.close();
		results.getCon().close();
	}
}
