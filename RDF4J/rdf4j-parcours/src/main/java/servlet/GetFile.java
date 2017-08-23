package servlet;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import parameters.MainResources;
import queryFiles.FileQuery;
import queryFiles.FilesAvailable;
import queryFiles.GetComments;
import queryFiles.GetEventPredicateFrequency;

public class GetFile extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String fileName = req.getParameter("fileName");
		if (fileName == null){
			// Set response content type
			resp.setContentType("text/html");
			PrintWriter out = resp.getWriter();
			StringBuilder sb = new StringBuilder();
			for (FilesAvailable FileAvailable : FilesAvailable.values()){
				sb.append("<br>");
				sb.append(FileAvailable.getFileName());
				sb.append(":            ");
				sb.append(FileAvailable.getComment());
				sb.append("<br>");
			}
			String docType = "<!doctype html public \"-//w3c//dtd html 4.0 " + "transitional//en\">\n";
			out.println(docType + "<html> <body>" + "?fileName=..." + 
					"\n" +
					sb.toString() +
					"</body> </html>")  ;
			// put a list of avaible file
		}
		
		if (FileQuery.isKnownFileName(fileName)){
			FileQuery fileQuery = FileQuery.getFileQuery(fileName);
			resp.setContentType(fileQuery.getMIMEtype());
			resp.setHeader("Content-Disposition","attachment;filename="+fileQuery.getFileName());
			OutputStream os = resp.getOutputStream();
			fileQuery.sendBytes(os);
			os.close();
		}
	}
}
