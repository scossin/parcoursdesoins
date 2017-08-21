package query;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.model.Value;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import ontologie.EIG;
import ontologie.Event;
import ontologie.EventOntology;
import parameters.Util;
import query.XMLFile.XMLelement;

public class XMLDescribeQuery implements Query {

	private Event event ;
	private XMLFile xml ;
	private HashMap<IRI,Value> predicatesValue = new HashMap<IRI,Value>();
	private SimpleDataset contextDataset;
	IRI[] eventsIRI ;
	String eventValues;
	String predicatesValues;
	
	public XMLDescribeQuery (XMLFile xml) throws ParserConfigurationException, SAXException, IOException, UnfoundEventException, UnfoundPredicatException{
		this.xml = xml;
		Node eventNode = xml.getEventNodes().item(0);
		this.event = EventOntology.getEvent(XMLFile.getEventType(eventNode));
		setPredicates(eventNode);
		setEventIRI(eventNode);
		setEventValues();
		setPredicatesValues();
		// context
		this.contextDataset = xml.getContextDataSet();
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
	
	private void setPredicatesValues() throws UnfoundEventException{
		Set<IRI> predicatesIRI = predicatesValue.keySet();
		StringBuilder sb = new StringBuilder();
		sb.append("VALUES ?predicate { ");
		for (IRI predicateIRI : predicatesIRI){
			sb.append(Query.formatIRI4query(predicateIRI));
		}
		sb.append("} .\n");
		this.predicatesValues = sb.toString();
	}
	
	private void setEventValues(){
		StringBuilder sb = new StringBuilder();
		sb.append("VALUES ?event { ");
		for (IRI eventIRI : eventsIRI){
			sb.append(Query.formatIRI4query(eventIRI));
		}
		sb.append("} . \n");
		this.eventValues = sb.toString();
	}
	
	private void setPredicates (Node eventNode) throws UnfoundPredicatException{
		Element element = (Element) eventNode;
		NodeList predicates = element.getElementsByTagName(XMLelement.predicateType.toString());
		Node predicate = predicates.item(0);
		String predicateNames[] = predicate.getTextContent().split("\t");
		for (String predicateName : predicateNames){
			predicatesValue.putAll(EventOntology.getOnePredicateValuePair(predicateName, event));
		}
	}
	
	
	private void setEventIRI (Node eventNode) throws UnfoundPredicatException{
		Element element = (Element) eventNode;
		NodeList predicates = element.getElementsByTagName(XMLelement.value.toString());
		Node predicate = predicates.item(0);
		String predicateNames[] = predicate.getTextContent().split("\t");
		eventsIRI = new IRI[predicateNames.length];
		for (int i = 0; i<predicateNames.length; i++){
			eventsIRI[i] = Util.vf.createIRI(EIG.NAMESPACE, predicateNames[i]);
		}
	}

	public SimpleDataset getContextDataset() {
		// TODO Auto-generated method stub
		return contextDataset;
	}

	public String[] getVariableNames() {
		// TODO Auto-generated method stub
		String[] variablesNames = {"context","event","predicate","value"};
		return(variablesNames);
	}
}
