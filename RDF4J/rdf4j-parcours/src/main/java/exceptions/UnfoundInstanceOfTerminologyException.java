package exceptions;

public class UnfoundInstanceOfTerminologyException extends UnfoundTerminologyException{
	public UnfoundInstanceOfTerminologyException(String instanceName, String terminologyName){
		super("\"" + instanceName + "\"" + " non trouvé dans la terminologie : \" " + terminologyName + "\"" );
}
}
