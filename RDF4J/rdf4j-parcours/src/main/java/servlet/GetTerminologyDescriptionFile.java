package servlet;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import queryFiles.FileQuery;
import queryFiles.FilesAvailable;
import terminology.Terminology.TerminoEnum;

public class GetTerminologyDescriptionFile extends HttpServlet {

	public static boolean isKnownTerminologyName (String terminologyName){
		if (terminologyName == null){
			return(false);
		}
		ArrayList<String> availableTerminologyName = new ArrayList<String>();
		for (TerminoEnum termino : TerminoEnum.values()){
			availableTerminologyName.add(termino.getTerminologyName());
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
		String[] availableInformation = {"predicateDescription", "predicateFrequency","hierarchy"};
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
			fileQuery = FileQuery.getPredicateDescription(terminologyName);
		} else if (information.equals("predicateFrequency")){
			fileQuery = FileQuery.getPredicateFrequency(terminologyName);
		} else if (information.equals("hierarchy")){
			fileQuery = FileQuery.getHierarchy();
		}
		
		resp.setContentType(fileQuery.getMIMEtype());
		resp.setHeader("Content-Disposition","attachment;filename="+fileQuery.getFileName());
		OutputStream os = resp.getOutputStream();
		fileQuery.sendBytes(os);
		os.close();
	}
}
