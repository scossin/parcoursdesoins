package servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.ParseException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import exceptions.IncomparableValueException;
import exceptions.InvalidContextException;
import exceptions.InvalidXMLFormat;
import exceptions.MyExceptions;
import exceptions.OperatorException;
import exceptions.UnfoundDTDFile;
import exceptions.UnfoundEventException;
import exceptions.UnfoundFilterException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundResultVariable;
import exceptions.UnfoundTerminologyException;
import query.DTDFiles;
import query.Query;
import query.Results;
import query.XMLCountQuery;
import query.XMLDescribeTerminologyQuery;
import query.XMLDescribeTimelinesQuery;
import query.XMLFile;
import query.XMLSearchQuery;
import query.XMLSearchQueryTimeLines;

// Extend HttpServlet class
public class HandleXMLQuery extends HttpServlet {
 
	final static Logger logger = LoggerFactory.getLogger(HandleXMLQuery.class);
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException ,IOException {

		resp.setContentType("text/csv");
		resp.setHeader("Content-Disposition","attachment;filename="+"results.csv");

		logger.info("New XMLquery received !");
		InputStream xmlFileIn = null ; // get InputStream of XMLFile
		try{
			List<FileItem> items = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(req);
			for (FileItem item : items) {
				xmlFileIn = item.getInputStream();
				logger.info("number of bytes : " + xmlFileIn.available());
			}
		} catch (FileUploadException e) {
			MyExceptions.logException(logger, e);
			throw new ServletException("Cannot parse multipart request.", e);
		}

		Query query = null;
		XMLFile xml = null;
		try {
			xml = new XMLFile(xmlFileIn);
		} catch (InvalidContextException | ParserConfigurationException | SAXException e1) {
			MyExceptions.logException(logger, e1);
			e1.printStackTrace();
		}
		
		try {
			if (xml.getDTDFile() == DTDFiles.SearchQueryTimelines){
				query = new XMLSearchQueryTimeLines(xml);
			} else if (xml.getDTDFile() == DTDFiles.SearchQueryTerminology){
				query = new XMLSearchQuery(xml);
			} else if (xml.getDTDFile() == DTDFiles.DescribeQuery) {
				query = new XMLDescribeTimelinesQuery(xml);
			} else if (xml.getDTDFile() == DTDFiles.CountQuery){
				query = new XMLCountQuery(xml);
			} else if (xml.getDTDFile() == DTDFiles.DescribeTerminologyQuery){
				query = new XMLDescribeTerminologyQuery(xml);
			} else {
				throw new UnfoundDTDFile(logger, xml.getDTDFile().getFilePath());
			}
			
		} catch (NumberFormatException | UnfoundEventException | UnfoundPredicatException
				| IncomparableValueException | UnfoundTerminologyException | OperatorException
				| InvalidContextException | InvalidXMLFormat | ParserConfigurationException | SAXException
				| ParseException | UnfoundDTDFile | RDFParseException | RepositoryException | UnfoundFilterException e1) {
			// TODO Auto-generated catch block
			MyExceptions.logException(logger, e1);
			e1.printStackTrace();
		} finally{
			xmlFileIn.close();
		}

		String sparqlEndpoint = query.getEndpoint().getEndpointIPadress();
		Results results = new Results(sparqlEndpoint,query);
		try {
			results.serializeResult();
		} catch (UnfoundResultVariable e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		File file = results.getFile();
		FileInputStream fis = null;

		try {
			logger.info("preparing to send file " + file.getAbsolutePath());
			fis = new FileInputStream(file);
		} catch (IOException e){
			e.printStackTrace();
		}

		OutputStream os = null;
		try {
			int BUFF_SIZE = 8*1024;
			byte[] buffer = new byte[BUFF_SIZE];
			os = resp.getOutputStream();
			int byteRead = 0;
			while ((byteRead = fis.read(buffer)) != -1) {
				os.write(buffer, 0, byteRead);
			}
			logger.info("\t file sent ");
		} finally{
			results.getCon().close();
			fis.close();
			os.close();
		}
	}
	
}

/* Over fields
try {
    List<FileItem> items = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(req);
    for (FileItem item : items) {
        if (item.isFormField()) {
            // Process regular form field (input type="text|radio|checkbox|etc", select, etc).
            String fieldname = item.getFieldName();
            String fieldvalue = item.getString();
            // ... (do your job here)
        } else {
            // Process form file field (input type="file").
            String fieldname = item.getFieldName();
            String filename = FilenameUtils.getName(item.getName());
            in = item.getInputStream();
            logger.info("nombre de bytes beginning : " + in.available());
            // ... (do your job here)
        }
    }
    */

/* test timeOut 
try {
	TimeUnit.SECONDS.sleep(10);
} catch (InterruptedException e1) {
	// TODO Auto-generated catch block
	e1.printStackTrace();
}
*/
