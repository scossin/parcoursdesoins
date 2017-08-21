package servlet;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import integration.DBconnection;
import parameters.Util;
import servlet.DockerDB.Endpoints;

public class CheckConnection extends HttpServlet {
	final static Logger logger = LoggerFactory.getLogger(CheckConnection.class);

	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String resultat="";
		DBconnection con = null;
		try {
			con = new DBconnection(DockerDB.getEndpointIPadress(Endpoints.TIMELINES));
			TupleQuery keywordQuery = con.getDBcon().prepareTupleQuery("SELECT * WHERE {?s ?p ?o} LIMIT 1");
			keywordQuery.evaluate();
			resultat = "Connection test successful";
			logger.info(resultat);
		} catch (Exception e){
			logger.error("Impossible to connect to DB");
			throw e;
		}  finally{
			con.close();
		}
		// Set response content type
		response.setContentType("text/html");

		PrintWriter out = response.getWriter();
		String title = "Try to connect to DB";
		String docType =
				"<!doctype html public \"-//w3c//dtd html 4.0 " + "transitional//en\">\n";
		out.println(docType + title + "<html> <body>" + resultat + "</body>         </html>")  ;
	}
}
