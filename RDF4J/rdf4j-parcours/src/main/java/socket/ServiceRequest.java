package socket;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.util.Arrays;

public class ServiceRequest implements Runnable {

	private final String EOF = "ENDOFFILE";
    private Socket socket;

    public ServiceRequest(Socket connection) {
        this.socket = connection;
    }

    
    public static void printBytes(byte[] bytestest){
		for (int i = 0; i<bytestest.length;i++){
			System.out.print(bytestest[i]);
		}
    }
    
    public void run() {
        InputStream in = null;
        OutputStream out = null;
        OutputStream outClient = null;
        
        try {
            in = socket.getInputStream();
        } catch (IOException ex) {
            System.out.println("Can't get socket input stream. ");
        }

        try {
            out = new FileOutputStream("untest.xml");
        } catch (FileNotFoundException ex) {
            System.out.println("File not found. ");
        }

        byte[] bytes = new byte[8192];
        int eofLength = EOF.getBytes().length;
        int count;
        try {
			while ((count = in.read(bytes)) > 0) {
				System.out.println(count);
				if (count == (eofLength+1)){
					byte[] bytestest = Arrays.copyOfRange(bytes, 0, eofLength);
					if (Arrays.equals(bytestest, EOF.getBytes())){
						break;
					}
				}
			}
			System.out.println("Exiting loop");
		} catch (IOException e) {
			e.printStackTrace();
		}

        
        try {
			outClient = socket.getOutputStream();
	        String test = "Merci bien reçu !";
	        byte[] b =  test.getBytes();
	        outClient.write(b);
	        outClient.flush();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
        System.out.println("send to the client !");
        try {
			while ((count = in.read(bytes)) > 0) {
				System.out.println(count);
				if (count == (eofLength+1)){
					byte[] bytestest = Arrays.copyOfRange(bytes, 0, eofLength);
					if (Arrays.equals(bytestest, EOF.getBytes())){
						break;
					}
				}
			}
			System.out.println("Exiting loop");
		} catch (IOException e) {
			e.printStackTrace();
		}
        
        // closing 
        System.out.println("closing now");
        try {
			out.close();
			outClient.close();
			in.close();
			socket.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
        
    }        
}
