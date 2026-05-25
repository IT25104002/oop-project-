<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    // 1. Extract parameters from the incoming URL query string
    String loggedInMemberId = request.getParameter("memberId");
    if (loggedInMemberId == null || loggedInMemberId.trim().isEmpty()) {
        loggedInMemberId = (String) session.getAttribute("memberId");
    }
    
    // Safety fallback framework assignment
    if (loggedInMemberId == null || loggedInMemberId.trim().isEmpty()) {
        loggedInMemberId = "MEM-101"; 
    } else {
        loggedInMemberId = loggedInMemberId.trim();
    }
    
    String planParam = request.getParameter("plan");
    if (planParam == null || planParam.trim().isEmpty()) {
        planParam = "Bronze"; 
    } else {
        planParam = planParam.trim();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FITNASE | Elite Secure Payment Gateway</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&family=Oswald:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --brand-orange: #ff5722;
            --brand-glow: rgba(255, 87, 34, 0.35);
            --dark-bg: #0f0f0f;
            --card-bg: rgba(20, 20, 20, 0.9);
            --text-gray: #bbbbbb;
            --glow-orange: rgba(255, 87, 34, 0.4);
        }
        body { 
            margin: 0; background: linear-gradient(rgba(0, 0, 0, 0.85), rgba(0, 0, 0, 0.85)), url('https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1350&q=80'); 
            background-size: cover; background-position: center; background-attachment: fixed;
            color: white; font-family: 'Poppins', sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; 
        }
        .card { 
            background: var(--card-bg); backdrop-filter: blur(10px); padding: 40px; border-radius: 4px; 
            width: 450px; border: 1px solid rgba(255, 87, 34, 0.15); box-shadow: 0 20px 50px rgba(0,0,0,0.7); position: relative; box-sizing: border-box;
        }
        .card::before { content: ""; position: absolute; top: 0; left: 0; width: 100%; height: 3px; background: var(--brand-orange); box-shadow: 0 0 15px var(--brand-orange); }
        h2 { text-align: center; font-family: 'Oswald', sans-serif; font-size: 2rem; letter-spacing: 3px; margin-top: 0; margin-bottom: 5px; text-transform: uppercase; }
        h2 span { color: var(--brand-orange); }
        .user-info { text-align: center; font-size: 13px; color: var(--text-gray); margin-bottom: 25px; background: rgba(255, 87, 34, 0.05); padding: 15px; border-radius: 2px; border: 1px dashed rgba(255, 87, 34, 0.2); }
        label { font-size: 11px; color: var(--brand-orange); font-weight: bold; display: block; margin-top: 20px; text-transform: uppercase; letter-spacing: 1px; }
        select, input { width: 100%; padding: 12px; background: #000; border: 1px solid #333; color: white; border-radius: 2px; margin-top: 6px; box-sizing: border-box; outline: none; font-family: inherit; transition: 0.3s; }
        select:focus, input:focus { border-color: var(--brand-orange); box-shadow: 0 0 10px var(--glow-orange); }
        .method-box { background: rgba(0, 0, 0, 0.5); padding: 20px; border-radius: 2px; margin-top: 15px; border-left: 4px solid var(--brand-orange); box-sizing: border-box; }
        .total-box { background: rgba(255, 87, 34, 0.08); padding: 20px; text-align: center; margin-top: 25px; border-radius: 2px; border: 1px dashed var(--brand-orange); }
        .btn { width: 100%; padding: 15px; background: var(--brand-orange); border: none; color: white; font-family: 'Oswald', sans-serif; font-size: 1.1rem; letter-spacing: 1px; font-weight: bold; margin-top: 25px; cursor: pointer; border-radius: 2px; transition: 0.3s; text-transform: uppercase; }
        .btn:hover { background: #e64a19; box-shadow: 0 0 20px var(--brand-glow); }
        .plan-badge { background: var(--brand-orange); color: white; padding: 3px 14px; border-radius: 2px; font-family: 'Oswald', sans-serif; font-weight: bold; letter-spacing: 1px; text-transform: uppercase; font-size: 0.8rem; margin-left: 5px; }
    </style>
</head>
<body>
    <div class="card">
        <h2>SECURE <span>PAYMENT</span></h2>
        <div class="user-info">
            <i class="fas fa-shield-alt"></i> Athlete Session ID: <b><%= loggedInMemberId %></b><br>
            <div style="margin-top: 10px;">
                Selected Tier: <span class="plan-badge"><%= planParam %></span>
            </div>
        </div>

        <form action="payment-success.jsp" method="POST">
            <input type="hidden" name="memberId" value="<%= loggedInMemberId %>">
            <input type="hidden" name="plan" value="<%= planParam %>">
            
            <label><i class="fas fa-clock"></i> Membership Duration</label>
            <select name="duration" id="duration" onchange="calculate()">
                <option value="1">1 Month (Regular)</option>
                <option value="3">3 Months (5% OFF)</option>
                <option value="6">6 Months (10% OFF)</option>
                <option value="12">12 Months (20% OFF)</option>
            </select>

            <label><i class="fas fa-credit-card"></i> Payment Method</label>
            <select name="paymentMethod" id="method" onchange="toggleFields()">
                <option value="Card">Credit / Debit Card</option>
                <option value="Online">Online Bank Transfer</option>
            </select>

            <div id="cardFields" class="method-box">
                <input type="text" placeholder="Card Number (16 Digits)" maxlength="16">
                <div style="display: flex; gap: 10px; margin-top: 10px;">
                    <input type="text" placeholder="MM/YY" maxlength="5">
                    <input type="password" placeholder="CVV" maxlength="3">
                </div>
            </div>

            <div id="onlineFields" class="method-box" style="display:none;">
                <p style="font-size: 12px; margin: 0 0 12px 0; color: var(--text-gray);">
                    Official Vault Account: <b style="color: white; letter-spacing: 0.5px;">BOC — 123456789</b>
                </p>
                <label style="color: #888; margin-top: 5px;">Upload Deposit Slip Receipt</label>
                <input type="file" style="font-size: 11px; border: none; background: none; padding: 10px 0; cursor: pointer;">
            </div>

            <div class="total-box">
                <span style="font-size: 10px; color: var(--text-gray); letter-spacing: 2px; font-weight: 500;">TOTAL AMOUNT DUE</span><br>
                <span style="font-size: 32px; font-weight: bold; color: white; font-family: 'Oswald', sans-serif;">Rs. <span id="displayAmount">0</span></span>
                <input type="hidden" name="amount" id="finalAmount">
            </div>

            <button type="submit" class="btn">Confirm & Pay Now</button>
        </form>
    </div>

    <script>
        function calculate() {
            const prices = {"BRONZE": 5000, "SILVER": 8000, "GOLD": 12000};
            const discounts = {"1": 0, "3": 0.05, "6": 0.10, "12": 0.20};
            
            let plan = "<%= planParam.toUpperCase() %>";
            let duration = document.getElementById("duration").value;
            
            let basePrice = (prices[plan] || 5000) * duration;
            let discountAmount = basePrice * discounts[duration];
            let finalPrice = basePrice - discountAmount;

            document.getElementById("displayAmount").innerText = finalPrice.toLocaleString();
            document.getElementById("finalAmount").value = finalPrice;
        }

        function toggleFields() {
            let method = document.getElementById("method").value;
            document.getElementById("cardFields").style.display = (method === 'Card') ? 'block' : 'none';
            document.getElementById("onlineFields").style.display = (method === 'Online') ? 'block' : 'none';
        }

        window.onload = calculate;
    </script>
</body>
</html>