package com.stegano;

import javax.servlet.*;
import javax.servlet.http.*;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.List;

public class DecodeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            List<FileItem> items = upload.parseRequest(request);

            BufferedImage image = null;

            for (FileItem item : items) {
                if (!item.isFormField() && item.getFieldName().equals("image")) {
                    InputStream is = item.getInputStream();
                    image = ImageIO.read(is);
                }
            }

            if (image == null) {
                request.setAttribute("error", "Image upload failed!");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            String hiddenMessage = SteganographyUtil.decode(image);

            request.setAttribute("decodedMessage", hiddenMessage);
            request.setAttribute("success", "Message extracted successfully!");
            request.getRequestDispatcher("result.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }
}