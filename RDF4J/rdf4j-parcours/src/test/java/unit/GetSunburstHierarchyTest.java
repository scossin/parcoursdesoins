package unit;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.junit.Test;

import exceptions.UnfoundFilterException;
import exceptions.UnfoundTerminologyException;
import hierarchy.GetSunburstHierarchyLabel;
import parameters.Util;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class GetSunburstHierarchyTest {

	
	@Test
	public void SendSunburstHierarchyTest() throws UnfoundTerminologyException, RDFParseException, RepositoryException, UnfoundFilterException, IOException{
		Terminology terminology = TerminologyInstances.getTerminology("Event");
		terminology.checkInitialization();
		GetSunburstHierarchyLabel sunburstHierachy = new GetSunburstHierarchyLabel(terminology);
		//sunburstHierachy.setHierarchyLabel();
		//sunburstHierachy.printTree();
		String outputFileName = "TreeJs";
		File file = new File(Util.classLoader.getResource(outputFileName).getFile() + "sunburstHierarchy.csv");
		OutputStream os = new FileOutputStream(file);
		sunburstHierachy.sendBytes(os);
		os.close();
	}
}
