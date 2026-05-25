package com.fitness.controller;

import com.fitness.dao.MemberDAO;
import com.fitness.model.Member;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/admin/member/view")
public class AdminViewMemberServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        Member member = memberDAO.findById(id);
        if (member == null) {
            response.sendRedirect(request.getContextPath() + "/admin/members?error=Member not found");
            return;
        }
        request.setAttribute("member", member);
        request.getRequestDispatcher("/WEB-INF/views/admin-view-member.jsp").forward(request, response);
    }
}
