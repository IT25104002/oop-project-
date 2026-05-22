<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FITNASE | Gateway Access Control</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;700&family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand-orange: #ff5722; 
            --black-bg: #050505;
            --card-gray: rgba(12, 12, 12, 0.98);
            --text-gray: #a0a0a0;
            --input-bg: #000;
            --border-color: #222;
        }
        body {
            font-family: 'Poppins', sans-serif; margin: 0; height: 100vh; display: flex; justify-content: center; align-items: center; overflow: hidden;
            background: linear-gradient(rgba(0,0,0,0.85), rgba(0,0,0,0.7)), url('https://images.unsplash.com/photo-1593079831268-3381b0db4a77?q=80&w=2069&auto=format&fit=crop');
            background-size: cover; background-position: center;
        }
        .login-card { background: var(--card-gray); padding: 45px 40px; border-radius: 8px; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.8); width: 380px; text-align: center; border: 1px solid var(--border-color); border-top: 4px solid var(--brand-orange); }
        h2 { font-family: 'Oswald', sans-serif; color: #fff; margin-bottom: 5px; font-size: 2.2rem; letter-spacing: 4px; }
        h2 span { color: var(--brand-orange); }
        .subtitle { color: var(--text-gray); font-size: 10px; letter-spacing: 2px; margin-bottom: 30px; text-transform: uppercase; }
        
        /* TOGGLE TERMINAL INTERFACE */
        .portal-toggle { display: grid; grid-template-columns: 1fr 1fr; background: var(--input-bg); border: 1px solid var(--border-color); padding: 4px; border-radius: 6px; margin-bottom: 30px; }
        .toggle-btn { padding: 10px; font-family: 'Oswald', sans-serif; font-size: 0.9rem; color: var(--text-gray); border: none; background: transparent; cursor: pointer; border-radius: 4px; transition: 0.3s; letter-spacing: 1px; }
        .toggle-btn.active { background: var(--brand-orange); color: #fff; }
        
        .form-group { margin-bottom: 22px; text-align: left; }
        label { color: var(--brand-orange); font-family: 'Oswald', sans-serif; font-size: 11px; letter-spacing: 1px; display: block; margin-bottom: 8px; }
        input { width: 100%; padding: 14px; background: var(--input-bg); border: 1px solid var(--border-color); border-radius: 4px; color: #fff; box-sizing: border-box; font-family: inherit; transition: 0.3s; }
        input:focus { outline: none; border-color: var(--brand-orange); background: #0f0f0f; }
        button { width: 100%; padding: 15px; background: var(--brand-orange); color: white; border: none; border-radius: 4px; font-family: 'Oswald', sans-serif; font-size: 1.1rem; font-weight: bold; text-transform: uppercase; letter-spacing: 2px; cursor: pointer; transition: 0.3s; margin-top: 10px; }
        button:hover { background: #e64a19; box-shadow: 0 0 20px rgba(255, 87, 34, 0.4); transform: translateY(-1px); }
    </style>
</head>
<body>
    <div class="login-card">
        <h2>FIT<span>NASE</span></h2>
        <div class="subtitle">System Gateway Access</div>
        
        <div class="portal-toggle">
            <button class="toggle-btn active" id="memBtn" onclick="setPortal('member')">Member Access</button>
            <button class="toggle-btn" id="admBtn" onclick="setPortal('admin')">Staff Terminal</button>
        </div>

        <%-- Form action redirected to look directly at your servlet's URL mapping url --%>
        <form action="AdminAuthServlet" method="POST">
            <input type="hidden" name="action" value="login">
            <input type="hidden" name="portalType" id="portalType" value="member">
            
            <div class="form-group">
                <label id="idLabel">MEMBER SECURITY ID</label>
                <input type="text" name="id" id="idInput" placeholder="e.g., MEM-101" required autocomplete="off">
            </div>
            <div class="form-group">
                <label>SECURITY PASSPHRASE</label>
                <input type="password" name="pass" placeholder="••••••••" required>
            </div>
            <button type="submit">Authorize System Entry</button>
        </form>
        
        <div id="registerPrompt" style="margin-top: 25px; font-size: 12px; color: var(--text-gray);">
            Need access? <a href="register.jsp" style="color: var(--brand-orange); text-decoration: none; font-weight: 600;">Register Athlete Profile Here</a>
        </div>
    </div>

    <script>
        function setPortal(type) {
            document.getElementById('portalType').value = type;
            document.getElementById('memBtn').classList.toggle('active', type === 'member');
            document.getElementById('admBtn').classList.toggle('active', type === 'admin');
            
            const idLabel = document.getElementById('idLabel');
            const idInput = document.getElementById('idInput');
            const regPrompt = document.getElementById('registerPrompt');
            
            if(type === 'admin') {
                idLabel.innerText = "ADMINISTRATOR SYSTEM USERNAME";
                idInput.placeholder = "Enter staff username...";
                regPrompt.style.visibility = "hidden";
            } else {
                idLabel.innerText = "MEMBER SECURITY ID";
                idInput.placeholder = "e.g., MEM-101";
                regPrompt.style.visibility = "visible";
            }
        }
    </script>
</body>
</html>