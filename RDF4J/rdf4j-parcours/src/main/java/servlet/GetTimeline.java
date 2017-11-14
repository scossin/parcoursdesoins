package servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.InvalidContextException;
import exceptions.UnfoundResultVariable;
import exceptions.UnfoundTerminologyException;
import query.Query;
import query.Results;
import query.TimelineGetEvents;

public class GetTimeline extends HttpServlet {

	final static Logger logger = LoggerFactory.getLogger(GetTimeline.class);
	
	public static void sendResults(HttpServletResponse resp, Results results) throws IOException{
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
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		resp.setContentType("text/csv");
		resp.setHeader("Content-Disposition","attachment;filename="+"results.csv");
		String contextName = req.getParameter("contextName");
		
		Query query = null;
		try {
			query = new TimelineGetEvents(contextName);
		} catch (RDFParseException | RepositoryException | InvalidContextException | UnfoundTerminologyException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		String sparqlEndpoint = query.getEndpoint().getEndpointIPadress();
		Results results = new Results(sparqlEndpoint,query);
		sendResults(resp, results);
}
}
