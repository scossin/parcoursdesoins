package parameters;

/**
 * Files and Folder resources for this project
 * mainResources are located in src/main/resources/ (resources associated to the main source code in a Maven project)
 * @author cossin
 */
public class MainResources {
	
	public final static String directoryMainResources = "src/main/resources/";
	
	/**
	 * The path to the ontologie folder (relative to this project folder)
	 */
	public final static String ontologyFolder = "ontology/";
	
	
	/**
	 * The path to terminologies (relative to this project folder)
	 */
	public final static String terminologiesFolder = Project.projectFolder;
	
	public final static String terminologyFileXMLname = "terminologies.xml";
	public final static String terminologyFileDTDname = "terminologies.dtd";
	
	public final static String cacheFolder="cache/";

	/**
	 * The path to the timelines folder containing the events of each patient in a file
	 */
	
	public final static String timelinesFolder = "timelines/";
	
	
	/**
	 * The path to the query folder containing a list of queries
	 */
	
	public final static String queryFolder = "query/";
	
	/**
	 * The folder containing files to transform to RDF format 
	 */
	public final static String chargementFolder = "chargement/";
	
	/**
	 * The name of the main ontology (relative to this project folder)
	 */
	public final static String ontologyFileName = ontologyFolder + "time.ttl";
	
	/**
	 * The name of the FINESS terminology file (relative to this project folder)
	 */
	public final static String finessTerminology = terminologiesFolder + "codesFINESS.ttl";
	
	/**
	 * The name of the DTD file of a user XML query
	 */
	public final static String dtdSearchTerminology = queryFolder + "searchTerminology.dtd";
	
	public final static String dtdSearchTimelines = queryFolder + "searchTimelines.dtd";
	
	public final static String dtdDescribeFile = queryFolder + "describe.dtd";
	
	public final static String dtdCountFile = queryFolder + "count.dtd";

	public final static String dtdDescribeTerminologyFile = queryFolder + "describeTerminology.dtd";
}
