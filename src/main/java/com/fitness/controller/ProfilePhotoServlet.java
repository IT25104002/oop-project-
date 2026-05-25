package com.fitness.controller;

import com.fitness.dao.MemberDAO;
import com.fitness.model.Member;
import com.fitness.util.StorageConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

@WebServlet("/profile-photo")
public class ProfilePhotoServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String memberId = request.getParameter("memberId");
        Member member = memberDAO.findById(memberId);

        if (member == null || member.getProfilePicture() == null || member.getProfilePicture().isBlank()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Path imagePath = StorageConfig.getDataDirectory().resolve("uploads").resolve(member.getProfilePicture()).normalize();
        Path uploadDir = StorageConfig.getDataDirectory().resolve("uploads").normalize();
        if (!imagePath.startsWith(uploadDir) || !Files.exists(imagePath)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = Files.probeContentType(imagePath);
        response.setContentType(contentType == null ? "image/jpeg" : contentType);
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        Files.copy(imagePath, response.getOutputStream());
    }
}
