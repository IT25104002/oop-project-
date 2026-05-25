package com.fitness.controller;

import com.fitness.dao.MemberDAO;
import com.fitness.model.Member;
import com.fitness.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/member/change-password")
public class ChangePasswordServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Member member = (Member) request.getSession().getAttribute("loggedUser");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New password and confirm password do not match.");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
            return;
        }

        if (!PasswordUtil.isStrongPassword(newPassword)) {
            request.setAttribute("error", "Password must have 8 characters, uppercase letter, number, and special character.");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
            return;
        }

        boolean changed = memberDAO.changePassword(member.getMemberId(), currentPassword, newPassword);
        if (!changed) {
            request.setAttribute("error", "Current password is incorrect.");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/member/profile?success=Password changed successfully");
    }
}
