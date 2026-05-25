package com.fitness.controller;

import com.fitness.dao.MemberDAO;
import com.fitness.model.Member;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/admin/member/delete")
public class AdminDeleteMemberServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String memberId = request.getParameter("id");
        HttpSession session = request.getSession(false);
        Member admin = session == null ? null : (Member) session.getAttribute("loggedUser");
        String actorId = admin == null ? "ADMIN" : admin.getMemberId();

        if (memberId == null || memberId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/members?error=Member ID is required");
            return;
        }

        try {
            boolean deleted = memberDAO.deleteMember(memberId, actorId);
            if (deleted) {
                response.sendRedirect(request.getContextPath() + "/admin/members?success=Member deleted successfully");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/members?error=Member not found");
            }
        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/admin/members?error=" + e.getMessage());
        } catch (RuntimeException e) {
            response.sendRedirect(request.getContextPath() + "/admin/members?error=Unable to delete member. Please try again.");
        }
    }
}
