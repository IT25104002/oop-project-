<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fitnaze.demo.DietPlan, java.util.*, java.io.*" %>

<%
    String loggedInId = (String) session.getAttribute("loggedInMemberId");
    if (loggedInId == null || loggedInId.trim().isEmpty()) {
        loggedInId = "MEM-101"; 
    }
    loggedInId = loggedInId.trim();

    String myName = "Athlete";
    String myStatus = "Standard Member"; 
    boolean hasPremiumAccess = false;

    String baseDir = System.getProperty("user.dir");
    File memberFile = new File(baseDir + File.separator + "src" + File.separator + "main" + File.separator + "webappdata" + File.separator + "members.txt");
    if (!memberFile.exists()) {
        memberFile = new File(baseDir + File.separator + "webappdata" + File.separator + "members.txt");
    }

    if (memberFile.exists()) {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(memberFile), "UTF-8"))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",");
                
                // FIX: Perform a strict alphanumeric check ignoring casing style or whitespace padding
                if (parts.length >= 2 && parts[0].trim().equalsIgnoreCase(loggedInId)) {
                    myName = parts[1].trim(); 
                    if (parts.length >= 5) {
                        myStatus = parts[4].trim(); 
                    } else if (parts.length >= 4) {
                        myStatus = parts[3].trim(); 
                    }
                    
                    String statusLower = myStatus.toLowerCase();
                    if (statusLower.contains("gold") || statusLower.contains("silver")) {
                        hasPremiumAccess = true;
                    }
                    break;
                }
            }
        } catch (Exception e) {
            // Baseline defaults
        }
    }

    DietPlan plan = (DietPlan) request.getAttribute("generatedPlan");
    String action = (String) request.getAttribute("action");
    if (action == null) {
        action = "list";
    }

    Integer calories = (Integer) request.getAttribute("calories");
    Integer protein = (Integer) request.getAttribute("protein");
    Integer carbs = (Integer) request.getAttribute("carbs");
    Integer fats = (Integer) request.getAttribute("fats");

    List<DietPlan> dietHistory = (List<DietPlan>) request.getAttribute("dietHistory");
    if (dietHistory == null) {
        dietHistory = new ArrayList<DietPlan>();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>FitNase | My Personal Nutrition Tracker</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
:root {
    --brand-orange: #ff5722;
    --dark-bg: #0f0f0f;
    --card-bg: #1a1a1a;
    --text-gray: #bbbbbb;
    --glow-orange: rgba(255, 87, 34, 0.4);
    --card-border: rgba(255, 87, 34, 0.15);
}
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: Arial, sans-serif; background: var(--dark-bg); color: white; }

header {
    background: #000;
    padding: 20px 50px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 2px solid var(--brand-orange);
}
.logo { font-size: 1.5rem; font-weight: bold; text-decoration: none; color: white; text-transform: uppercase; }
.logo span { color: var(--brand-orange); }

.hero {
    padding: 80px 50px;
    background: linear-gradient(to right, rgba(0,0,0,0.9), rgba(0,0,0,0.3)),
                url('https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=1350&q=80');
    background-size: cover;
    background-position: center;
    min-height: 35vh;
    display: flex;
    align-items: center;
}
.hero h4 { color: var(--brand-orange); letter-spacing: 3px; font-size: 0.9rem; }
.hero h1 { font-size: 3rem; text-transform: uppercase; margin: 8px 0; line-height: 1.1; }
.hero p  { color: var(--text-gray); margin-top: 8px; }

.container { padding: 50px; max-width: 900px; margin: 0 auto; }

.lock-panel { 
    background: linear-gradient(145deg, #161616, #0d0d0d); 
    border: 1px solid var(--card-border); 
    border-top: 4px solid var(--brand-orange); 
    padding: 60px 40px; 
    text-align: center; 
    border-radius: 12px; 
    box-shadow: 0 20px 50px rgba(0,0,0,0.6); 
    margin-bottom: 30px; 
}
.lock-icon { font-size: 4rem; color: var(--brand-orange); margin-bottom: 20px; }
.lock-panel h2 { font-size: 2.2rem; text-transform: uppercase; margin-bottom: 12px; letter-spacing: 1px; }
.lock-panel p { color: var(--text-gray); line-height: 1.6; margin-bottom: 30px; font-size: 1rem; }
.upgrade-btn { display: inline-block; background: var(--brand-orange); color: white; text-decoration: none; font-size: 1.1rem; font-weight: bold; letter-spacing: 1px; padding: 14px 40px; border-radius: 4px; text-transform: uppercase; transition: 0.3s; }
.upgrade-btn:hover { box-shadow: 0 0 20px var(--glow-orange); transform: translateY(-2px); }

@keyframes borderFlow {
    0%   { border-color: #333; }
    50%  { border-color: var(--brand-orange); }
    100% { border-color: #333; }
}
.panel {
    background: linear-gradient(145deg, #1a1a1a, #111);
    padding: 35px;
    border-radius: 12px;
    margin-bottom: 30px;
    border: 1px solid #333;
    animation: borderFlow 4s infinite ease-in-out;
    box-shadow: 0 20px 50px rgba(0,0,0,0.4);
}
.panel-title {
    color: var(--brand-orange);
    letter-spacing: 2px;
    margin-bottom: 25px;
    font-size: 1rem;
    text-transform: uppercase;
}

.form-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
    margin-bottom: 20px;
}
.form-group label {
    display: block;
    font-size: 0.75rem;
    letter-spacing: 1px;
    color: var(--text-gray);
    margin-bottom: 6px;
    text-transform: uppercase;
}
.form-group select {
    width: 100%;
    padding: 12px;
    background: rgba(0,0,0,0.5);
    border: 1px solid #444;
    color: white;
    border-radius: 4px;
    font-size: 0.9rem;
    transition: all 0.3s;
}
.form-group select:focus {
    outline: none;
    border-color: var(--brand-orange);
    box-shadow: 0 0 12px var(--glow-orange);
}
.form-group select option { background: #1a1a1a; }

.btn-orange {
    background: var(--brand-orange);
    color: white;
    padding: 14px 40px;
    border: none;
    text-transform: uppercase;
    font-weight: bold;
    cursor: pointer;
    border-radius: 4px;
    font-size: 0.95rem;
    transition: 0.3s;
    text-decoration: none;
    display: inline-block;
    width: 100%;
    text-align: center;
}
.btn-orange:hover { box-shadow: 0 0 20px var(--glow-orange); }

.btn-secondary {
    background: #222;
    color: #bbb;
    border: 1px solid #444;
    padding: 14px 40px;
    text-transform: uppercase;
    font-weight: bold;
    cursor: pointer;
    border-radius: 4px;
    font-size: 0.95rem;
    transition: 0.3s;
    text-decoration: none;
    display: inline-block;
    width: 100%;
    text-align: center;
}
.btn-secondary:hover { background: #333; color: white; border-color: #666; }

.badge {
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 0.72rem;
    text-transform: uppercase;
    letter-spacing: 1px;
    display: inline-block;
}
.badge-veg    { background: rgba(40,167,69,0.2); color: #28a745; border: 1px solid #28a745; }
.badge-nonveg { background: rgba(255,87,34,0.2); color: var(--brand-orange); border: 1px solid var(--brand-orange); }

.badge-water {
    background: rgba(0, 123, 255, 0.15);
    color: #007bff;
    border: 1px solid #007bff;
    padding: 3px 12px;
    border-radius: 20px;
    font-size: 0.85rem;
    font-weight: bold;
    display: inline-block;
}

.macro-dashboard {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    margin: 20px 0;
}
.macro-card {
    background: rgba(255,255,255,0.03);
    border: 1px solid rgba(255,255,255,0.05);
    padding: 15px;
    border-radius: 8px;
    text-align: center;
}
.macro-card h5 { font-size: 0.7rem; text-transform: uppercase; color: var(--text-gray); letter-spacing: 1px; margin-bottom: 5px; }
.macro-card p { font-size: 1.3rem; font-weight: bold; color: white; }
.macro-card p span { font-size: 0.8rem; color: var(--brand-orange); font-weight: normal; }

.plan-box {
    background: rgba(255,87,34,0.05);
    border-left: 4px solid var(--brand-orange);
    border-radius: 6px;
    padding: 25px;
    white-space: pre-line;
    font-size: 0.95rem;
    color: var(--text-gray);
    line-height: 1.8;
    margin-top: 15px;
}
.detail-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 20px;
    margin-bottom: 25px;
}
.detail-item label {
    display: block;
    font-size: 0.72rem;
    color: var(--brand-orange);
    letter-spacing: 1px;
    text-transform: uppercase;
    margin-bottom: 4px;
}
.detail-item p { font-size: 0.95rem; font-weight: bold; }
.empty-state { text-align: center; padding: 40px; color: var(--text-gray); }

.history-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
    font-size: 0.9rem;
}
.history-table th {
    background: #000;
    color: var(--brand-orange);
    text-transform: uppercase;
    font-size: 0.75rem;
    letter-spacing: 1px;
    padding: 12px;
    text-align: left;
    border-bottom: 2px solid #222;
}
.history-table td {
    padding: 14px 12px;
    border-bottom: 1px solid #222;
    color: var(--text-gray);
}
.history-table tr:hover td {
    background: rgba(255,255,255,0.02);
    color: white;
}
</style>
</head>
<body>

<header>
    <a href="dashboard" class="logo">FIT<span>NAZE</span></a>
    <div style="display: flex; align-items: center; gap: 20px;">
        <a href="dashboard" style="color: white; text-decoration: none; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; border: 1px solid #333; padding: 8px 16px; border-radius: 4px; background: #111; transition: 0.3s;" onmouseover="this.style.borderColor='#ff5722'" onmouseout="this.style.borderColor='#333'">
            <i class="fas fa-arrow-left"></i> Dashboard
        </a>
        <div style="color:var(--text-gray); font-size:0.9rem; text-transform:uppercase; letter-spacing:2px;">
            <i class="fas fa-user-circle" style="color:var(--brand-orange)"></i> &nbsp; <%= myStatus %> Portal
        </div>
    </div>
</header>

<section class="hero">
    <div>
        <h4><i class="fas fa-leaf"></i> &nbsp; PERSONALISED NUTRITION — 2026</h4>
        <h1>Your Diet<br>Plan</h1>
        <p>Generate and view custom tailored macro blueprints based on your targets</p>
    </div>
</section>

<div class="container">

<% if (!hasPremiumAccess) { %>
    <div class="lock-panel">
        <div class="lock-icon"><i class="fas fa-lock"></i></div>
        <h2>Premium Track Features</h2>
        <p>Hello <strong><%= myName %></strong>! Customized nutrition programs are reserved exclusively for our premium tier packages. Your tracking status is currently listed as a <strong><%= myStatus %></strong>.</p>
        <a href="dashboard" class="upgrade-btn">Unlock Diet Matrices</a>
    </div>
<% } else { %>

    <% if ("view".equals(action) && plan != null) { %>
    <div class="panel">
        <h3 class="panel-title"><i class="fas fa-clipboard-check"></i> &nbsp; Tailored Regime Blueprint</h3>
        
        <div class="detail-grid">
            <div class="detail-item">
                <label>Plan ID Reference</label>
                <p>#<%= plan.getPlanId() %></p>
            </div>
            <div class="detail-item">
                <label>Diet Track Category</label>
                <p>
                    <span class="badge <%= "vegetarian".equalsIgnoreCase(plan.getDietType()) ? "badge-veg" : "badge-nonveg" %>">
                        <%= plan.getDietType() %>
                    </span>
                </p>
            </div>
            <div class="detail-item">
                <label>Target Core Objective</label>
                <p><%= plan.getFitnessGoal() %></p>
            </div>
            <div class="detail-item">
                <label>Target Water Intake</label>
                <p>
                    <span class="badge-water">
                        <i class="fas fa-glass-water"></i> <%= plan.getWaterIntake() %> L / Day
                    </span>
                </p>
            </div>
        </div>

        <% if(calories != null) { %>
        <label style="font-size:0.75rem; color:var(--brand-orange); letter-spacing:1px; text-transform:uppercase; font-weight:bold;">
            <i class="fas fa-calculator"></i> &nbsp; Daily Target Energy & Macros Profile
        </label>
        <div class="macro-dashboard">
            <div class="macro-card">
                <h5>Calories</h5>
                <p><%= calories %> <span>kcal</span></p>
            </div>
            <div class="macro-card">
                <h5>Protein</h5>
                <p><%= protein %> <span>g</span></p>
            </div>
            <div class="macro-card">
                <h5>Carbohydrates</h5>
                <p><%= carbs %> <span>g</span></p>
            </div>
            <div class="macro-card">
                <h5>Fats</h5>
                <p><%= fats %> <span>g</span></p>
            </div>
        </div>
        <% } %>

        <label style="font-size:0.75rem; color:var(--brand-orange); letter-spacing:1px; text-transform:uppercase; font-weight:bold;">
            <i class="fas fa-utensils"></i> &nbsp; Configured Food Layout Schedule
        </label>
        <div class="plan-box"><%= plan.getPlanDetails() %></div>
        <br><br>

        <div style="display: flex; flex-direction: column; gap: 10px;">
            <a href="dietplan/download?planId=<%= plan.getPlanId() %>&type=<%= plan.getDietType() %>&goal=<%= plan.getFitnessGoal() %>&details=<%= java.net.URLEncoder.encode(plan.getPlanDetails(), "UTF-8") %>" 
               class="btn-orange" 
               style="background: #111; border: 1px solid var(--brand-orange);">
               <i class="fas fa-file-pdf"></i> Download Official PDF Blueprint
            </a>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                <a href="dietplan?action=list" class="btn-orange">Generate Another Track</a>
                <a href="dashboard" class="btn-secondary"><i class="fas fa-home"></i> Return to Dashboard</a>
            </div>
        </div>
    </div>

    <% } else { %>
    <div class="panel">
        <h3 class="panel-title"><i class="fas fa-plus-circle"></i> &nbsp; Generate New Nutrition Track</h3>
        <form action="dietplan" method="post">
            <div class="form-grid">
                <div class="form-group">
                    <label>Diet Allocation Profile</label>
                    <select name="dietType" required>
                        <option value="" disabled selected>Choose eating style...</option>
                        <option value="vegetarian">🥦 Strict Vegetarian Profile</option>
                        <option value="non-vegetarian">🍗 Non-Vegetarian Profile</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Fitness Target Goal</label>
                    <select name="fitnessGoal" required>
                        <option value="weight loss">⬇ Weight Loss Strategy</option>
                        <option value="weight gain">⬆ Weight Gain Strategy</option>
                        <option value="maintenance">↔ Balanced Maintenance</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Estimated Activity Level</label>
                    <select name="activityLevel" required>
                        <option value="low">🚶 Low Activity</option>
                        <option value="medium" selected>🏃 Medium Activity</option>
                        <option value="high">⚡ High Velocity Activity</option>
                    </select>
                </div>
            </div>
            <div style="display: grid; grid-template-columns: 3fr 1fr; gap: 15px;">
                <button type="submit" class="btn-orange">Compile My Custom Matrix</button>
                <a href="dashboard" class="btn-secondary" style="padding: 12px;"><i class="fas fa-arrow-left"></i> Back</a>
            </div>
        </form>
    </div>

    <div class="panel">
        <h3 class="panel-title"><i class="fas fa-history"></i> &nbsp; Track Compilation History</h3>
        <% if (dietHistory.isEmpty()) { %>
            <div class="empty-state">
                <p>No historic modifications saved on current cycle record log.</p>
            </div>
        <% } else { %>
            <table class="history-table">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Plan Token</th>
                        <th>Diet Profile</th>
                        <th>Fitness Target</th>
                        <th>Hydration</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (DietPlan historicPlan : dietHistory) { %>
                        <tr>
                            <td><%= historicPlan.getCreatedDate() %></td>
                            <td><strong>#<%= historicPlan.getPlanId() %></strong></td>
                            <td>
                                <span class="badge <%= "vegetarian".equalsIgnoreCase(historicPlan.getDietType()) ? "badge-veg" : "badge-nonveg" %>">
                                    <%= historicPlan.getDietType() %>
                                </span>
                            </td>
                            <td><%= historicPlan.getFitnessGoal() %></td>
                            <td><i class="fas fa-tint" style="color:#007bff;"></i> <%= historicPlan.getWaterIntake() %>L</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>
    <% } %>

<% } %>

</div>
</body>
</html>