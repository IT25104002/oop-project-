package com.fitness.controller;

import com.fitness.model.Member;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(urlPatterns = {"/member/*", "/admin/*"})
public class AuthFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        Member user = session == null ? null : (Member) session.getAttribute("loggedUser");

        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/login?error=Please login first");
            return;
        }

        if (req.getRequestURI().contains("/admin/") && !user.isAdmin()) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
