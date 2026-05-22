<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // Security Access Guard: Lock down the log viewer to authenticated sessions
    String currentSessionUser = (String) session.getAttribute("memberId");
    if (currentSessionUser == null || currentSessionUser.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }
    currentSessionUser = currentSessionUser.trim();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FitNase | Transaction History</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&family=Oswald:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --brand-orange: #ff5722;
            --brand-glow: rgba(255, 87, 34, 0.35);
            --dark-bg: #0f0f0f;
            --card-bg: rgba(20, 20, 20, 0.9);
            --text-gray: #bbbbbb;
        }

        body { 
            background: linear-gradient(rgba(10, 10, 10, 0.95), rgba(10, 10, 10, 0.95)), 
                        url('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=2070&auto=format&fit=crop'); 
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            color: white; 
            font-family: 'Poppins', sans-serif; 
            margin: 0;
            padding: 60px 20px; 
            min-height: 100vh;
            box-sizing: border-box;
        }

        h2 { 
            font-family: 'Oswald', sans-serif;
            color: white; 
            letter-spacing: 4px; 
            text-align: center; 
            text-transform: uppercase; 
            font-size: 2.5rem;
            margin-top: 0;
            margin-bottom: 40px;
        }

        h2 span { color: var(--brand-orange); }

        .history-container {
            background: var(--card-bg);
            backdrop-filter: blur(10px);
            padding: 40px;
            border-radius: 4px;
            border: 1px solid rgba(255, 87, 34, 0.15);
            box-shadow: 0 25px 60px rgba(0,0,0,0.8);
            max-width: 1100px;
            margin: 0 auto;
            box-sizing: border-box;
        }

        table { 
            width: 100%; 
            border-collapse: collapse; 
        }

        th { 
            text-align: left; 
            color: var(--brand-orange); 
            padding: 20px 15px; 
            font-family: 'Oswald', sans-serif;
            font-size: 0.95rem; 
            letter-spacing: 2px;
            text-transform: uppercase;
            border-bottom: 2px solid #333;
        }

        td { 
            padding: 20px 15px; 
            border-bottom: 1px solid #222; 
            font-size: 0.95rem; 
            color: #ddd;
        }

        tr:hover td { 
            background: rgba(255, 255, 255, 0.02); 
            color: white;
            transition: 0.2s ease;
        }

        .status-badge {
            padding: 6px 14px;
            border-radius: 2px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .status-verified { background: rgba(76, 175, 80, 0.12); color: #81c784; border: 1px solid rgba(129, 199, 132, 0.25); }
        .status-pending { background: rgba(255, 193, 7, 0.12); color: #ffd54f; border: 1px solid rgba(255, 213, 79, 0.25); }
        .status-cancelled { background: rgba(244, 67, 54, 0.12); color: #e57373; border: 1px solid rgba(229, 115, 115, 0.25); }

        .plan-name {
            font-weight: 600;
            color: white;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-cancel { 
            background: transparent;
            border: 1px solid #444;
            color: #888; 
            padding: 8px 18px;
            border-radius: 2px;
            text-decoration: none; 
            font-size: 11px; 
            font-weight: 600; 
            font-family: 'Oswald', sans-serif;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            transition: 0.3s; 
        }

        .btn-cancel:hover { 
            border-color: var(--brand-orange);
            color: white;
            background: rgba(255, 87, 34, 0.1);
        }

        .btn-home { 
            display: inline-block;
            margin-top: 40px; 
            color: var(--text-gray); 
            text-decoration: none; 
            font-family: 'Oswald', sans-serif;
            font-size: 0.85rem; 
            letter-spacing: 1px;
            text-transform: uppercase;
            transition: 0.3s; 
        }

        .btn-home:hover { color: var(--brand-orange); }

        .empty-msg {
            text-align: center;
            padding: 60px;
            color: #555;
            font-style: italic;
        }
    </style>
</head>
<body>

    <h2>TRANSACTION <span>LOGS</span></h2>
    
    <div class="history-container">
        <table>
            <thead>
                <tr>
                    <th>Plan Details</th>
                    <th>Amount</th>
                    <th>Payment Method</th>
                    <th>Verification Status</th>
                    <th style="text-align: right;">Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    // ✅ FIXED RUNTIME LOCATION RESOLUTION: Links cleanly to your data directories on a web server container environment
                    String webappRoot = application.getRealPath("/");
                    File paymentsFile = new File(webappRoot + "webappdata" + File.separator + "payments.txt");
                    boolean elementsFound = false;

                    if (paymentsFile.exists()) {
                        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(paymentsFile), "UTF-8"))) {
                            String line;
                            while ((line = br.readLine()) != null) {
                                if (line.trim().isEmpty()) continue;
                                
                                String[] parts = line.split(",");
                                if (parts.length >= 6) {
                                    String fileMemberId = parts[0].trim();
                                    String plan = parts[1].trim();
                                    String duration = parts[2].trim();
                                    String method = parts[3].trim();
                                    String amount = parts[4].trim();
                                    String status = parts[5].trim();

                                    // Filter logs specifically targeting the active user
                                    if (currentSessionUser.equalsIgnoreCase(fileMemberId)) {
                                        elementsFound = true;
                %>
                                        <tr>
                                            <td class="plan-name">
                                                <% if ("Gold".equalsIgnoreCase(plan)) { %>
                                                    <i class="fas fa-crown" style="color: #ffd700;"></i>
                                                <% } else if ("Silver".equalsIgnoreCase(plan)) { %>
                                                    <i class="fas fa-shield-halved" style="color: #c0c0c0;"></i>
                                                <% } else { %>
                                                    <i class="fas fa-dumbbell" style="color: #cd7f32;"></i>
                                                <% } %>
                                                <%= plan %> Membership (<%= duration %> Month<%= "1".equals(duration) ? "" : "s" %>)
                                            </td>
                                            <td style="font-family: 'Oswald', sans-serif; font-size: 1.1rem; color: white; letter-spacing: 0.5px;">
                                                Rs. <%= amount %>
                                            </td>
                                            <td>
                                                <i class="fas <%= "Card".equalsIgnoreCase(method) ? "fa-credit-card" : "fa-building-columns" %>" style="margin-right: 8px; opacity: 0.4; color: var(--brand-orange)"></i>
                                                <%= method %>
                                            </td>
                                            <td>
                                                <% if ("Verified".equalsIgnoreCase(status)) { %>
                                                    <span class="status-badge status-verified"><i class="fas fa-check-circle"></i> <%= status %></span>
                                                <% } else if ("Cancelled".equalsIgnoreCase(status)) { %>
                                                    <span class="status-badge status-cancelled"><i class="fas fa-times-circle"></i> <%= status %></span>
                                                <% } else { %>
                                                    <span class="status-badge status-pending"><i class="fas fa-circle-notch fa-spin"></i> <%= status %></span>
                                                <% } %>
                                            </td>
                                            <td style="text-align: right;">
                                                <% if (!"Cancelled".equalsIgnoreCase(status)) { %>
                                                    <a href="delete-payment.jsp?plan=<%= plan %>&amount=<%= amount %>" 
                                                       class="btn-cancel"
                                                       onclick="return confirm('Security Alert: Request cancellation of this transaction order record?')">
                                                        <i class="fas fa-ban"></i> Cancel
                                                    </a>
                                                <% } else { %>
                                                    <span style="color: #444; font-size: 11px; text-transform: uppercase; font-family: 'Oswald'; letter-spacing: 1px;">Terminated</span>
                                                <% } %>
                                            </td>
                                        </tr>
                <%
                                    }
                                }
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5' style='color:#ff4444; text-align:center; padding: 20px;'>Error parsing pipeline log arrays: " + e.getMessage() + "</td></tr>");
                        }
                    }

                    if (!elementsFound) {
                %>
                        <tr>
                            <td colspan="5" class="empty-msg">
                                <i class="fas fa-receipt" style="font-size: 3rem; display: block; margin-bottom: 15px; opacity: 0.15; color: var(--brand-orange);"></i>
                                No active membership transactions logged.
                            </td>
                        </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        
        <div style="text-align: center;">
            <a href="Dashboard.jsp" class="btn-home"><i class="fas fa-chevron-left"></i> Back To Hub Terminal</a>
        </div>
    </div>

</body>
</html>