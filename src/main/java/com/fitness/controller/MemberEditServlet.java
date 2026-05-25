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

@WebServlet("/member/edit")
public class MemberEditServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("member", request.getSession().getAttribute("loggedUser"));
        request.getRequestDispatcher("/WEB-INF/views/member-edit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Member member = (Member) request.getSession().getAttribute("loggedUser");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String dobValue = request.getParameter("dob");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        String fitnessGoal = request.getParameter("fitnessGoal");
        String emergencyContact = request.getParameter("emergencyContact");
        double height = ValidationUtil.parseDouble(request.getParameter("height"), 0);
        double weight = ValidationUtil.parseDouble(request.getParameter("weight"), 0);

        if (ValidationUtil.isBlank(fullName) || ValidationUtil.isBlank(phone)) {
            request.setAttribute("error", "Name and phone number are required.");
            request.setAttribute("member", member);
            request.getRequestDispatcher("/WEB-INF/views/member-edit.jsp").forward(request, response);
            return;
        }

        if (!ValidationUtil.isValidPhone(phone)) {
            request.setAttribute("error", "Please enter a valid phone number.");
            request.setAttribute("member", member);
            request.getRequestDispatcher("/WEB-INF/views/member-edit.jsp").forward(request, response);
            return;
        }

        LocalDate dob = null;
        try {
            if (!ValidationUtil.isBlank(dobValue)) {
                dob = LocalDate.parse(dobValue);
                if (!ValidationUtil.isPastDate(dob)) {
                    request.setAttribute("error", "Date of birth must be a past date.");
                    request.setAttribute("member", member);
                    request.getRequestDispatcher("/WEB-INF/views/member-edit.jsp").forward(request, response);
                    return;
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Invalid date of birth.");
            request.setAttribute("member", member);
            request.getRequestDispatcher("/WEB-INF/views/member-edit.jsp").forward(request, response);
            return;
        }

        member.setFullName(fullName);
        member.setPhone(phone);
        member.setDob(dob);
        member.setGender(gender);
        member.setAddress(address);
        member.setHeight(height);
        member.setWeight(weight);
        member.setFitnessGoal(fitnessGoal);
        member.setEmergencyContact(emergencyContact);

        memberDAO.update(member);
        request.getSession().setAttribute("loggedUser", member);
        response.sendRedirect(request.getContextPath() + "/member/profile?success=Profile updated successfully");
    }
}
