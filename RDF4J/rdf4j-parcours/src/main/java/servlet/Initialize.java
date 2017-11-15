package servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundFilterException;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class Initialize extends HttpServlet {
	final static Logger logger = LoggerFactory.getLogger(Initialize.class);

	@Override
	public void init() throws ServletException {
		logger.info("loading ...");
		try {
			for (Terminology terminology : TerminologyInstances.terminologies){
				terminology.checkInitialization();
			}
		} catch (RDFParseException | RepositoryException | UnfoundFilterException | IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
