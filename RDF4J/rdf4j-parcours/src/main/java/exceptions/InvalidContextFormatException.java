package exceptions;

public class InvalidContextFormatException extends InvalidContextException{

	public InvalidContextFormatException(String fileName){
		super(fileName);
		System.out.println("\"" + fileName + "\""+ " incorrect context file format");
	}
}
