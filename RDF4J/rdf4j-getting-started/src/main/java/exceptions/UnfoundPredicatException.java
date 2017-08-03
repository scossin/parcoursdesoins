package exceptions;

public class UnfoundPredicatException extends Exception  {
	public UnfoundPredicatException(String predicat){
		System.out.println("\"" + predicat + "\""+ " non trouvé dans la liste des prédicats");
	}
}
