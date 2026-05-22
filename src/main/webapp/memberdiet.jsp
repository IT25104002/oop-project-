<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fitnaze.demo.DietPlan, java.util.*" %>

<%
    // --- BYPASS FILE READ & FORCE PREMIUM ACCESS CONTROLS ---
    String loggedInId = (String) session.getAttribute("loggedInMemberId");
    if (loggedInId == null || loggedInId.trim().isEmpty() || loggedInId.equals("1")) {
        loggedInId = "MEM-101"; 
    }
    loggedInId = loggedInId.trim();

    String myName = (String) session.getAttribute("loggedInMemberName");
    if (myName == null || myName.trim().isEmpty()) {
        myName = "Tharu Kulasekara";
    }

    String myStatus = "GOLD TIER MEMBER"; 
    boolean hasPremiumAccess = true; 

    session.setAttribute("loggedInMemberId", loggedInId);
    session.setAttribute("loggedInMemberName", myName);

    String action = (String) request.getAttribute("action");
    if (action == null) {
        action = "list";
    }
    DietPlan plan = (DietPlan) request.getAttribute("generatedPlan");
    if (plan == null) {
        plan = (DietPlan) session.getAttribute("activeGeneratedPlan");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Fitnaze | My Diet Plan</title>
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
header { background: #000; padding: 20px 50px; display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid var(--brand-orange); }
.logo { font-size: 1.5rem; font-weight: bold; text-decoration: none; color: white; text-transform: uppercase;}
.logo span { color: var(--brand-orange); }
.hero { padding: 80px 50px; background: linear-gradient(to right, rgba(0,0,0,0.9), rgba(0,0,0,0.3)), url('https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1350&q=80'); background-size: cover; background-position: center; min-height: 35vh; display: flex; align-items: center; }
.hero h4 { color: var(--brand-orange); letter-spacing: 3px; font-size: 0.9rem; }
.hero h1 { font-size: 3rem; text-transform: uppercase; margin: 8px 0; line-height: 1.1; }
.hero p  { color: var(--text-gray); margin-top: 8px; }
.container { padding: 50px; max-width: 900px; margin: 0 auto; }
.panel { background: linear-gradient(145deg, #1a1a1a, #111); padding: 35px; border-radius: 12px; margin-bottom: 30px; border: 1px solid #333; box-shadow: 0 20px 50px rgba(0,0,0,0.4); }
.panel-title { color: var(--brand-orange); letter-spacing: 2px; margin-bottom: 25px; font-size: 1rem; text-transform: uppercase; }
.form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 25px; }
.form-group label { display: block; font-size: 0.75rem; letter-spacing: 1px; color: var(--text-gray); margin-bottom: 6px; text-transform: uppercase; }
.form-group select { width: 100%; padding: 12px; background: rgba(0,0,0,0.5); border: 1px solid #444; color: white; border-radius: 4px; font-size: 0.9rem; }
.btn-orange { background: var(--brand-orange); color: white; padding: 14px 40px; border: none; text-transform: uppercase; font-weight: bold; cursor: pointer; border-radius: 4px; font-size: 0.95rem; text-decoration: none; display: inline-block; width: 100%; text-align: center; }
.btn-orange:hover { box-shadow: 0 0 20px var(--glow-orange); }
.plan-result { background: rgba(255,87,34,0.05); border-left: 4px solid var(--brand-orange); border-radius: 8px; padding: 25px; white-space: pre-line; font-size: 0.95rem; color: var(--text-gray); line-height: 1.8; }

.macro-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin: 25px 0; }
.macro-card { background: #151515; border: 1px solid #252525; border-top: 3px solid var(--brand-orange); padding: 15px; border-radius: 6px; text-align: center; }
.macro-card h5 { font-size: 0.75rem; color: var(--text-gray); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 5px; }
.macro-card p { font-size: 1.4rem; font-weight: bold; color: white; }
.btn-download { background: transparent; color: white; border: 2px solid white; padding: 12px 30px; text-transform: uppercase; font-weight: bold; cursor: pointer; border-radius: 4px; font-size: 0.9rem; text-decoration: none; display: inline-block; width: 100%; text-align: center; margin-bottom: 15px; transition: all 0.3s ease; }
.btn-download:hover { background: white; color: black; }

@media(max-width: 600px){
    .macro-grid { grid-template-columns: repeat(2, 1fr); }
}
</style>
</head>
<body>

<header>
    <a href="user.jsp" class="logo">FIT<span>NAZE</span></a>
    <div style="color:var(--text-gray); font-size:0.9rem; text-transform:uppercase; letter-spacing:2px;">
        <i class="fas fa-user-circle" style="color:var(--brand-orange)"></i> &nbsp; <%= myStatus %>
    </div>
</header>

<section class="hero">
    <div>
        <h4><i class="fas fa-leaf"></i> &nbsp; PERSONALISED NUTRITION — 2026</h4>
        <h1>Your Diet<br>Plan</h1>
        <p>Get a customized meal plan based on your health preferences</p>
    </div>
</section>

<div class="container">

    <%-- CONFIG VIEW MODE SCREEN: Displays generated details --%>
    <% if (plan != null) { %>
    <div class="panel">
        <h3 class="panel-title"><i class="fas fa-clipboard-check"></i> &nbsp; Your Personalised Plan</h3>
        <p style="margin-bottom: 15px;"><strong>Plan ID:</strong> #<%= plan.getPlanId() %></p>
        <p style="margin-bottom: 15px;"><strong>Diet Style:</strong> <%= plan.getDietType() %></p>
        <p style="margin-bottom: 25px;"><strong>Goal Objective:</strong> <%= plan.getFitnessGoal() %></p>
        
        <h4 style="color:var(--brand-orange); font-size:0.85rem; text-transform:uppercase; margin-bottom:5px;">
            <i class="fas fa-calculator"></i> &nbsp; Target Macro Breakdown
        </h4>
        <div class="macro-grid">
            <div class="macro-card">
                <h5>Calories</h5>
                <p><%= plan.getCalories() %> <span style="font-size: 0.8rem; font-weight: normal; color: var(--text-gray);">kcal</span></p>
            </div>
            <div class="macro-card">
                <h5>Protein</h5>
                <p><%= plan.getProtein() %><span style="font-size: 0.8rem; font-weight: normal; color: var(--text-gray);">g</span></p>
            </div>
            <div class="macro-card">
                <h5>Carbs</h5>
                <p><%= plan.getCarbs() %><span style="font-size: 0.8rem; font-weight: normal; color: var(--text-gray);">g</span></p>
            </div>
            <div class="macro-card">
                <h5>Fats</h5>
                <p><%= plan.getFats() %><span style="font-size: 0.8rem; font-weight: normal; color: var(--text-gray);">g</span></p>
            </div>
        </div>
        
        <h4 style="color:var(--brand-orange); font-size:0.85rem; text-transform:uppercase; margin-bottom:12px;">
            <i class="fas fa-utensils"></i> &nbsp; Detailed Meal Plan
        </h4>
        <div class="plan-result"><%= plan.getPlanDetails() %></div>
        <br><br>
        
        <a href="dietplan/download?planId=<%= plan.getPlanId() %>" class="btn-download">
            <i class="fas fa-file-pdf" style="color: #ff3d00;"></i> &nbsp; Download Metric Plan PDF
        </a>
        
        <a href="memberdiet.jsp" class="btn-orange">Generate Another Plan</a>
    </div>
    <% } %>

    <%-- ALWAYS ACCESSIBLE GENERATOR CORE --%>
    <% if (plan == null) { %>
    <div class="panel">
        <h3 class="panel-title"><i class="fas fa-plus-circle"></i> &nbsp; Get Your Diet Plan</h3>
        <form action="dietplan" method="post">
            <div class="form-grid">
                <div class="form-group">
                    <label>Diet Type</label>
                    <select name="dietType" required>
                        <option value="" disabled selected>Select your diet</option>
                        <option value="vegetarian">🥦 Vegetarian</option>
                        <option value="non-vegetarian">🍗 Non-Vegetarian</option>
                    </select>
                </div>
                
                <div class="form-grid-item form-group">
                    <label>Fitness Goal</label>
                    <select name="fitnessGoal" required>
                        <option value="weight loss" selected>⬇ Weight Loss</option>
                        <option value="weight gain">⬆ Weight Gain</option>
                        <option value="maintenance">↔ Maintain Weight</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Activity Level</label>
                    <select name="activityLevel" required>
                        <option value="low">🚶 Low</option>
                        <option value="medium" selected>🏃 Medium</option>
                        <option value="high">⚡ High</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Medical Condition</label>
                    <select name="medicalCondition" required>
                        <option value="NO" selected>No medical conditions</option>
                        <option value="YES">Yes, I have a medical condition</option>
                    </select>
                </div>
            </div>
            <button type="submit" class="btn-orange">Generate My Diet Plan</button>
        </form>
    </div>
    <% } %>

</div>
</body>
</html>