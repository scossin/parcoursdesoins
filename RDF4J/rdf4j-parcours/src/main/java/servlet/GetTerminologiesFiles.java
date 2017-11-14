package servlet;

import java.io.IOException;
import java.io.OutputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import queryFiles.GetTerminologies;

public class GetTerminologiesFiles extends HttpServlet {

	final static Logger logger = LoggerFactory.getLogger(GetTerminologiesFiles.class);
	
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		logger.info("Asking GetTerminologiesFiles");
		resp.setContentType("text/csv");
		resp.setHeader("Content-Disposition","attachment;filename=" + GetTerminologies.fileName);
		OutputStream os = resp.getOutputStream();
		new GetTerminologies().sendBytes(os);
		os.close();
}}
