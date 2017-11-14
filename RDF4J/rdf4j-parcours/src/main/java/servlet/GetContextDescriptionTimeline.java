package servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.InvalidContextException;
import exceptions.UnfoundTerminologyException;
import query.Query;
import query.Results;
import query.TimelineDescribeContext;

public class GetContextDescriptionTimeline extends HttpServlet {

	final static Logger logger = LoggerFactory.getLogger(GetContextDescriptionTimeline.class);
	
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		resp.setContentType("text/csv");
		resp.setHeader("Content-Disposition","attachment;filename="+"results.csv");
		String contextName = req.getParameter("contextName");
		
		Query query = null;
		try {
			query = new TimelineDescribeContext(contextName);
		} catch (RDFParseException | RepositoryException | InvalidContextException | UnfoundTerminologyException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		String sparqlEndpoint = query.getEndpoint().getEndpointIPadress();
		Results results = new Results(sparqlEndpoint,query);
		GetTimeline.sendResults(resp, results);
}
}
