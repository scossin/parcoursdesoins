package servlet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import ontologie.EventOntology;

public class Initialize extends HttpServlet {
	final static Logger logger = LoggerFactory.getLogger(Initialize.class);

	@Override
	public void init() throws ServletException {
		logger.info("loading ...");
		EventOntology.isEvent("SejourMCO");
	}
}
