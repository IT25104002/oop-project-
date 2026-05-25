package com.fitness.controller;

import com.fitness.dao.MemberDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/admin/members")
public class AdminMembersServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String q = request.getParameter("q");
        request.setAttribute("members", memberDAO.search(q));
        request.setAttribute("q", q == null ? "" : q);
        request.getRequestDispatcher("/WEB-INF/views/admin-members.jsp").forward(request, response);
    }
}
