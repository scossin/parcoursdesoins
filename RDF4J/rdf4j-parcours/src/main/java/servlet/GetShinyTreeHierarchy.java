package servlet;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.MyExceptions;
import exceptions.UnfoundInstanceOfTerminologyException;
import exceptions.UnfoundTerminologyException;
import hierarchy.HandleHierarchy;
import parameters.Util;
import terminology.TerminologyInstances;

public class GetShinyTreeHierarchy extends HttpServlet {

	final static Logger logger = LoggerFactory.getLogger(GetShinyTreeHierarchy.class);
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException ,IOException {
		resp.setContentType("application/json");
		resp.setHeader("Content-Disposition","attachment;filename="+"results.csv");

		logger.info("New ShinyTreeHierarchy asked !");
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
		
		try {
			BufferedReader br = new BufferedReader(new InputStreamReader(xmlFileIn, Util.charset));
	        // first line from the text file
			String line = br.readLine();
			String separator = "\t";
			String[] columns = line.split(separator);
			String terminologyName = columns[0];
			HandleHierarchy handleHierarchy = new HandleHierarchy(TerminologyInstances.getTerminology(terminologyName));
			
			while ((line = br.readLine()) != null) {
				//System.out.println(line);
				columns = line.split(separator);
				String codeName = columns[1];
				int number = Integer.parseInt(columns[2]);
				handleHierarchy.setCodeNumber(codeName, number);
			}
			
			br.close();
			handleHierarchy.setAllCodesNumber();
			xmlFileIn.close();
			
			
			resp.setContentType(handleHierarchy.getMIMEtype());
			resp.setHeader("Content-Disposition","attachment;filename="+handleHierarchy.getFileName());
			OutputStream os = resp.getOutputStream();
			handleHierarchy.sendBytes(os);
			os.close();
			
		} catch (RDFParseException | RepositoryException | UnfoundTerminologyException | UnfoundInstanceOfTerminologyException e1) {
			MyExceptions.logException(logger, e1);
			e1.printStackTrace();
		}
	}
}
