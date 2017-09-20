package servlet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundTerminologyException;
import ontologie.EIG;
import terminology.TerminologyInstances;

public class Initialize extends HttpServlet {
	final static Logger logger = LoggerFactory.getLogger(Initialize.class);

	@Override
	public void init() throws ServletException {
		logger.info("loading ...");
		try {
			TerminologyInstances.getTerminology(EIG.TerminologyName).getClassName();
		} catch (UnfoundTerminologyException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
