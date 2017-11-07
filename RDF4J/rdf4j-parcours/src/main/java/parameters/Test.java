package parameters;

import java.io.FileWriter;
import java.io.IOException;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class Test {
	
	public static void main (String[] args) throws IOException{
		JSONObject obj = new JSONObject();
		obj.put("Name", "crunchify.com");
		obj.put("Author", "App Shah");
		JSONObject obj2 = new JSONObject();
		JSONObject obj3 = new JSONObject();
		obj3.put("SejourHospit", "hospit");
		obj2.put("Event", "event1");
		obj2.put("event3", "event4");
		obj2.put("objet3", obj3);
		JSONArray arr = new JSONArray();
		arr.add("test");
		arr.add("test2");
		obj2.put("array",arr);
		obj.put("Company List", obj2 );
 
		// try-with-resources statement based on post comment below :)
		try (FileWriter file = new FileWriter("file1.txt")) {
			file.write(obj.toString());
			System.out.println("Successfully Copied JSON Object to File...");
			System.out.println("\nJSON Object: " + obj.toString());
		}
	}
}
