package parameters;

import org.eclipse.rdf4j.query.impl.SimpleDataset;

public class Test {
	
	private SimpleDataset dataset = new SimpleDataset();
	
	public SimpleDataset getDataSet(){
		return(dataset);
	}
	public static void main (String[] args){
		Test test = new Test();
		
		if (test.getDataSet() == null){
			System.out.println("c'est nulle");
		}
		System.out.println(test.getDataSet().getNamedGraphs().hashCode());
	}
}
