package com.fitness.controller;

import com.fitness.model.Member;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/member/profile")
public class MemberProfileServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Member loggedUser = (Member) request.getSession().getAttribute("loggedUser");
        request.setAttribute("member", loggedUser);
        request.getRequestDispatcher("/WEB-INF/views/member-profile.jsp").forward(request, response);
    }
}
