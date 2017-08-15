package parameters;

import java.util.concurrent.TimeUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundEventException;
import exceptions.UnfoundTerminologyException;
import ontologie.EventOntology;
import ontologie.FINESS;

public class TestSet {

	final static Logger logger = LoggerFactory.getLogger(TestSet.class);
	
	public static void main(String[] args) throws UnfoundTerminologyException, UnfoundEventException, InterruptedException {
		// TODO Auto-generated method stub

		System.out.println(EventOntology.isInstanceOfTerminology(FINESS.getClassNameIRI(), "330000217"));
		logger.info("test...");
		
		String msg = " non trouvé dans la liste des events";
		//logger.error(msg,new UnfoundEventException);
		throw new UnfoundEventException(logger, "mon event");
}}
