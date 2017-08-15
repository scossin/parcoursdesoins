package servlet;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundTerminologyException;
import ontologie.EventOntology;
import ontologie.FINESS;

public class Hello extends HttpServlet {
	final static Logger logger = LoggerFactory.getLogger(Hello.class);

	@Override
	public void init() throws ServletException {
		logger.info("loading ...");
		try {
			EventOntology.isInstanceOfTerminology(FINESS.getClassNameIRI(), "3300002172");
		} catch (UnfoundTerminologyException e) {
			// TODO Auto-generated catch block
			logger.info("an error occured");
			e.printStackTrace();
		}
	}
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse response) throws ServletException, IOException {
		// Set response content type
	    response.setContentType("text/html");

	   boolean trouve = false;
	try {
		trouve = EventOntology.isInstanceOfTerminology(FINESS.getClassNameIRI(), "330000217");
	} catch (UnfoundTerminologyException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	    
	    PrintWriter out = response.getWriter();
	    String docType =
	       "<!doctype html public \"-//w3c//dtd html 4.0 " + "transitional//en\">\n";
	    out.println(docType +  "<body>");
	    out.println(trouve);
		out.println("</body></html>");
	}
	

}
