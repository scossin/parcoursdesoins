package exceptions;

public class UnfoundEventException extends Exception {
	
	public UnfoundEventException(String event){
		System.out.println("\"" + event + "\""+ " non trouvé dans la liste des events");
	}

}
