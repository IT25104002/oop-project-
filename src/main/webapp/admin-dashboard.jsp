<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.util.*" %>
<%
    // Verify administrative clearance credentials
    String systemRole = (String) session.getAttribute("role");
    if (systemRole == null || !"ADMIN".equals(systemRole)) {
        // Kick unauthorized traffic back out to the gateway access terminal
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%
    // Metrics variables calculated directly from data flat-files
    int totalMembers = 0;
    int pendingPayments = 0;
    double totalRevenue = 0.0;
    int feedbackCount = 0;
    int totalClassesScheduled = 0; // Added for timetable tracking
    int totalAdmins = 0;

    String baseDir = application.getRealPath("/");
    File dataDir = new File(baseDir + "webappdata");
    
    // 1. Calculate Active Members Count
    File membersFile = new File(dataDir, "members.txt");
    if (membersFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(membersFile))) {
            while (br.readLine() != null) totalMembers++;
        } catch (Exception e) {}
    }

    // 2. Parse Ledger & Calculate Confirmed Revenue / Pending Actions
    File paymentsFile = new File(dataDir, "payments.txt");
    if (paymentsFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(paymentsFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                
                String[] parts = line.split(",");
                // Only process explicit transaction lines (e.g., TXN-XXXX...)
                if (parts.length >= 6 && parts[0].startsWith("TXN")) {
                    String status = parts[5].trim();
                    if ("PENDING".equalsIgnoreCase(status)) {
                        pendingPayments++;
                    } else if ("APPROVED".equalsIgnoreCase(status)) {
                        try {
                            totalRevenue += Double.parseDouble(parts[3].trim());
                        } catch(Exception ex) {}
                    }
                }
            }
        } catch (Exception e) {}
    }

    // 3. Calculate Athlete Feedback Submission Counts
    File feedbackFile = new File(dataDir, "feedback.txt");
    if (feedbackFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(feedbackFile))) {
            while (br.readLine() != null) feedbackCount++;
        } catch (Exception e) {}
    }

    // 4. Calculate Scheduled Classes / Timetable Sessions Count
    File scheduleFile = new File(dataDir, "schedule.txt");
    if (scheduleFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(scheduleFile))) {
            while (br.readLine() != null) totalClassesScheduled++;
        } catch (Exception e) {}
    }

    // 5. Calculate Administrative User Accounts Count
    File adminsFile = new File(dataDir, "admins.txt");
    if (adminsFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(adminsFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (!line.trim().isEmpty()) totalAdmins++;
            }
        } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FITNASE | HQ Admin Command Center</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&family=Oswald:wght@500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --brand-orange: #ff5722;
            --brand-glow: rgba(255, 87, 34, 0.3);
            --card-glass: rgba(20, 20, 20, 0.9);
            --text-gray: #aaaaaa;
        }
        body {
            margin: 0; padding: 0;
            background: linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0.9)), url('https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=1350&q=80');
            background-size: cover; background-position: center; background-attachment: fixed;
            color: white; font-family: 'Poppins', sans-serif;
        }
        header {
            background: #000; padding: 20px 50px;
            border-bottom: 2px solid var(--brand-orange);
            display: flex; justify-content: space-between; align-items: center;
        }
        .logo { font-family: 'Oswald', sans-serif; font-size: 1.8rem; font-weight: bold; letter-spacing: 2px; color: white; text-decoration: none; }
        .logo span { color: var(--brand-orange); }
        .logout-btn { color: #ff4444; text-decoration: none; font-family: 'Oswald', sans-serif; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; border: 1px solid #ff4444; padding: 8px 16px; border-radius: 4px; transition: 0.3s; }
        .logout-btn:hover { background: #ff4444; color: white; }

        .container { max-width: 1200px; margin: 50px auto; padding: 0 20px; box-sizing: border-box; }
        h2 { font-family: 'Oswald', sans-serif; font-size: 2.2rem; letter-spacing: 2px; text-transform: uppercase; margin-bottom: 5px; }
        h2 span { color: var(--brand-orange); }
        .subtitle { color: var(--text-gray); font-size: 0.95rem; margin-top: 0; margin-bottom: 40px; text-transform: uppercase; letter-spacing: 1px; }

        /* Metrics Display Grid Layout */
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 50px; }
        .metric-card { background: var(--card-glass); border: 1px solid #222; border-left: 4px solid #333; padding: 25px 20px; border-radius: 2px; display: flex; align-items: center; justify-content: space-between; }
        .metric-card.alert { border-left-color: #ffb300; }
        .metric-card.success { border-left-color: #4caf50; }
        .metric-card.info { border-left-color: #00bcd4; }
        .metric-card.purple { border-left-color: #9c27b0; }
        .metric-card.admin { border-left-color: var(--brand-orange); }
        
        .metric-info h3 { margin: 0; font-size: 0.75rem; color: var(--text-gray); text-transform: uppercase; letter-spacing: 1px; }
        .metric-info p { margin: 5px 0 0 0; font-family: 'Oswald', sans-serif; font-size: 1.8rem; font-weight: bold; }
        .metric-icon { font-size: 2.2rem; color: rgba(255,255,255,0.15); }
        .metric-card.alert .metric-icon { color: rgba(255,179,0,0.2); }
        .metric-card.success .metric-icon { color: rgba(76,175,80,0.2); }
        .metric-card.info .metric-icon { color: rgba(0,188,212,0.2); }
        .metric-card.purple .metric-icon { color: rgba(156, 39, 176, 0.2); }
        .metric-card.admin .metric-icon { color: rgba(255, 87, 34, 0.22); }

        /* Console Matrix Navigation Links */
        .controls-title { font-family: 'Oswald', sans-serif; font-size: 1.4rem; letter-spacing: 1px; margin-bottom: 20px; text-transform: uppercase; border-bottom: 1px solid #222; padding-bottom: 10px; }
        .controls-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 20px; }
        .control-box { background: rgba(0,0,0,0.6); border: 1px solid rgba(255,87,34,0.1); padding: 30px; border-radius: 2px; text-align: center; text-decoration: none; color: white; transition: 0.3s; }
        .control-box i { font-size: 2.5rem; color: var(--brand-orange); margin-bottom: 15px; display: block; }
        .control-box h4 { margin: 0 0 8px 0; font-family: 'Oswald', sans-serif; font-size: 1.2rem; letter-spacing: 1px; text-transform: uppercase; }
        .control-box p { margin: 0; font-size: 0.85rem; color: var(--text-gray); line-height: 1.4; }
        .control-box:hover { border-color: var(--brand-orange); transform: translateY(-4px); box-shadow: 0 10px 20px var(--brand-glow); background: var(--card-glass); }
    </style>
</head>
<body>

    <header>
        <a href="admin-dashboard.jsp" class="logo">FIT<span>NASE HQ</span></a>
        <a href="logout.jsp" class="logout-btn"><i class="fas fa-power-off"></i> Terminal Exit</a>
    </header>

    <div class="container">
        <h2>ADMINISTRATIVE <span>DASHBOARD</span></h2>
        <p class="subtitle">System Status and Facility Management Control Layer</p>

        <div class="metrics-grid">
            <div class="metric-card">
                <div class="metric-info">
                    <h3>Active Roster</h3>
                    <p><%= totalMembers %> Athletes</p>
                </div>
                <div class="metric-icon"><i class="fas fa-users"></i></div>
            </div>
            
            <div class="metric-card <%= pendingPayments > 0 ? "alert" : "" %>">
                <div class="metric-info">
                    <h3>Verification Needed</h3>
                    <p><%= pendingPayments %> Entries</p>
                </div>
                <div class="metric-icon"><i class="fas fa-wallet"></i></div>
            </div>

            <div class="metric-card success">
                <div class="metric-info">
                    <h3>Revenue Cleared</h3>
                    <p>Rs. <%= String.format("%,.2f", totalRevenue) %></p>
                </div>
                <div class="metric-icon"><i class="fas fa-dollar-sign"></i></div>
            </div>

            <div class="metric-card info">
                <div class="metric-info">
                    <h3>Reviews Logged</h3>
                    <p><%= feedbackCount %> Entries</p>
                </div>
                <div class="metric-icon"><i class="fas fa-comments"></i></div>
            </div>

            <div class="metric-card purple">
                <div class="metric-info">
                    <h3>Active Classes</h3>
                    <p><%= totalClassesScheduled %> Sessions</p>
                </div>
                <div class="metric-icon"><i class="fas fa-calendar-alt"></i></div>
            </div>

            <div class="metric-card admin">
                <div class="metric-info">
                    <h3>Admin Accounts</h3>
                    <p><%= totalAdmins %> Users</p>
                </div>
                <div class="metric-icon"><i class="fas fa-user-shield"></i></div>
            </div>
        </div>

        <div class="controls-title">Operations Console Matrix</div>
        <div class="controls-grid">
            <a href="admin-payments.jsp" class="control-box">
                <i class="fas fa-file-invoice-dollar"></i>
                <h4>Payment Vault</h4>
                <p>Verify bank transfer receipts, check payment entries, and approve pending accounts.</p>
            </a>

            <a href="admin-members.jsp" class="control-box">
                <i class="fas fa-user-cog"></i>
                <h4>Manage Members</h4>
                <p>View client profiles, track tier allocations, and modify flat-file records manually.</p>
            </a>

            <a href="admin-schedule.jsp" class="control-box">
                <i class="fas fa-calendar-days"></i>
                <h4>Schedule Manager</h4>
                <p>Configure gym floor opening blocks, add fitness sessions, and assign operational trainers.</p>
            </a>

            <a href="admin-diet.jsp" class="control-box">
                <i class="fas fa-utensils"></i>
                <h4>Diet Plan Console</h4>
                <p>Configure calorie macros, assign training nutritional meal files, and modify track diet limits.</p>
            </a>

            <a href="admin-feedback.jsp" class="control-box">
                <i class="fas fa-comments"></i>
                <h4>Athlete Feedback</h4>
                <p>Monitor customer remarks, system star ratings, and custom feedback indices.</p>
            </a>

            <a href="admin-management.jsp" class="control-box">
                <i class="fas fa-user-shield"></i>
                <h4>Admin Management</h4>
                <p>Add new admins, update staff access levels, disable accounts, and remove old administrator records.</p>
            </a>
            
            <a href="Dashboard.jsp" class="control-box" style="border-color: #333; grid-column: 1 / -1;">
                <i class="fas fa-dumbbell" style="color: #666;"></i>
                <h4>User Hub View</h4>
                <p>Temporarily drop out of system configurations and load up the normal athlete interface dashboard.</p>
            </a>
        </div>
    </div>

</body>
</html>
