package com.stegano;
import javax.servlet.*;
import javax.servlet.http.*;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.Base64;
import java.util.List;

public class EncodeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            List<FileItem> items = upload.parseRequest(request);

            BufferedImage image = null;
            String message = "";

            for (FileItem item : items) {
                if (item.isFormField()) {
                    if (item.getFieldName().equals("message")) {
                        message = item.getString("UTF-8");
                    }
                } else {
                    if (item.getFieldName().equals("image")) {
                        InputStream is = item.getInputStream();
                        image = ImageIO.read(is);
                    }
                }
            }

            if (image == null) {
                request.setAttribute("error", "Image upload failed!");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            if (message.isEmpty()) {
                request.setAttribute("error", "Message cannot be empty!");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            BufferedImage encodedImage = SteganographyUtil.encode(image, message);
            byte[] imageBytes = SteganographyUtil.toBytes(encodedImage);
            String base64Image = Base64.getEncoder().encodeToString(imageBytes);

            request.setAttribute("encodedImage", base64Image);
            request.setAttribute("success", "Message hidden successfully!");
            request.getRequestDispatcher("result.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }
}