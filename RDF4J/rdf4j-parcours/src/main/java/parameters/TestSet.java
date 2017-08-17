package parameters;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import exceptions.UnfoundEventException;
import exceptions.UnfoundTerminologyException;

public class TestSet {

	final static Logger logger = LoggerFactory.getLogger(TestSet.class);
	
	public static void main(String[] args) throws UnfoundTerminologyException, UnfoundEventException, InterruptedException {
		// TODO Auto-generated method stub
		String fileName = MainResources.timelinesFolder;
		System.out.println(fileName);
		//Util.classLoader.getResourceAsStream(fileName);
		System.out.println(Util.classLoader.getResource(fileName).getPath());
		
		

}}
