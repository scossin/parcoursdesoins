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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import exceptions.IncomparableValueException;
import exceptions.MyExceptions;
import exceptions.OperatorException;
import exceptions.UnfoundEventException;
import exceptions.UnfoundPredicatException;
import exceptions.UnfoundTerminologyException;
import parameters.MainResources;
import parameters.Util;
import query.Query;
import query.Results;
import query.XMLFile;
import query.XMLSearchQuery;
import servlet.DockerDB.Endpoints;

// Extend HttpServlet class
public class HandleXMLQuery extends HttpServlet {
 
	final static Logger logger = LoggerFactory.getLogger(HandleXMLQuery.class);
	
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException ,IOException {


		resp.setContentType("text/csv");
		resp.setHeader("Content-Disposition","attachment;filename="+"results.csv");



		logger.info("New XMLquery received !");
		InputStream xmlFileIn = null ;

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

		InputStream dtdFileIn = Util.classLoader.getResourceAsStream(MainResources.dtdSearchFile);

		Query query = null;
		try {
			query = new XMLSearchQuery(new XMLFile(xmlFileIn, dtdFileIn));
		} catch (NumberFormatException | UnfoundEventException | ParserConfigurationException | SAXException
				| UnfoundPredicatException | ParseException | IncomparableValueException | UnfoundTerminologyException
				| OperatorException e) {
			MyExceptions.logException(logger, e);
			e.printStackTrace();
		} finally{
			xmlFileIn.close();
			dtdFileIn.close();
		}

		String sparqlEndpoint = DockerDB.getEndpointIPadress(Endpoints.TIMELINES);
		Results results = new Results(sparqlEndpoint,query);
		results.setUpFile();
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
