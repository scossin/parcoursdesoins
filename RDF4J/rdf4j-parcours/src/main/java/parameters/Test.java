package parameters;

import org.eclipse.rdf4j.model.Literal;
import org.eclipse.rdf4j.query.impl.SimpleDataset;

public class Test {
	
	private SimpleDataset dataset = new SimpleDataset();
	
	public SimpleDataset getDataSet(){
		return(dataset);
	}
	public static void main (String[] args){
		Literal literal = Util.vf.createLiteral("18-");
		System.out.println(literal.toString());
	}
}
