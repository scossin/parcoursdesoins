package servlet;

import java.io.*;
import java.util.List;
import java.util.concurrent.TimeUnit;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import integration.DBconnection;
import parameters.MainResources;
import parameters.Util;
import query.XMLFile;

// Extend HttpServlet class
public class HelloServlet extends HttpServlet {
 
	final static Logger logger = LoggerFactory.getLogger(Hello.class);
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException ,IOException {
		 
		/*
		try {
			TimeUnit.SECONDS.sleep(10);
		} catch (InterruptedException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		*/
		InputStream in = null ;
		
		
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
	    } catch (FileUploadException e) {
	        throw new ServletException("Cannot parse multipart request.", e);
	    }
		
		
		  //PrintWriter out = resp.getWriter();
		  
	      // Set response content type
		  //resp.setContentType("text/html");
	      //String docType = "<!doctype html public \"-//w3c//dtd html 4.0 " + "transitional//en\">\n";
	      //String title = "Using GET Method to Read Form Data";  
	      InputStream dtdFile = Util.classLoader.getResourceAsStream(MainResources.dtdFile);
	      resp.setContentType("text/xml");
	      resp.setHeader("Content-Disposition","attachment;filename="+"essai.xml");
	      
	      try {
	    	  resp.setBufferSize(1024);
	    	  logger.info("in2");
	    	  logger.info("nombre de bytes : " + in.available());
	    	InputStream in2 = Util.classLoader.getResourceAsStream(MainResources.dtdFile);
	    	logger.info("nombre de bytes in2 : " + in2.available());
			XMLFile xmlFile = new XMLFile(in,dtdFile);
			 logger.info(xmlFile.toString());
			//String resultat = xmlFile.getClass().toString();
			//IOUtils.copy(in, resp.getOutputStream());
			int BUFF_SIZE = 1024;
			byte[] buffer = new byte[BUFF_SIZE];
			OutputStream os = resp.getOutputStream();
		    int byteRead = 0;
		    while ((byteRead = in2.read(buffer)) != -1) {
		    	logger.info("bytes : " + byteRead);
		       os.write(buffer, 0, byteRead);
		    }
		    logger.info("transfert terminé");
		    os.flush();
		    os.close();
		    in.close();
		    in2.close();
			 //out.println(docType + "<body>" + resultat + "</body></html>");
		} catch (ParserConfigurationException | SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	     

	/*
	      DBconnection con = new DBconnection(Util.sparqlEndpoint);
			try {
				TupleQuery keywordQuery = con.getDBcon().prepareTupleQuery("SELECT * WHERE {?s ?p ?o} LIMIT 1");
				TupleQueryResult keywordQueryResult = keywordQuery.evaluate();
				if (!keywordQueryResult.hasNext()){
					System.out.println("Repository is empty");
				}
				while(keywordQueryResult.hasNext()){
					System.out.println("Printing only one statement...");
					BindingSet set = keywordQueryResult.next();
					resultat += set.toString();
					break;
				}
			} finally{
				con.close();
			}

	      */
	}
	
	public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
      
      // Set response content type
      response.setContentType("text/html");

      PrintWriter out = response.getWriter();
      String title = "Using GET Method to Read Form Data";
      String docType =
         "<!doctype html public \"-//w3c//dtd html 4.0 " + "transitional//en\">\n";
         
      out.println(docType +
         "<html>\n" +
            "<head><title>" + title + "</title></head>\n" +
            "<body bgcolor = \"#f0f0f0\">\n" +
               "<h1 align = \"center\">" + title + "</h1>\n" +
               "<ul>\n" +
                  "  <li><b>First Name</b>: "
                  + request.getParameter("first_name") + "\n" +
                  "  <li><b>Last Name</b>: "
                  + request.getParameter("last_name") + "\n" +
               "</ul>\n" +
            "</body>         </html>"
      );
   }
}
