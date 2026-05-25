package com.fitnaze.demo;

import java.io.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;

/**
 * Controller handling authentication requests for both Administrators and Members.
 * Reads user data from local text files acting as flat-file databases.
 */
@Controller
public class AdminAuthServlet {

    /**
     * Processes POST requests sent to the "/AdminAuthServlet" endpoint.
     * Extracts credentials, validates them against administrative rules or flat files, 
     * manages user sessions, and routes the user to the appropriate dashboard.
     */
    @PostMapping("/AdminAuthServlet")
    public void processAuthentication(HttpServletRequest request, HttpServletResponse response) throws IOException {
        
        // Extract login credentials and portal type from the HTTP request parameters
        String inputId = request.getParameter("id");
        String inputPass = request.getParameter("pass");
        String portalType = request.getParameter("portalType"); // Expected values: "member" or "admin"

        // Initialize or retrieve the existing user session
        HttpSession session = request.getSession();

        // Check that parameters are not null before performing any operations
        if (inputId != null && inputPass != null) {
            // Trim whitespace to handle accidental spaces typed by the user
            inputId = inputId.trim();
            inputPass = inputPass.trim();

            // =========================================================================
            // 1. STAFF / ADMIN HARDCODED GATEWAY
            // =========================================================================
            if ("admin".equalsIgnoreCase(portalType)) {
                
                // Check against hardcoded supreme admin credentials first
                boolean adminAuthenticated = "admin".equalsIgnoreCase(inputId) && 
                                             ("admin123".equals(inputPass) || "elite123".equals(inputPass));

                // Locate the 'admins.txt' flat file in the deployed webapp directory
                String baseDir = request.getServletContext().getRealPath("/");
                File adminFile = new File(baseDir + File.separator + "webappdata" + File.separator + "admins.txt");
                
                // If not hardcoded-authenticated, look for the user in the admins.txt file
                if (!adminAuthenticated && adminFile.exists()) {
                    try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(adminFile), "UTF-8"))) {
                        String line;
                        // Read the file line by line
                        while ((line = br.readLine()) != null) {
                            if (line.trim().isEmpty()) continue; // Skip blank lines
                            
                            // Split line by comma (CSV format); -1 preserves trailing empty strings
                            String[] parts = line.split(",", -1);
                            
                            // Check that the line contains enough data elements (ID, Pass, Name, etc., Status)
                            if (parts.length >= 5) {
                                String fileId = parts[0].trim();
                                String filePass = parts[1].trim();
                                String fileStatus = parts[4].trim();
                                
                                // Validate ID (case-insensitive), Password (case-sensitive), and status matching "ACTIVE"
                                if (fileId.equalsIgnoreCase(inputId) && filePass.equals(inputPass) && "ACTIVE".equalsIgnoreCase(fileStatus)) {
                                    adminAuthenticated = true;
                                    // Cache the admin's actual name from the file into the session
                                    session.setAttribute("adminName", parts[2].trim());
                                    break; // Match found, break loop
                                }
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace(); // Log file reading errors
                    }
                }

                // Handle successful Admin authentication lifecycle
                if (adminAuthenticated) {
                    // Set authorization session tokens
                    session.setAttribute("role", "ADMIN");
                    session.setAttribute("adminSessionToken", "GRANTED");
                    
                    // Fallback to use username if no display name was derived from the file lookup
                    if (session.getAttribute("adminName") == null) {
                        session.setAttribute("adminName", inputId);
                    }
                    
                    // --- Fallback Routing Matrix ---
                    // Scans the web app space to redirect to the dashboard page, 
                    // dynamically handling varying filename case styles to prevent 404s.
                    if (new File(baseDir + File.separator + "Admindashboard.jsp").exists()) {
                        response.sendRedirect("Admindashboard.jsp");
                    } else if (new File(baseDir + File.separator + "admin-dashboard.jsp").exists()) {
                        response.sendRedirect("admin-dashboard.jsp");
                    } else if (new File(baseDir + File.separator + "AdminDashboard.jsp").exists()) {
                        response.sendRedirect("AdminDashboard.jsp");
                    } else {
                        response.sendRedirect("admindashboard.jsp"); // Last resort lowercase fallback
                    }
                    return; // Terminate execution after successful redirect
                }
            } 
            // =========================================================================
            // 2. ATHLETE / MEMBER TEXT FILE GATEWAY
            // =========================================================================
            else {
                // Locate the 'members.txt' flat file in the web app infrastructure
                String baseDir = request.getServletContext().getRealPath("/");
                File memberFile = new File(baseDir + File.separator + "webappdata" + File.separator + "members.txt");

                if (memberFile.exists()) {
                    try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(memberFile), "UTF-8"))) {
                        String line;
                        // Iterate through the database flat-file
                        while ((line = br.readLine()) != null) {
                            if (line.trim().isEmpty()) continue; // Skip blank rows
                            
                            String[] parts = line.split(",");
                            
                            // Confirm at minimum indices 0, 1, and 2 exist (ID, Password, Name)
                            if (parts.length >= 3) {
                                String fileId = parts[0].trim();
                                String filePass = parts[1].trim();

                                // Credentials matching validation check
                                if (fileId.equalsIgnoreCase(inputId) && filePass.equals(inputPass)) {
                                    
                                    String memberName = parts[2].trim();
                                    
                                    // Parse user age, defaulting to 25 if data is missing or corrupted
                                    int age = 25; 
                                    if (parts.length > 3) {
                                        try { 
                                            age = Integer.parseInt(parts[3].trim()); 
                                        } catch(NumberFormatException e){
                                            // Silently catch badly formatted age strings and preserve default
                                        }
                                    }
                                    
                                    // Extract optional contact details and tier fields with defaults
                                    String contact = (parts.length > 4) ? parts[4].trim() : "N/A";
                                    String statusTier = (parts.length > 5) ? parts[5].trim() : "STANDARD";

                                    // Map parsed file records onto a domain Member model object
                                    Member activeMember = new Member(fileId, memberName, age, contact, statusTier, "2026-12-31");

                                    // Bind user authorization values and member details to the active HTTP Session
                                    session.setAttribute("role", "MEMBER");
                                    session.setAttribute("memberId", activeMember.getMemberId());
                                    session.setAttribute("loggedInMemberName", activeMember.getName());
                                    session.setAttribute("memberPackage", activeMember.getMembershipType());

                                    // Redirect successfully logged-in member to the generic dashboard
                                    response.sendRedirect("Dashboard.jsp");
                                    return; // Terminate function processing
                                }
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace(); // Log file reading errors
                    }
                }
            }
        }

        // =========================================================================
        // 3. REJECTION ALERT FALLBACK
        // =========================================================================
        // Executes only if credentials didn't match or parameters weren't valid
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        // Emit a Javascript alert directly to the client browser detailing failures, then kickback to login.jsp
        out.println("<script>alert('Access Denied: Invalid Security Credentials.'); window.location.href='login.jsp';</script>");
    }
}
