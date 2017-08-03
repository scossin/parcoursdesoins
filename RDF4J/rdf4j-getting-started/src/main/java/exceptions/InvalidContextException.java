package exceptions;

import java.io.IOException;

public class InvalidContextException extends IOException{

	public InvalidContextException(String fileName){
		super(fileName);
		System.out.println("\"" + fileName + "\""+ " incorrect context file format");
	}
}
