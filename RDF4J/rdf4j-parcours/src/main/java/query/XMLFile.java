package query;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.eclipse.rdf4j.model.IRI;
import org.eclipse.rdf4j.query.impl.SimpleDataset;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.EntityResolver;
import org.xml.sax.ErrorHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import exceptions.InvalidContextException;
import exceptions.MyExceptions;
import exceptions.UnfoundDTDFile;
import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import parameters.MainResources;
import parameters.Util;
import terminology.Terminology;
import terminology.TerminologyInstances;

/**
 * This class handles a XML file containing the query. <br>
 * A XML file must be well formed and validated against a DTD file.
 * @author cossin
 *
 */
public class XMLFile {
	final static Logger logger = LoggerFactory.getLogger(XMLFile.class);
	
	/**
	 * An enumeration of VariableType in the XML file containing the query
	 * <ul>
	 * <li> numeric : is a numeric datatype
	 * <li> factor : is an instance of a terminology (ex : ICD-10 code)
	 * <li> date : is a date value datatype
	 * </ul>
	 * @author cossin
	 *
	 */
	public static enum XMLvariableType {
		numeric, factor, date;
	}
	
	
	/**
	 * An enumeration of XML elements in the XML file containing the query
	 * <ul>
	 * <li> event : describes one event we want
	 * <li> link : the link between 2 events
	 * <li> minValue : minimum value of a predicate (must be numeric or date)
	 * <li> maxValue : maximum value of a predicate (must be numeric or date)
	 * <li> value : one value of a factor type (instance of a terminology)
	 * <li> predicateType : a predicate name
	 * <li> eventType : an event type 
	 * <li> event1 : for link only, the number of the first event
	 * <li> event2 : for link only, the number of the second event
	 * <li> predicate1 : for link only, the predicate name of the first event
	 * <li> predicate1 : for link only, the predicate name of the second event
	 * <li> operator : for link only, the name of the operator to compare values
	 * <li> context : in which contexts to search
	 * <li> terminologyName : for describing instances of a terminology only 
	 * </ul> 
	 * @author cossin
	 *
	 */
	public static enum XMLelement {
		event, link, minValue, maxValue, value, predicateType, eventType, event1, event2, predicate1, predicate2, operator,
		context, terminologyName;
	}
	
	/**
	 * An enumeration of authorized operations to compare values 
	 * <ul>
	 * <li> diff : difference between values
	 * </ul>
	 * @author cossin
	 *
	 */
	public static enum XMLoperator{
		diff;
	}
	
	/**
	 * Check if operator is known
	 * @param operatorName the name of the operator in the XML file
	 * @return true if operatorName is known
	 */
	public static boolean isRecognizedOperator(String operatorName) {

	    for (XMLoperator o : XMLoperator.values()) {
	        if (o.name().equals(operatorName)) {
	            return true;
	        }
	    }
	    return false;
	}
	
	/**
	 * An enumeration of XML attributes in the XML file containing the query
	 * <ul>
	 * <li> number : the number of the event
	 * </ul>
	 * @author cossin
	 *
	 */
	public static enum XMLattributes{
		number
	}
	
	/**
	 * All events nodes in the XML file
	 */
	private NodeList eventNodes ;
	
	/**
	 * All links nodes in the XML file
	 */
	private NodeList linkNodes ;
	
	private SimpleDataset contextDataset = new SimpleDataset();
	
	/************************************************ Getter *************/
	
	public NodeList getEventNodes(){
		return(eventNodes);
	}
	
	public NodeList getLinkNodes(){
		return(linkNodes);
	}
	
	public DTDFiles getDTDFile(){
		return(DTDFile);
	}
	
	private DTDFiles DTDFile;
	
	/**
	 * Parse a new XML file containing a query. <br>
	 * Extract the event Nodes which describe the events wanted. <br>
	 * Extract the link nodes which describe the links between these events. <br>
	 * @param xmlFile A user query XML file well formed and validated against a DTD file
	 * @throws ParserConfigurationException If the XML file is bad formated 
	 * @throws SAXException If a the XML file is not validated
	 * @throws IOException If file not found
	 * @throws InvalidContextException 
	 */
	
	@Deprecated
	public XMLFile (File xmlFile) throws ParserConfigurationException, SAXException, IOException, InvalidContextException{
		DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
		domFactory.setValidating(true); // the xml file will be validated against a DTD (named in the file)
		DocumentBuilder builder = domFactory.newDocumentBuilder();
	    Document doc = builder.parse(xmlFile);
	    this.eventNodes = doc.getElementsByTagName(XMLelement.event.toString());
	    this.linkNodes = doc.getElementsByTagName(XMLelement.link.toString());
	    setContextDataSet(doc.getElementsByTagName(XMLelement.context.toString()));
	}
	
	@Deprecated
	public XMLFile (InputStream xmlFile, InputStream dtdFile) throws ParserConfigurationException, SAXException, IOException, InvalidContextException {
		DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
		domFactory.setValidating(true); // the xml file will be validated against a DTD (named in the file)
		DocumentBuilder builder = domFactory.newDocumentBuilder();
		builder.setEntityResolver(new EntityResolver() {
		    public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
		            return new InputSource(dtdFile);
		    }
		});
	    Document doc = builder.parse(xmlFile);
	    this.eventNodes = doc.getElementsByTagName(XMLelement.event.toString());
	    this.linkNodes = doc.getElementsByTagName(XMLelement.link.toString());
	    setContextDataSet(doc.getElementsByTagName(XMLelement.context.toString()));
	}
	
	private void setDTDFile(DTDFiles DTDFile){
		this.DTDFile = DTDFile;
	}
	
	public XMLFile (InputStream xmlFile) throws ParserConfigurationException, SAXException, IOException, InvalidContextException {
		DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
		domFactory.setValidating(true); // the xml file will be validated against a DTD (named in the file)
		DocumentBuilder builder = domFactory.newDocumentBuilder();
		builder.setEntityResolver(new EntityResolver() {
			private InputStream getInputDTD(String systemId) throws UnfoundDTDFile{
				for (DTDFiles DTDFile : DTDFiles.values()){
					File file = new File(DTDFile.getFilePath());
					if (systemId.endsWith(file.getName())){
						InputStream dtdInput = Util.classLoader.getResourceAsStream(DTDFile.getFilePath());
						setDTDFile(DTDFile);
						return(dtdInput);
					}
				}
				String dtdFileName = new File(systemId).getName();
				throw new UnfoundDTDFile(logger, dtdFileName);
			}
			
			
			public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
		    	 try {
					return new InputSource(getInputDTD(systemId));
				} catch (UnfoundDTDFile e) {
				}
		    	throw new IOException();
		    }
		});
		builder.setErrorHandler(new ErrorHandler() {
			
			public void warning(SAXParseException exception) throws SAXException {
				MyExceptions.logException(logger, exception);
				throw exception;
			}
			
			@Override
			public void fatalError(SAXParseException exception) throws SAXException {
				MyExceptions.logException(logger, exception);
				throw exception;
			}
			
			@Override
			public void error(SAXParseException exception) throws SAXException {
				MyExceptions.logException(logger, exception);
				throw exception;
			}
		});
	    Document doc = builder.parse(xmlFile);
	    this.eventNodes = doc.getElementsByTagName(XMLelement.event.toString());
	    this.linkNodes = doc.getElementsByTagName(XMLelement.link.toString());
	    setContextDataSet(doc.getElementsByTagName(XMLelement.context.toString()));
	}
	
	
	/*************************************** static methods **/
	
	/**
	 * Get the event number
	 * @param eventNode A XML element describing an event
	 * @return the event number
	 */
	public static int getEventNumber(Node eventNode){
		Element element = (Element) eventNode;
		String eventNumber = element.getAttribute(XMLattributes.number.toString());
        return(Integer.parseInt(eventNumber));
	}
	
	/**
	 * Get the event type 
	 * @param eventNode A XML element describing an event
	 * @return the event name (type)
	 */
	public static String getEventType(Node eventNode){
		Element element = (Element) eventNode;
        String eventType = element.getElementsByTagName(XMLelement.eventType.toString()).item(0).getTextContent();
        return(eventType);
	}

	/**
	 * Get all numerical predicates for this event
	 * @param eventNode A XML element describing an event
	 * @return A nodeList of numerical predicates
	 */
	public static NodeList getNumericPredicate (Node eventNode){
		Element element = (Element) eventNode;
		return(element.getElementsByTagName(XMLvariableType.numeric.toString()));
	}
	
	/**
	 * Get all factor predicates for this event
	 * @param eventNode A XML element describing an event
	 * @return nodeList of factor predicates
	 */
	public static NodeList getFactorPredicate (Node eventNode){
		Element element = (Element) eventNode;
		return(element.getElementsByTagName(XMLvariableType.factor.toString()));
	}
	
	/**
	 * Get all dates predicates for this event
	 * @param eventNode A XML element describing an event
	 * @return nodeList of dates predicates
	 */
	public static NodeList getDatePredicate (Node eventNode){
		Element element = (Element) eventNode;
		return(element.getElementsByTagName(XMLvariableType.date.toString()));
	}
	
	
	public static Terminology getTerminology(Node eventNode) throws UnfoundTerminologyException{
		Element element = (Element) eventNode;
		NodeList terminolyNameNodes = element.getElementsByTagName(XMLelement.terminologyName.toString());
		Node terminolyNameNode = terminolyNameNodes.item(0);
		String terminologyName = terminolyNameNode.getTextContent();
		Terminology terminology = TerminologyInstances.getTerminology(terminologyName);
		return(terminology);
	}
	
	public String getTerminologyNameFirstEventNode() throws UnfoundTerminologyException{
		Terminology terminology = getTerminology(eventNodes.item(0));
		return(terminology.getTerminologyName());
	}
	
	public static void main(String[] args) throws SAXException, IOException, ParserConfigurationException, InvalidContextException {

		InputStream xmlFile = Util.classLoader.getResourceAsStream(MainResources.queryFolder + "test.xml" );
		InputStream dtdFile = Util.classLoader.getResourceAsStream(MainResources.dtdSearchTimelines);
		
		XMLFile xml = new XMLFile(xmlFile, dtdFile);
		
		NodeList nList = xml.getEventNodes();
		
		Node eventNode = nList.item(0);
		
		System.out.println("Event Number : " + getEventNumber(eventNode));
		System.out.println("Event Type : " + getEventType(eventNode));
		System.out.println("Number of NumericPredicate : " + getNumericPredicate(eventNode).getLength());
		System.out.println("Number of FactorPredicate : " + getFactorPredicate(eventNode).getLength());
		System.out.println("Number of DatePredicate : " + getDatePredicate(eventNode).getLength());
		
		xmlFile.close();
		dtdFile.close();
	}
	
	
	private void setContextDataSet(NodeList contextNodes) throws InvalidContextException {
		logger.info("setting dataset...");
		SimpleDataset dataset = new SimpleDataset();
		if (contextNodes.getLength() == 0){
			logger.info("\t no node context");
			return;
		} 
		Node contextNode = contextNodes.item(0); // only 0-1 element (context?)
		NodeList contextValuesNode = ((Element) contextNode).getElementsByTagName(XMLelement.value.toString());
		if (contextValuesNode.getLength() == 0){
			logger.info("\t no node value in context node");
			return;
		}
		
		String contextValuesString = contextValuesNode.item(0).getTextContent();
		if (contextValuesString.equals("")){
			logger.info("\t value node of context node is empty"); // <value></value>
			return;
		}
		
		String contextValues[] = contextValuesString.split("\t");

		for (String contextName : contextValues){
			IRI contextIRI = EIG.getContextIRI(contextName);
			dataset.addNamedGraph(contextIRI);
		}
		logger.info("\t number of contexts in query : " + contextValues.length);
		this.contextDataset = dataset;
	}
	
	public SimpleDataset getContextDataSet() {
		return(contextDataset);
	}
	
}
