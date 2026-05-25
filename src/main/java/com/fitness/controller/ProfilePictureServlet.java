package com.fitness.controller;

import com.fitness.dao.MemberDAO;
import com.fitness.model.Member;
import com.fitness.util.StorageConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

@WebServlet("/member/upload-photo")
@MultipartConfig(maxFileSize = 1024 * 1024 * 3)
public class ProfilePictureServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Member member = (Member) request.getSession().getAttribute("loggedUser");
        Part filePart = request.getPart("profilePicture");

        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect(request.getContextPath() + "/member/profile?error=Please choose an image");
            return;
        }

        String contentType = filePart.getContentType();
        if (!("image/jpeg".equals(contentType) || "image/png".equals(contentType) || "image/jpg".equals(contentType))) {
            response.sendRedirect(request.getContextPath() + "/member/profile?error=Only JPG, JPEG, and PNG images are allowed");
            return;
        }

        Path uploadDir = StorageConfig.getDataDirectory().resolve("uploads");
        Files.createDirectories(uploadDir);

        String extension = contentType.equals("image/png") ? ".png" : ".jpg";
        String fileName = member.getMemberId() + "_profile" + extension;
        Path destination = uploadDir.resolve(fileName);
        Files.copy(filePart.getInputStream(), destination, StandardCopyOption.REPLACE_EXISTING);

        member.setProfilePicture(fileName);
        memberDAO.update(member);
        request.getSession().setAttribute("loggedUser", member);

        response.sendRedirect(request.getContextPath() + "/member/profile?success=Profile picture updated successfully");
    }
}
