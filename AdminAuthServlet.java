package com.fitnaze.demo;

import java.io.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class AdminAuthServlet {

    @PostMapping("/AdminAuthServlet")
    public void processAuthentication(HttpServletRequest request, HttpServletResponse response) throws IOException {
        
        String inputId = request.getParameter("id");
        String inputPass = request.getParameter("pass");
        String portalType = request.getParameter("portalType"); // "member" or "admin"

        HttpSession session = request.getSession();

        if (inputId != null && inputPass != null) {
            inputId = inputId.trim();
            inputPass = inputPass.trim();

            // 1. STAFF / ADMIN HARDCODED GATEWAY
            if ("admin".equalsIgnoreCase(portalType)) {
                boolean adminAuthenticated = "admin".equalsIgnoreCase(inputId) && ("admin123".equals(inputPass) || "elite123".equals(inputPass));

                String baseDir = request.getServletContext().getRealPath("/");
                File adminFile = new File(baseDir + File.separator + "webappdata" + File.separator + "admins.txt");
                if (!adminAuthenticated && adminFile.exists()) {
                    try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(adminFile), "UTF-8"))) {
                        String line;
                        while ((line = br.readLine()) != null) {
                            if (line.trim().isEmpty()) continue;
                            String[] parts = line.split(",", -1);
                            if (parts.length >= 5) {
                                String fileId = parts[0].trim();
                                String filePass = parts[1].trim();
                                String fileStatus = parts[4].trim();
                                if (fileId.equalsIgnoreCase(inputId) && filePass.equals(inputPass) && "ACTIVE".equalsIgnoreCase(fileStatus)) {
                                    adminAuthenticated = true;
                                    session.setAttribute("adminName", parts[2].trim());
                                    break;
                                }
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                if (adminAuthenticated) {
                    
                    session.setAttribute("role", "ADMIN");
                    session.setAttribute("adminSessionToken", "GRANTED");
                    if (session.getAttribute("adminName") == null) {
                        session.setAttribute("adminName", inputId);
                    }
                    
                    // Fallback routing matrix to handle any filename case styling automatically
                    if (new File(baseDir + File.separator + "Admindashboard.jsp").exists()) {
                        response.sendRedirect("Admindashboard.jsp");
                    } else if (new File(baseDir + File.separator + "admin-dashboard.jsp").exists()) {
                        response.sendRedirect("admin-dashboard.jsp");
                    } else if (new File(baseDir + File.separator + "AdminDashboard.jsp").exists()) {
                        response.sendRedirect("AdminDashboard.jsp");
                    } else {
                        response.sendRedirect("admindashboard.jsp"); // Last resort lowercase fallback
                    }
                    return;
                }
            } 
            // 2. ATHLETE / MEMBER TEXT FILE GATEWAY
            else {
                String baseDir = request.getServletContext().getRealPath("/");
                File memberFile = new File(baseDir + File.separator + "webappdata" + File.separator + "members.txt");

                if (memberFile.exists()) {
                    try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(memberFile), "UTF-8"))) {
                        String line;
                        while ((line = br.readLine()) != null) {
                            if (line.trim().isEmpty()) continue;
                            String[] parts = line.split(",");
                            
                            if (parts.length >= 3) {
                                String fileId = parts[0].trim();
                                String filePass = parts[1].trim();

                                if (fileId.equalsIgnoreCase(inputId) && filePass.equals(inputPass)) {
                                    
                                    String memberName = parts[2].trim();
                                    int age = 25; 
                                    if (parts.length > 3) {
                                        try { age = Integer.parseInt(parts[3].trim()); } catch(NumberFormatException e){}
                                    }
                                    
                                    String contact = (parts.length > 4) ? parts[4].trim() : "N/A";
                                    String statusTier = (parts.length > 5) ? parts[5].trim() : "STANDARD";

                                    // Instantiate Member object to hit criteria requirements
                                    Member activeMember = new Member(fileId, memberName, age, contact, statusTier, "2026-12-31");

                                    session.setAttribute("role", "MEMBER");
                                    session.setAttribute("memberId", activeMember.getMemberId());
                                    session.setAttribute("loggedInMemberName", activeMember.getName());
                                    session.setAttribute("memberPackage", activeMember.getMembershipType());

                                    response.sendRedirect("Dashboard.jsp");
                                    return;
                                }
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }

        // 3. REJECTION ALERT FALLBACK
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<script>alert('Access Denied: Invalid Security Credentials.'); window.location.href='login.jsp';</script>");
    }
}
