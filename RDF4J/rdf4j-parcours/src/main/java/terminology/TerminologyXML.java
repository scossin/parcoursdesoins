package terminology;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.HashSet;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import exceptions.InvalidContextException;
import exceptions.UnfoundEventException;
import parameters.MainResources;
import parameters.Util;
import servlet.Endpoint;

public class TerminologyXML {


	final static Logger logger = LoggerFactory.getLogger(TerminologyXML.class);
	
	private NodeList terminologiesNodes ;
	
	private HashSet<Terminology> terminologies = new HashSet<Terminology>();
	
	public static enum terminologyVariable {
		terminology, terminologyName, namespace, prefix, className, ontologyFileName, dataFileName, endpoint;
	}
	
	public HashSet<Terminology> getTerminologies(){
		return(terminologies);
	}
	
	public TerminologyXML (File xmlFile, File dtdFile) throws ParserConfigurationException, SAXException, IOException, InvalidContextException, UnfoundEventException {
		DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
		domFactory.setValidating(true); // the xml file will be validated against a DTD (named in the file)
		DocumentBuilder builder = domFactory.newDocumentBuilder();
		builder.setEntityResolver(new EntityResolver() {
		    public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
		            return new InputSource(new FileInputStream(dtdFile));
		    }
		});
	    Document doc = builder.parse(xmlFile);
	    this.terminologiesNodes = doc.getElementsByTagName(terminologyVariable.terminology.toString());
	    setTerminologies();
	}
	
	private void addTerminology(Node terminologyNode) throws UnfoundEventException, IOException{
		Element terminologyEl = (Element) terminologyNode;
		String terminologyName = terminologyEl.getElementsByTagName(terminologyVariable.terminologyName.toString()).item(0).getTextContent();
		String namespace = terminologyEl.getElementsByTagName(terminologyVariable.namespace.toString()).item(0).getTextContent();
		String prefix = terminologyEl.getElementsByTagName(terminologyVariable.prefix.toString()).item(0).getTextContent();
		String className = terminologyEl.getElementsByTagName(terminologyVariable.className.toString()).item(0).getTextContent();
		String ontologyFileName = terminologyEl.getElementsByTagName(terminologyVariable.ontologyFileName.toString()).item(0).getTextContent();
		String dataFileName = terminologyEl.getElementsByTagName(terminologyVariable.dataFileName.toString()).item(0).getTextContent();
		String endpointName = terminologyEl.getElementsByTagName(terminologyVariable.endpoint.toString()).item(0).getTextContent();
		
		logger.info("adding new Terminology : " + terminologyName);
		
		terminologies.add(new Terminology(terminologyName, namespace, prefix, className, 
				ontologyFileName, dataFileName, new Endpoint(endpointName)));
	}
	
	private void setTerminologies() throws UnfoundEventException, IOException{
		for (int i = 0 ; i < terminologiesNodes.getLength() ; i++){
			Node terminologyNode = terminologiesNodes.item(i);
			addTerminology(terminologyNode);
		}
	}
	
	
	public static String getTerminologyFile(){
		return(MainResources.terminologiesFolder + MainResources.terminologyFileXMLname);
	}
	
}
