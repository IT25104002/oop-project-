package com.fitness.controller;

import com.fitness.dao.MemberDAO;
import com.fitness.model.Member;
import com.fitness.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/admin/member/edit")
public class AdminEditMemberServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Member member = memberDAO.findById(request.getParameter("id"));
        if (member == null) {
            response.sendRedirect(request.getContextPath() + "/admin/members?error=Member not found");
            return;
        }
        request.setAttribute("member", member);
        request.getRequestDispatcher("/WEB-INF/views/admin-edit-member.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Member member = memberDAO.findById(request.getParameter("memberId"));
        if (member == null) {
            response.sendRedirect(request.getContextPath() + "/admin/members?error=Member not found");
            return;
        }

        member.setFullName(request.getParameter("fullName"));
        member.setPhone(request.getParameter("phone"));
        member.setGender(request.getParameter("gender"));
        member.setAddress(request.getParameter("address"));
        member.setHeight(ValidationUtil.parseDouble(request.getParameter("height"), 0));
        member.setWeight(ValidationUtil.parseDouble(request.getParameter("weight"), 0));
        member.setFitnessGoal(request.getParameter("fitnessGoal"));
        member.setEmergencyContact(request.getParameter("emergencyContact"));
        member.setMembershipPlan(request.getParameter("membershipPlan"));
        member.setPaymentStatus(request.getParameter("paymentStatus"));
        member.setStatus(request.getParameter("status"));

        try {
            if (!ValidationUtil.isBlank(request.getParameter("dob"))) {
                member.setDob(LocalDate.parse(request.getParameter("dob")));
            }
            if (!ValidationUtil.isBlank(request.getParameter("joinDate"))) {
                member.setJoinDate(LocalDate.parse(request.getParameter("joinDate")));
            }
            if (!ValidationUtil.isBlank(request.getParameter("expiryDate"))) {
                member.setExpiryDate(LocalDate.parse(request.getParameter("expiryDate")));
            }
        } catch (Exception e) {
            request.setAttribute("member", member);
            request.setAttribute("error", "Please check date fields.");
            request.getRequestDispatcher("/WEB-INF/views/admin-edit-member.jsp").forward(request, response);
            return;
        }

        memberDAO.update(member);
        response.sendRedirect(request.getContextPath() + "/admin/member/view?id=" + member.getMemberId() + "&success=Member updated successfully");
    }
}
