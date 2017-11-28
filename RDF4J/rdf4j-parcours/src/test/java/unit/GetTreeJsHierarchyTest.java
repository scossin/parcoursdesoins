package unit;

import static org.junit.Assert.assertTrue;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.apache.commons.io.FileUtils;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.junit.Test;

import exceptions.UnfoundFilterException;
import exceptions.UnfoundInstanceOfTerminologyException;
import exceptions.UnfoundTerminologyException;
import hierarchy.GetTreeJsHierarchy;
import parameters.Util;
import terminology.Terminology;
import terminology.TerminologyInstances;

public class GetTreeJsHierarchyTest {

	@Test
	public void testNumber() throws IOException, UnfoundTerminologyException, RDFParseException, RepositoryException, UnfoundFilterException, UnfoundInstanceOfTerminologyException{
		String fileName = "TreeJs/instancesNumberCIM10.csv";
		Path filePath = Paths.get(Util.classLoader.getResource(fileName).getPath());
		BufferedReader br = Files.newBufferedReader(filePath,Util.charset);

	    // first line from the text file
		String line = br.readLine();
		String separator = "\t";
		String[] columns = line.split(separator);
		String terminologyName = columns[0];
		
		Terminology terminology = TerminologyInstances.getTerminology(terminologyName);
		GetTreeJsHierarchy getTreeJsHierarchy = new GetTreeJsHierarchy(terminology);
		
		while ((line = br.readLine()) != null) {
			columns = line.split(separator);
			String codeName = columns[1];
			int number = Integer.parseInt(columns[2]);
			getTreeJsHierarchy.setCodeNumber(codeName, number);
		}
		
		br.close();
		getTreeJsHierarchy.setAllCodesNumber();
		
		String outputFileName = "TreeJs";
		File file = new File(Util.classLoader.getResource(outputFileName).getFile() + "/outputFile.json");
		OutputStream os = new FileOutputStream(file);
		getTreeJsHierarchy.sendBytes(os);
		os.close();
		
		File file1 = new File(Util.classLoader.getResource(outputFileName).getFile() + "/expectedFile.json");
		boolean isTwoEqual = FileUtils.contentEquals(file1, file);
		assertTrue(isTwoEqual);
	}
}
