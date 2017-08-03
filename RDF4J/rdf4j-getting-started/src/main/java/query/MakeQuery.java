package query;

import javax.xml.bind.annotation.XmlElementDecl.GLOBAL;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.ValueFactory;
import org.eclipse.rdf4j.model.impl.SimpleValueFactory;

import integration.DBconnection;
import integration.Util;

public class MakeQuery {
	private DBconnection con;
	
	public DBconnection getcon(){
		return(con);
	}
	
	private final String part1 = "SELECT ?patient ";
	
	// part2 : dynamique : liste des variables 
	private String part2 = "";
	
	private final String part3 = " WHERE {graph ?patient { ";
	
	// part 4 : dynamique : description des events
	private String part4 = "";
	
	
	private final String part5 = "}} ";
	
	private String part6 ="";
	
	public MakeQuery(String sparqlEndpoint){
		con = new DBconnection(sparqlEndpoint);
	}
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		MakeQuery makeQuery = new MakeQuery(Util.sparqlEndpoint);
		makeQuery.addEvent(0, "a", "SejourMCO");
		makeQuery.addEvent(1, "a", "SejourMCO");
		makeQuery.addEvent(2, "a", "Consultation");
		String sparqlQuery = makeQuery.getStringQuery();
		System.out.println(sparqlQuery);
	}
	
	
	public void addEvent (int numEvent, String p, String o){
		//
		String ajoutpart2 = "?event" + numEvent + " ";
		setPart2(ajoutpart2);
	}
	
	
	public String getStringQuery(){
		String stringQuery = part1 + part2 + part3 + part4 + part5;
		return(stringQuery);
	}
	
	private void setPart2 (String ajoutpart2 ){
		part2 = part2 + ajoutpart2 ;
	}
	private void setPart4 (String ajoutpart4 ){
		part4 = part4 + ajoutpart4 ;
	}

}
