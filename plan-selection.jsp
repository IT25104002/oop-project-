<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Fetch user IDs from active session variables to bridge continuity to checkout
    String loggedInMemberId = (String) session.getAttribute("memberId");
    if (loggedInMemberId == null || loggedInMemberId.trim().isEmpty()) {
        loggedInMemberId = "MEM-101"; // Consistent structural fallback identity
    }
    loggedInMemberId = loggedInMemberId.trim();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FitNase | Select Your Plan</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&family=Oswald:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --brand-orange: #ff5722;
            --brand-glow: rgba(255, 87, 34, 0.35);
            --dark-bg: #0f0f0f;
            --card-glass: rgba(20, 20, 20, 0.85);
            --card-border: rgba(255, 87, 34, 0.15);
            --text-gray: #bbbbbb;
            --glow-orange: rgba(255, 87, 34, 0.4);
        }
        body { 
            background: linear-gradient(rgba(10, 10, 10, 0.9), rgba(10, 10, 10, 0.9)), url('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1350&q=80'); 
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            color: white; 
            font-family: 'Poppins', sans-serif; 
            margin: 0; 
            padding: 0;
            display: flex; 
            flex-direction: column; 
            min-height: 100vh; 
            overflow-x: hidden;
        }
        
        /* Unified Header Dashboard Theme */
        header { 
            background: rgba(0, 0, 0, 0.9);
            padding: 20px 50px;
            border-bottom: 2px solid var(--brand-orange); 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            box-shadow: 0 4px 20px rgba(0,0,0,0.5);
            box-sizing: border-box;
            width: 100%;
        }
        .logo { font-family: 'Oswald', sans-serif; font-size: 1.8rem; font-weight: bold; letter-spacing: 2px; text-decoration: none; color: white; }
        .logo span { color: var(--brand-orange); }
        
        .dashboard-btn { color: white; text-decoration: none; font-family: 'Oswald', sans-serif; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; border: 1px solid #444; padding: 8px 16px; border-radius: 4px; background: transparent; transition: 0.3s; }
        .dashboard-btn:hover { border-color: var(--brand-orange); color: var(--brand-orange); }
        .user-pill { background: rgba(255, 87, 34, 0.1); padding: 8px 18px; border-radius: 4px; border: 1px solid var(--brand-orange); font-size: 0.85rem; font-weight: 600; letter-spacing: 1px; display: flex; align-items: center; gap: 10px; }

        .main-wrapper {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 60px 20px;
            box-sizing: border-box;
        }

        .header-title { 
            margin-bottom: 50px; 
            text-align: center; 
        }
        .header-title h1 { 
            font-family: 'Oswald', sans-serif;
            color: white; 
            font-size: 3rem;
            letter-spacing: 3px; 
            margin: 0;
            text-transform: uppercase;
        }
        .header-title h1 span { color: var(--brand-orange); text-shadow: 0 0 15px var(--brand-glow); }
        .header-title p { 
            color: var(--text-gray); 
            letter-spacing: 2px; 
            font-size: 0.9rem;
            margin-top: 10px;
            text-transform: uppercase;
        }
        .container { 
            display: flex; 
            gap: 30px; 
            flex-wrap: wrap; 
            justify-content: center; 
            max-width: 1100px;
            width: 100%;
        }
        .plan-card {
            background: var(--card-glass);
            border: 1px solid var(--card-border); 
            padding: 40px 30px; 
            border-radius: 4px;
            width: 280px; 
            text-align: center; 
            transition: 0.3s ease; 
            position: relative;
            backdrop-filter: blur(8px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            box-sizing: border-box;
        }
        .plan-card:hover { 
            border-color: var(--brand-orange); 
            transform: translateY(-8px); 
            box-shadow: 0 15px 40px var(--glow-orange);
        }
        .plan-card i { 
            font-size: 45px; 
            color: var(--brand-orange); 
            margin-bottom: 20px; 
        }
        .plan-card h3 {
            font-family: 'Oswald', sans-serif;
            font-size: 1.8rem;
            margin: 10px 0;
            letter-spacing: 2px;
        }
        .price { 
            font-family: 'Oswald', sans-serif;
            font-size: 32px; 
            font-weight: bold; 
            color: white;
            margin: 15px 0; 
        }
        .features { 
            font-size: 13px; 
            color: var(--text-gray); 
            margin-bottom: 35px; 
            list-style: none; 
            padding: 0; 
            line-height: 2.2;
            text-align: left;
            padding-left: 15px;
        }
        .features li::before {
            content: "✓ ";
            color: var(--brand-orange);
            font-weight: bold;
            margin-right: 8px;
        }
        .btn { 
            display: block;
            background: transparent; 
            color: white; 
            padding: 12px 20px; 
            border-radius: 2px; 
            border: 1px solid var(--brand-orange);
            text-decoration: none; 
            font-weight: bold; 
            font-family: 'Oswald', sans-serif;
            font-size: 14px; 
            letter-spacing: 1px;
            transition: 0.3s;
            text-transform: uppercase;
        }
        .btn:hover { 
            background: var(--brand-orange); 
            box-shadow: 0 0 15px var(--brand-glow);
            color: white;
        }
        .popular-badge {
            position: absolute;
            top: -15px;
            left: 50%;
            transform: translateX(-50%);
            background: var(--brand-orange);
            color: white;
            padding: 5px 18px;
            border-radius: 2px;
            font-size: 10px;
            font-family: 'Oswald', sans-serif;
            font-weight: bold;
            letter-spacing: 1px;
            box-shadow: 0 5px 10px rgba(0,0,0,0.3);
        }
        footer-text {
            margin-top: 60px; color: #444; font-size: 11px; letter-spacing: 2px; text-family: 'Oswald', sans-serif;
        }
    </style>
</head>
<body>

    <header>
        <a href="Dashboard.jsp" class="logo">FIT<span>NASE</span></a>
        <div style="display: flex; align-items: center; gap: 20px;">
            <a href="Dashboard.jsp" class="dashboard-btn"><i class="fas fa-arrow-left"></i> Hub Terminal</a>
            <div class="user-pill"><i class="fas fa-user-ninja"></i> <span>ID: <%= loggedInMemberId %></span></div>
        </div>
    </header>

    <div class="main-wrapper">
        <div class="header-title">
            <h1>CHOOSE YOUR <span>GOAL</span></h1>
            <p>Elite Memberships for High Performance</p>
        </div>

        <div class="container">
            <div class="plan-card">
                <i class="fas fa-dumbbell"></i>
                <h3>BRONZE</h3>
                <div class="price">Rs. 5,000</div>
                <ul class="features">
                    <li>Gym Access Only</li>
                    <li>Locker Facilities</li>
                    <li>Standard Support</li>
                </ul>
                <a href="payment-form.jsp?plan=Bronze&memberId=<%= loggedInMemberId %>" class="btn">Select Bronze</a>
            </div>

            <div class="plan-card" style="border-color: rgba(255, 87, 34, 0.45);">
                <div class="popular-badge">MOST POPULAR</div>
                <i class="fas fa-utensils"></i>
                <h3>SILVER</h3>
                <div class="price">Rs. 8,000</div>
                <ul class="features">
                    <li>Gym Access + Cardio</li>
                    <li>Personal Meal Plan</li>
                    <li>Weekly Progress Check</li>
                </ul>
                <a href="payment-form.jsp?plan=Silver&memberId=<%= loggedInMemberId %>" class="btn">Select Silver</a>
            </div>

            <div class="plan-card">
                <i class="fas fa-crown"></i>
                <h3>GOLD</h3>
                <div class="price">Rs. 12,000</div>
                <ul class="features">
                    <li>Personal Elite Coach</li>
                    <li>All Facilities Included</li>
                    <li>Customized Nutrition</li>
                </ul>
                <a href="payment-form.jsp?plan=Gold&memberId=<%= loggedInMemberId %>" class="btn">Select Gold</a>
            </div>
        </div>

        <p class="footer-text" style="margin-top: 60px; color: #444; font-size: 11px; letter-spacing: 2px;">FITNASE COMMAND CENTER © 2026</p>
    </div>

</body>
</html>