package inference;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map.Entry;
import java.util.Set;
import java.util.TreeSet;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.XMLGregorianCalendar;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Literal;
import org.eclipse.rdf4j.model.Resource;
import org.eclipse.rdf4j.model.Statement;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.model.vocabulary.RDF;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.sail.memory.MemoryStore;
import org.eclipse.rdf4j.sail.memory.model.CalendarMemLiteral;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.InvalidOntology;
import exceptions.UnfoundEventException;
import ontologie.EIG;
import ontologie.Event;
import ontologie.EventOntology;
import ontologie.TIME;
import parameters.MainResources;
import parameters.Util;
import query.Query;

public class Inference{
	final static Logger logger = LoggerFactory.getLogger(Inference.class);
	
	public static HashSet<Statement> setEIGtype (RepositoryConnection con) throws InvalidOntology{
		RepositoryResult<Statement> statements = con.getStatements(null, RDF.TYPE, null);
		HashSet<Statement> statements2 = new HashSet<Statement>() ;
		
		Set<Resource> eventType = new HashSet<Resource>();
		
		while(statements.hasNext()){
			
			Statement stat = statements.next();
			Resource subject = stat.getSubject();
			IRI typeIRI = (IRI) stat.getObject();
			if (!EventOntology.isEvent(typeIRI.getLocalName())){
				continue;
			}
			if (!typeIRI.getNamespace().equals(EIG.NAMESPACE)){ // timeInterval
				continue;
			}
			if (eventType.contains(subject)){
				throw new InvalidOntology(logger, "event must have only one type, do you run getSubClassOf inference before ?");
			}
			statements2.add(Util.vf.createStatement(subject, EIG.HASTYPE, stat.getObject()));
			eventType.add(subject);
		}
		
		return(statements2);
		
	}
	
	public static HashSet<Statement> getSubClassOf(RepositoryConnection con){
		
		RepositoryResult<Statement> statements = con.getStatements(null, RDF.TYPE, null);
		HashSet<Statement> statements2 = new HashSet<Statement>() ;
		
		while(statements.hasNext()){
			Statement stat = statements.next();
			Resource subject = stat.getSubject();
			IRI typeIRI = (IRI) stat.getObject();
			if (!EventOntology.isEvent(typeIRI.getLocalName())){
				continue;
			}
			try {
				Event event = EventOntology.getEvent(typeIRI.getLocalName());
				Set<IRI> parents = event.getParents();
				for (IRI parent : parents){
					statements2.add(Util.vf.createStatement(subject, RDF.TYPE, parent));
				}
			} catch (UnfoundEventException e){
				System.out.println("Impossible to reach !");
				e.printStackTrace();
			}
		}
		
		return(statements2);
	}
	
	public static HashSet<Statement> getNumbering(RepositoryConnection con){
		HashSet<Statement> statements2 = new HashSet<Statement>();
		HashMap<XMLGregorianCalendar,ArrayList<Value>> linkDateIRI = new HashMap<XMLGregorianCalendar,ArrayList<Value>>();
		
		String queryString = "SELECT ?event ?date where{"
				+ "?event " + Query.formatIRI4query(TIME.HASBEGINNING) + " ?eventStart . "
				+ "?eventStart " + Query.formatIRI4query(TIME.INXSDDATETIME) + "?date . }";
		
		TreeSet<XMLGregorianCalendar> dates = new TreeSet<XMLGregorianCalendar>(
				new Comparator<XMLGregorianCalendar>(){
					public int compare(XMLGregorianCalendar o1, XMLGregorianCalendar o2) {
						int nDay = o1.compare(o2);
						return(nDay);
					}
					
				});
		
		TupleQuery query = con.prepareTupleQuery(queryString);
		TupleQueryResult results = query.evaluate();
		while(results.hasNext()){
			BindingSet ligne = results.next();
			CalendarMemLiteral valeur = (CalendarMemLiteral) ligne.getBinding("date").getValue();
			XMLGregorianCalendar test = valeur.calendarValue();
			if (linkDateIRI.containsKey(test)){
				linkDateIRI.get(test).add(ligne.getBinding("event").getValue());
			} else {
				ArrayList<Value> temp = new ArrayList<Value>();
				temp.add(ligne.getBinding("event").getValue());
				linkDateIRI.put(test, temp);
			}
			dates.add(test);
		}
		results.close();
		// 
		int counter = 1;
		for (XMLGregorianCalendar date : dates){
			Literal number = Util.vf.createLiteral(counter);
			ArrayList<Value> temp = linkDateIRI.get(date);
			for (Value valeur : temp){
				statements2.add(Util.vf.createStatement((Resource) valeur, EIG.HASNUM, number));
			}
			counter ++ ;
		}
		return statements2;
	}
	
	
	public static HashSet<Statement> hasDuration(RepositoryConnection con) throws DatatypeConfigurationException{
		HashSet<Statement> statements2 = new HashSet<Statement>();
		
		HashMap<IRI,Integer> eventDuration = new HashMap<IRI,Integer>();
		
		String queryString = "SELECT ?event ?beginningDate ?endDate WHERE { \n "
				+ "?event " + Query.formatIRI4query(TIME.HASBEGINNING) + " ?eventStart . \n"
				+ "?eventStart " + Query.formatIRI4query(TIME.INXSDDATETIME) + " ?beginningDate . \n "
				+ "?event " + Query.formatIRI4query(TIME.HASEND) + " ?eventEnd . \n "
				+ "?eventEnd " + Query.formatIRI4query(TIME.INXSDDATETIME) + " ?endDate . \n }";
		
		TupleQuery query = con.prepareTupleQuery(queryString);
		
		TupleQueryResult results = query.evaluate();
		while(results.hasNext()){
			BindingSet row = results.next();
			
			CalendarMemLiteral beginningDateCal = (CalendarMemLiteral) row.getBinding("beginningDate").getValue();
			CalendarMemLiteral endDateCal = (CalendarMemLiteral) row.getBinding("endDate").getValue();
			XMLGregorianCalendar beginningDate = beginningDateCal.calendarValue();
			XMLGregorianCalendar endDate = endDateCal.calendarValue();
			IRI eventInstanceIRI = (IRI) row.getBinding("event").getValue();
			int duration = diffInSeconds(beginningDate, endDate) ;
			eventDuration.put(eventInstanceIRI, duration);
		}
		results.close();
		
		
		for (Entry<IRI, Integer> entry : eventDuration.entrySet()) {
		    IRI eventIRI = entry.getKey();
		    Literal durationSeconds = Util.vf.createLiteral(entry.getValue());
		    statements2.add(Util.vf.createStatement(eventIRI, EIG.HASDURATION, durationSeconds));
		}
		
		return(statements2);
	}
	
	private static int diffInSeconds(XMLGregorianCalendar o1, XMLGregorianCalendar o2) throws DatatypeConfigurationException{
		long diffMs = o2.toGregorianCalendar().getTimeInMillis() - 
				o1.toGregorianCalendar().getTimeInMillis();
		int diffSeconds = (int) (diffMs / 1000);
		return(diffSeconds);
	}
	
	public static void main(String[] args) throws RDFParseException, RepositoryException, IOException, UnfoundEventException, DatatypeConfigurationException, InvalidOntology{
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		RepositoryConnection con = rep.getConnection();
		InputStream in = Util.classLoader.getResourceAsStream(MainResources.timelinesFolder + "p1.ttl");
		con.add(in, EIG.NAMESPACE, Util.DefaultRDFformat);
		in.close();
		HashSet<Statement> statements2 = Inference.getSubClassOf(con);
		for (Statement stat : statements2){
			System.out.println(stat.toString());
		}
		
		statements2 = getNumbering(con);
		for (Statement stat : statements2){
			System.out.println(stat.toString());
		}
		
		statements2 = hasDuration(con);
		for (Statement stat : statements2){
			System.out.println(stat.toString());
		}
		
		statements2 = setEIGtype(con);
		for (Statement stat : statements2){
			System.out.println(stat.toString());
		}
		
	}
	
}


