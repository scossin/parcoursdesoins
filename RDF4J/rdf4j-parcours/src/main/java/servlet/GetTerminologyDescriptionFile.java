package servlet;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundFilterException;
import exceptions.UnfoundResultVariable;
import exceptions.UnfoundTerminologyException;
import queryFiles.FileQuery;
import queryFiles.FilesAvailable;
import queryFiles.GetTerminologies;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class GetTerminologyDescriptionFile extends HttpServlet {

	final static Logger logger = LoggerFactory.getLogger(GetTerminologyDescriptionFile.class);
	
	public static boolean isKnownTerminologyName (String terminologyName){
		if (terminologyName == null){
			return(false);
		}
		ArrayList<String> availableTerminologyName = new ArrayList<String>();
		for (Terminology terminology : TerminologyInstances.terminologies){
			availableTerminologyName.add(terminology.getTerminologyName());
		}
		
		for (String knownTerminologyName : availableTerminologyName){
			if (terminologyName.equals(knownTerminologyName)){
				return(true);
			}
		}
		return(false);
	}
	
	public static boolean isKnownInformation (String information){
		if (information == null){
			return(false);
		}
		String[] availableInformation = {"predicateDescription", "predicateFrequency","hierarchy","terminologies"};
		for (String knownInformation : availableInformation){
			if (information.equals(knownInformation)){
				return(true);
			}
		}
		return(false);
	}
	
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String terminologyName = req.getParameter("terminologyName");
		boolean isKnownTerminologyName = isKnownTerminologyName(terminologyName);
		String information = req.getParameter("information");
		boolean isKnownInformation = isKnownInformation(information);
		
		if (!isKnownTerminologyName || !isKnownInformation ){
			// Set response content type
			resp.setContentType("text/html");
			PrintWriter out = resp.getWriter();
			StringBuilder sb = new StringBuilder();
			for (FilesAvailable FileAvailable : FilesAvailable.values()){
				sb.append("<br>");
				sb.append(FileAvailable.getFileName());
				sb.append(":            ");
				sb.append(FileAvailable.getComment());
				sb.append("<br>");
			}
			String docType = "<!doctype html public \"-//w3c//dtd html 4.0 " + "transitional//en\">\n";
			out.println(docType + "<html> <body>" + "Sorry, invalid Get Request" + "</body> </html>")  ;
			// put a list of avaible file
			return;
		}
		FileQuery fileQuery = null;
		if (information.equals("predicateDescription")){
			try {
				fileQuery = FileQuery.getPredicateDescription(terminologyName);
			} catch (UnfoundTerminologyException | UnfoundFilterException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} else if (information.equals("predicateFrequency")){
			try {
				fileQuery = FileQuery.getPredicateFrequency(terminologyName);
			} catch (UnfoundResultVariable | RDFParseException | RepositoryException | UnfoundTerminologyException e) {
				e.printStackTrace();
			}
		} else if (information.equals("hierarchy")){
			try {
				fileQuery = FileQuery.getHierarchy(terminologyName);
			} catch (RDFParseException | RepositoryException | UnfoundTerminologyException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} else if (information.equals("terminologies")){
			logger.info("Asking terminologies description");
			fileQuery = new GetTerminologies();
		}
		
		resp.setContentType(fileQuery.getMIMEtype());
		resp.setHeader("Content-Disposition","attachment;filename="+fileQuery.getFileName());
		OutputStream os = resp.getOutputStream();
		fileQuery.sendBytes(os);
		os.close();
	}
}
