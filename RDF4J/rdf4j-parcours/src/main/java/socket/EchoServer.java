package socket;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
 
public class EchoServer {
	
	public void run() throws Exception{
	        ServerSocket serverSocket = null;

	        try {
	            serverSocket = new ServerSocket(4444);
	        } catch (IOException ex) {
	            System.out.println("Can't setup server on this port number. ");
	        }

	        Socket socket = null;
	        InputStream in = null;
	        OutputStream out = null;

	        try {
	            socket = serverSocket.accept();
	        } catch (IOException ex) {
	            System.out.println("Can't accept client connection. ");
	        }

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

	        int count;
	        while ((count = in.read(bytes)) > 0) {
	            out.write(bytes, 0, count);
	        }

	        out.close();
	        in.close();
	        socket.close();
	        serverSocket.close();
	    }
	
    public static void main(String[] args) throws Exception {
		EchoServer echoServer = new EchoServer();
		echoServer.run();
    }
}