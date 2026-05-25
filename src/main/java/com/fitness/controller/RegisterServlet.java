package com.fitness.controller;

import com.fitness.dao.MemberDAO;
import com.fitness.model.Member;
import com.fitness.util.PasswordUtil;
import com.fitness.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private final MemberDAO memberDAO = new MemberDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String fullName = clean(request.getParameter("fullName"));
        String email = clean(request.getParameter("email"));
        String phone = clean(request.getParameter("phone"));
        String dobValue = clean(request.getParameter("dob"));
        String gender = clean(request.getParameter("gender"));
        String address = clean(request.getParameter("address"));
        String heightValue = clean(request.getParameter("height"));
        String weightValue = clean(request.getParameter("weight"));
        String fitnessGoal = clean(request.getParameter("fitnessGoal"));
        String emergencyContact = clean(request.getParameter("emergencyContact"));
        String membershipPlan = clean(request.getParameter("membershipPlan"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
        request.setAttribute("dob", dobValue);
        request.setAttribute("gender", gender);
        request.setAttribute("address", address);
        request.setAttribute("height", heightValue);
        request.setAttribute("weight", weightValue);
        request.setAttribute("fitnessGoal", fitnessGoal);
        request.setAttribute("emergencyContact", emergencyContact);
        request.setAttribute("membershipPlan", membershipPlan);

        if (ValidationUtil.isBlank(fullName) || ValidationUtil.isBlank(email) || ValidationUtil.isBlank(phone)
                || ValidationUtil.isBlank(password) || ValidationUtil.isBlank(confirmPassword)) {
            showError(request, response, "Please fill all required fields.");
            return;
        }

        if (!ValidationUtil.isValidEmail(email)) {
            showError(request, response, "Please enter a valid email address.");
            return;
        }

        if (memberDAO.emailExists(email)) {
            showError(request, response, "This email is already registered. Please login or use another email.");
            return;
        }

        if (!ValidationUtil.isValidPhone(phone)) {
            showError(request, response, "Please enter a valid phone number.");
            return;
        }

        LocalDate dob = null;
        if (!ValidationUtil.isBlank(dobValue)) {
            try {
                dob = LocalDate.parse(dobValue);
                if (!ValidationUtil.isPastDate(dob)) {
                    showError(request, response, "Date of birth must be a past date.");
                    return;
                }
            } catch (Exception e) {
                showError(request, response, "Please enter a valid date of birth.");
                return;
            }
        }

        if (!password.equals(confirmPassword)) {
            showError(request, response, "Password and confirm password do not match.");
            return;
        }

        if (!PasswordUtil.isStrongPassword(password)) {
            showError(request, response, "Password must be at least 8 characters and include uppercase, number, and special character.");
            return;
        }

        double height = ValidationUtil.parseDouble(heightValue, 0);
        double weight = ValidationUtil.parseDouble(weightValue, 0);

        if (ValidationUtil.isBlank(gender)) gender = "Not specified";
        if (ValidationUtil.isBlank(address)) address = "Not specified";
        if (ValidationUtil.isBlank(fitnessGoal)) fitnessGoal = "General Fitness";
        if (ValidationUtil.isBlank(emergencyContact)) emergencyContact = phone;
        if (ValidationUtil.isBlank(membershipPlan)) membershipPlan = "Premium Monthly";

        Member newMember = new Member(
                null,
                fullName,
                email,
                password,
                "MEMBER",
                phone,
                dob,
                gender,
                address,
                null,
                height,
                weight,
                fitnessGoal,
                emergencyContact,
                membershipPlan,
                LocalDate.now(),
                calculateExpiryDate(membershipPlan),
                "Pending",
                "Active"
        );

        Member savedMember = memberDAO.register(newMember);
        response.sendRedirect(request.getContextPath() + "/login?success=Registration successful. Your Member ID is "
                + savedMember.getMemberId() + ". Please login.");
    }

    private LocalDate calculateExpiryDate(String membershipPlan) {
        if (membershipPlan == null) return LocalDate.now().plusMonths(1);
        String plan = membershipPlan.toLowerCase();
        if (plan.contains("year")) return LocalDate.now().plusYears(1);
        if (plan.contains("quarter")) return LocalDate.now().plusMonths(3);
        return LocalDate.now().plusMonths(1);
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }
}
