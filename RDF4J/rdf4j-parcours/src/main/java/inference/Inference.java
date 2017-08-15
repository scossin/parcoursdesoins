package inference;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.TreeSet;

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

import exceptions.UnfoundEventException;
import ontologie.EIG;
import ontologie.Event;
import ontologie.EventOntology;
import ontologie.TIME;
import parameters.MainResources;
import parameters.Util;

public class Inference{
	
	
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
				+ "?event <" + TIME.HASBEGINNING.stringValue() + "> ?eventStart . "
				+ "?eventStart <" + TIME.INXSDDATETIME.stringValue() + "> ?date . }";
		
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
		
		// 
		int counter = 1;
		IRI hasNum = Util.vf.createIRI(EIG.NAMESPACE, "hasNum");
		for (XMLGregorianCalendar date : dates){
			Literal number = Util.vf.createLiteral(counter);
			ArrayList<Value> temp = linkDateIRI.get(date);
			for (Value valeur : temp){
				statements2.add(Util.vf.createStatement((Resource) valeur, hasNum, number));
			}
			counter ++ ;
		}
		return statements2;
	}
	
	public static void main(String[] args) throws RDFParseException, RepositoryException, IOException, UnfoundEventException{
		Repository rep = new SailRepository(new MemoryStore());
		rep.initialize();
		RepositoryConnection con = rep.getConnection();
		con.add(new File(MainResources.timelinesFolder + "p1.ttl"), null, Util.DefaultRDFformat);
		HashSet<Statement> statements2 = Inference.getSubClassOf(con);
		for (Statement stat : statements2){
			System.out.println(stat.toString());
		}
		
		
		statements2 = getNumbering(con);
		for (Statement stat : statements2){
			System.out.println(stat.toString());
		}
	}
	
}


