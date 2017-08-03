package query;

import java.io.File;
import java.io.IOException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;


public class XMLquery {
	
	public static enum VariableType {
		numeric, factor, date;
	}
	
	public static enum XMLelement {
		event, link, minValue, maxValue, value, predicateType, eventType, event1, event2, predicate1, predicate2;
	}
	
	private NodeList eventNodes ;
	
	private NodeList linkNodes ;
	
	public NodeList getEventNodes(){
		return(eventNodes);
	}
	
	public NodeList getLinkNodes(){
		return(linkNodes);
	}
	
	public XMLquery (File file) throws ParserConfigurationException, SAXException, IOException{
		// TODO Auto-generated method stub
		DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
		domFactory.setValidating(true);
		//domFactory.setNamespaceAware(true);
		DocumentBuilder builder = domFactory.newDocumentBuilder();
		builder.setErrorHandler(new ErrorHandler() {
		    @Override
		    public void error(SAXParseException exception) throws SAXException {
		        // do something more useful in each of these handlers
		        exception.printStackTrace();
		    }
		    @Override
		    public void fatalError(SAXParseException exception) throws SAXException {
		        exception.printStackTrace();
		    }

		    @Override
		    public void warning(SAXParseException exception) throws SAXException {
		        exception.printStackTrace();
		    }
		});
	    Document doc = builder.parse(file);
	    this.eventNodes = doc.getElementsByTagName(XMLelement.event.toString());
	    this.linkNodes = doc.getElementsByTagName(XMLelement.link.toString());
		
	}
	
	public static int getEventNumber(Node eventNode){
		Element element = (Element) eventNode;
		String eventNumber = element.getAttribute("number");
        return(Integer.parseInt(eventNumber));
	}
	
	public static String getEventType(Node eventNode){
		Element element = (Element) eventNode;
        String eventType = element.getElementsByTagName("eventType").item(0).getTextContent();
        return(eventType);
	}

	
	public static NodeList getNumericPredicate (Node eventNode){
		Element element = (Element) eventNode;
		return(element.getElementsByTagName("numeric"));
	}
	
	public static NodeList getFactorPredicate (Node eventNode){
		Element element = (Element) eventNode;
		return(element.getElementsByTagName("factor"));
	}
	
	public static NodeList getDatePredicate (Node eventNode){
		Element element = (Element) eventNode;
		return(element.getElementsByTagName("date"));
	}
	
	
	
	public static void main(String[] args) throws SAXException, IOException, ParserConfigurationException {

		/*
		recurse(doc.getChildNodes());*/
		XMLquery xml = new XMLquery(new File ("test.xml"));
		
		NodeList nList = xml.getEventNodes();
		
		Node eventNode = nList.item(0);
		
		System.out.println("Event Number : " + getEventNumber(eventNode));
		System.out.println("Event Type : " + getEventType(eventNode));
		System.out.println("Number of NumericPredicate : " + getNumericPredicate(eventNode).getLength());
		System.out.println("Number of FactorPredicate : " + getFactorPredicate(eventNode).getLength());
		System.out.println("Number of DatePredicate : " + getDatePredicate(eventNode).getLength());
		
	}
	
	
}
