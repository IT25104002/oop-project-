<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.io.*" %>
<%
    // Verify member clearance credentials
    String systemRole = (String) session.getAttribute("role");
    if (systemRole == null || !"MEMBER".equals(systemRole)) {
        // Kick out unauthorized traffic
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Extracting user identity data from the authenticated session
    String activeMemberId = (String) session.getAttribute("memberId");
    String activeMemberName = (String) session.getAttribute("loggedInMemberName");
    String activeTierPackage = (String) session.getAttribute("memberPackage");
%>
<%
    String loggedInMemberId = (String) session.getAttribute("memberId");
    if (loggedInMemberId == null || loggedInMemberId.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }
    String targetId = loggedInMemberId.trim();

    String baseDir = application.getRealPath("/");
    File dataDir = new File(baseDir + "webappdata");
    if (!dataDir.exists()) {
        dataDir.mkdirs(); 
    }
    
    File memberFile = new File(dataDir, "members.txt");
    String action = request.getParameter("action");

    // Baseline Fallbacks
    String myName = (session.getAttribute("loggedInMemberName") != null) ? (String)session.getAttribute("loggedInMemberName") : "Elite Athlete";
    String myWeight = "70";
    String myHeight = "175";
    String myGoal = "Weight Loss";
    String myPhone = "";
    String myStatus = "BRONZE"; 
    String bmiString = "--";
    String bmiStatus = "No Data";

    // 1. DYNAMIC SCANNER & PARSER LOOP
    if (memberFile.exists()) {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(memberFile), "UTF-8"))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length >= 1 && parts[0].trim().equalsIgnoreCase(targetId)) {
                    
                    // Basic profile string extractions
                    if (parts.length >= 3 && !parts[2].trim().isEmpty()) myName = parts[2].trim();
                    
                    // Gather all non-empty elements after the name to isolate numeric blocks safely
                    List<String> numericTokens = new ArrayList<>();
                    for (int i = 3; i < parts.length; i++) {
                        String token = parts[i].trim();
                        if (!token.isEmpty()) {
                            // Check if token represents a decimal/integer metric value
                            if (token.matches("-?\\d+(\\.\\d+)?")) {
                                numericTokens.add(token);
                            } else if (token.equalsIgnoreCase("BRONZE") || token.equalsIgnoreCase("SILVER") || token.equalsIgnoreCase("GOLD")) {
                                myStatus = token.toUpperCase();
                            } else if (token.contains("Loss") || token.contains("Building") || token.contains("Training")) {
                                myGoal = token;
                            }
                        }
                    }

                    // Assign numeric strings sequentially based on automated token identification
                    if (numericTokens.size() >= 1) myWeight = numericTokens.get(0);
                    if (numericTokens.size() >= 2) myHeight = numericTokens.get(1);
                    if (numericTokens.size() >= 3 && myPhone.isEmpty()) {
                        // The remaining longer number string corresponds to the contact handle
                        for (String num : numericTokens) {
                            if (num.length() >= 8) myPhone = num;
                        }
                    }
                    break;
                }
            }
        } catch (IOException e) { }
    }

    // 2. SAFE PROFILE UPDATE EXECUTOR
    if ("updateWeight".equals(action) || "updateHeight".equals(action) || "updateGoal".equals(action)) {
        List<String> fileLines = new ArrayList<>();
        boolean updated = false;

        if (memberFile.exists()) {
            try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(memberFile), "UTF-8"))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] parts = line.split(",");
                    
                    if (parts.length >= 1 && parts[0].trim().equalsIgnoreCase(targetId)) {
                        // Re-identify active metrics inside target row vector to update them inline safely
                        int weightIndex = -1;
                        int heightIndex = -1;
                        int goalIndex = -1;
                        
                        for (int i = 3; i < parts.length; i++) {
                            String val = parts[i].trim();
                            if (val.matches("-?\\d+(\\.\\d+)?") && val.equals(myWeight) && weightIndex == -1) {
                                weightIndex = i;
                            } else if (val.matches("-?\\d+(\\.\\d+)?") && val.equals(myHeight) && weightIndex != -1 && heightIndex == -1) {
                                heightIndex = i;
                            } else if (val.equalsIgnoreCase(myGoal)) {
                                goalIndex = i;
                            }
                        }

                        // Fallback fallback index layout if metrics weren't set yet
                        if (weightIndex == -1) weightIndex = 3;
                        if (heightIndex == -1) heightIndex = 4;
                        if (goalIndex == -1) goalIndex = 5;

                        if ("updateWeight".equals(action)) {
                            String input = request.getParameter("newWeight");
                            if (input != null && !input.trim().isEmpty()) { parts[weightIndex] = input.trim(); updated = true; }
                        } else if ("updateHeight".equals(action)) {
                            String input = request.getParameter("newHeight");
                            if (input != null && !input.trim().isEmpty()) { parts[heightIndex] = input.trim(); updated = true; }
                        } else if ("updateGoal".equals(action)) {
                            String input = request.getParameter("newGoal");
                            if (input != null && !input.trim().isEmpty()) { parts[goalIndex] = input.trim(); updated = true; }
                        }
                        
                        StringBuilder sb = new StringBuilder();
                        for (int i = 0; i < parts.length; i++) {
                            sb.append(parts[i].trim()).append(i < parts.length - 1 ? "," : "");
                        }
                        fileLines.add(sb.toString());
                    } else {
                        fileLines.add(line);
                    }
                }
            } catch (IOException e) { }
        }

        if (updated) {
            try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(memberFile, false), "UTF-8"))) {
                for (String l : fileLines) { bw.write(l); bw.newLine(); }
                bw.flush();
            } catch (IOException e) { }
            response.sendRedirect("Dashboard.jsp");
            return;
        }
    }

    // 3. BMI CALCULATION ENGINE
    try {
        double w = Double.parseDouble(myWeight);
        double h = Double.parseDouble(myHeight) / 100.0;
        if (h > 0) {
            double bmi = w / (h * h);
            bmiString = String.format("%.1f", bmi);
            if (bmi < 18.5) bmiStatus = "Underweight";
            else if (bmi < 24.9) bmiStatus = "Optimal Metric";
            else if (bmi < 29.9) bmiStatus = "Overweight";
            else bmiStatus = "Obese";
        }
    } catch (Exception ex) {
        bmiString = "--";
        bmiStatus = "Data Error";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FITNASE | Central Terminal Hub</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;600;700&family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand-orange: #ff5722;
            --brand-glow: rgba(255, 87, 34, 0.35);
            --dark-overlay: rgba(10, 10, 10, 0.88);
            --card-glass: rgba(20, 20, 20, 0.75);
            --card-border: rgba(255, 87, 34, 0.15);
            --text-gray: #bbbbbb;
        }
        body { font-family: 'Poppins', sans-serif; margin: 0; padding: 0; background: linear-gradient(var(--dark-overlay), var(--dark-overlay)), url('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1350&q=80'); background-size: cover; background-position: center; background-attachment: fixed; color: white; min-height: 100vh; }
        header { background: rgba(0, 0, 0, 0.9); padding: 20px 50px; display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid var(--brand-orange); box-shadow: 0 4px 20px rgba(0,0,0,0.5); }
        .logo { font-family: 'Oswald', sans-serif; font-size: 1.8rem; font-weight: bold; letter-spacing: 2px; }
        .logo span { color: var(--brand-orange); }
        .user-pill { background: rgba(255, 87, 34, 0.1); padding: 8px 18px; border-radius: 4px; border: 1px solid var(--brand-orange); font-size: 0.85rem; font-weight: 600; letter-spacing: 1px; display: flex; align-items: center; gap: 12px; }
        .user-pill .divider { color: var(--brand-orange); font-weight: normal; }
        .hero-banner { padding: 50px; max-width: 1200px; margin: 0 auto; box-sizing: border-box; }
        .hero-banner h1 { font-family: 'Oswald', sans-serif; font-size: 3rem; text-transform: uppercase; margin: 0; letter-spacing: 2px; }
        .hero-banner h1 span { color: var(--brand-orange); text-shadow: 0 0 15px var(--brand-glow); }
        .hero-banner p { margin: 5px 0 0 0; color: var(--text-gray); font-size: 1rem; letter-spacing: 1px; }
        
        .dashboard-grid { max-width: 1200px; margin: 0 auto 60px auto; padding: 0 50px; display: grid; grid-template-columns: 2.2fr 1fr; gap: 40px; box-sizing: border-box; }
        .section-title { font-family: 'Oswald', sans-serif; font-size: 1.3rem; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 25px; display: flex; align-items: center; gap: 12px; border-left: 4px solid var(--brand-orange); padding-left: 12px; }
        
        .vitals-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 40px; }
        .vital-card { background: var(--card-glass); border: 1px solid var(--card-border); padding: 25px 20px; border-radius: 4px; position: relative; backdrop-filter: blur(8px); transition: all 0.3s ease; }
        .vital-card:hover { border-color: var(--brand-orange); box-shadow: 0 5px 20px rgba(255, 87, 34, 0.15); transform: translateY(-2px); }
        .vital-card label { display: block; color: var(--text-gray); font-size: 0.8rem; text-transform: uppercase; letter-spacing: 1px; font-weight: 500; }
        .vital-card .value { font-family: 'Oswald', sans-serif; font-size: 2.4rem; font-weight: bold; margin-top: 10px; }
        .vital-card .value span { font-size: 1rem; color: var(--text-gray); font-family: 'Poppins', sans-serif; margin-left: 5px; font-weight: 400; }
        .bmi-status { display: inline-block; margin-top: 5px; font-size: 0.75rem; background: rgba(255, 87, 34, 0.15); color: var(--brand-orange); padding: 2px 8px; border-radius: 2px; font-weight: 600; text-transform: uppercase; }
        .metric-update-form { display: flex; margin-top: 12px; gap: 5px; border-top: 1px solid rgba(255,255,255,0.05); padding-top: 12px; }
        .metric-update-form input { width: 70px; background: #000; border: 1px solid #333; color: white; padding: 5px 8px; font-size: 0.8rem; border-radius: 2px; text-align: center; }
        .metric-update-form button { background: var(--brand-orange); color: white; border: none; padding: 5px 10px; font-size: 0.75rem; font-family: 'Oswald', sans-serif; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; border-radius: 2px; }
        
        .control-deck { display: grid; grid-template-columns: repeat(2, 1fr); gap: 25px; }
        .deck-btn { background: var(--card-glass); border: 1px solid var(--card-border); padding: 35px 20px; border-radius: 4px; text-decoration: none; color: white; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 15px; backdrop-filter: blur(8px); transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); cursor: pointer; }
        .deck-btn i { font-size: 2.2rem; color: var(--brand-orange); }
        .deck-btn span { font-family: 'Oswald', sans-serif; font-size: 1.05rem; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; text-align: center; }
        .deck-btn:hover { border-color: var(--brand-orange); background: rgba(255, 87, 34, 0.04); box-shadow: 0 8px 25px rgba(255, 87, 34, 0.2); transform: translateY(-4px); }
        
        .sidebar-card { background: rgba(10, 10, 10, 0.9); border: 1px solid var(--card-border); padding: 35px 25px; border-radius: 4px; backdrop-filter: blur(10px); box-shadow: 0 10px 40px rgba(0,0,0,0.6); }
        .sidebar-card h3 { font-family: 'Oswald', sans-serif; text-transform: uppercase; letter-spacing: 1.5px; margin-top: 0; font-size: 1.2rem; margin-bottom: 20px; }
        .goal-select-dropdown { width: 100%; background: #000000; color: #ffffff; border: 1px solid var(--brand-orange); border-left: 4px solid var(--brand-orange); padding: 15px; font-family: 'Poppins', sans-serif; font-weight: 600; border-radius: 2px; cursor: pointer; }
        .logout-btn { display: block; width: 100%; padding: 14px; background: transparent; border: 1px solid #444; color: #aaa; font-family: 'Oswald', sans-serif; font-weight: 600; letter-spacing: 2px; border-radius: 4px; text-align: center; text-decoration: none; text-transform: uppercase; margin-top: 30px; cursor: pointer; box-sizing: border-box; }
        .logout-btn:hover { border-color: #f44336; color: white; background: #f44336; }
        .tier-badge { background: linear-gradient(135deg, var(--brand-orange), #ff7043); padding: 2px 10px; border-radius: 2px; font-size: 0.75rem; font-weight: bold; letter-spacing: 1px; color: white; }
    </style>
    <script type="text/javascript">
        function verifyDietAccess() {
            var currentTier = "<%= myStatus %>";
            if (currentTier === "BRONZE") {
                alert("🔒 Access Denied: Personalized Diet Plans are exclusively reserved for Silver and Gold membership tiers.");
            } else {
                window.location.href = "memberdiet.jsp";
            }
        }
    </script>
</head>
<body>
    <header>
        <div class="logo">FIT<span>NASE</span></div>
        <div class="user-pill">
            <i class="fas fa-id-badge"></i> 
            <span><%= targetId %></span>
            <% if(!myPhone.isEmpty()){ %>
                <span class="divider">|</span>
                <i class="fas fa-phone"></i>
                <span><%= myPhone %></span>
            <% } %>
            <span class="tier-badge"><%= myStatus %></span>
        </div>
    </header>
    <section class="hero-banner">
        <h1>Welcome Back, <span><%= myName %></span></h1>
        <p>Accessing secure console data stream metrics.</p>
    </section>
    <main class="dashboard-grid">
        <div>
            <div class="section-title"><i class="fas fa-chart-line" style="color: var(--brand-orange);"></i> Biometric Performance Streams</div>
            <div class="vitals-row">
                <div class="vital-card">
                    <label>Current Weight</label>
                    <div class="value"><%= myWeight %><span>kg</span></div>
                    <form action="Dashboard.jsp" method="POST" class="metric-update-form">
                        <input type="hidden" name="action" value="updateWeight">
                        <input type="number" name="newWeight" placeholder="New kg" min="30" max="250" step="any" required>
                        <button type="submit">Log</button>
                    </form>
                </div>
                <div class="vital-card">
                    <label>Registered Height</label>
                    <div class="value"><%= myHeight %><span>cm</span></div>
                    <form action="Dashboard.jsp" method="POST" class="metric-update-form">
                        <input type="hidden" name="action" value="updateHeight">
                        <input type="number" name="newHeight" placeholder="New cm" min="100" max="250" step="any" required>
                        <button type="submit">Log</button>
                    </form>
                </div>
                <div class="vital-card">
                    <label>Body Mass Index</label>
                    <div class="value"><%= bmiString %></div>
                    <span class="bmi-status"><%= bmiStatus %></span>
                </div>
            </div>

            <div class="section-title"><i class="fas fa-cubes" style="color: var(--brand-orange);"></i> Command Control Matrix</div>
            <div class="control-deck">
                <a href="plan-selection.jsp" class="deck-btn"><i class="fas fa-credit-card"></i><span>Billing Portal</span></a>
                <a href="user.jsp" class="deck-btn"><i class="fas fa-calendar-alt"></i><span>Schedules Terminal</span></a>
                <a href="Feedback.jsp" class="deck-btn"><i class="fas fa-comments"></i><span>Feedback Portal</span></a>
                <div onclick="verifyDietAccess()" class="deck-btn"><i class="fas fa-utensils"></i><span>Diet Plan Matrix</span></div>
            </div>
        </div>
        
        <div>
            <div class="sidebar-card">
                <h3>Target Objective</h3>
                <form action="Dashboard.jsp" method="POST" class="goal-wrapper-form">
                    <input type="hidden" name="action" value="updateGoal">
                    <select name="newGoal" class="goal-select-dropdown" onchange="this.form.submit()">
                        <option value="Weight Loss" <%= "Weight Loss".equals(myGoal) ? "selected" : "" %>>Weight Loss</option>
                        <option value="Muscle Building" <%= "Muscle Building".equals(myGoal) ? "selected" : "" %>>Muscle Building</option>
                        <option value="Endurance Training" <%= "Endurance Training".equals(myGoal) ? "selected" : "" %>>Endurance Training</option>
                    </select>
                </form>
                
                <a href="logout.jsp" class="logout-btn">Terminate Session</a>
            </div>
        </div>
    </main>
</body>
</html>