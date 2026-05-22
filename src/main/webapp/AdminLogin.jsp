<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ta">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FITNASE | Elite Admin Access</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --brand-orange: #ff5722;
            --black-bg: #0a0a0a;
            --card-glass: rgba(18, 18, 18, 0.9);
            --text-gray: #888;
        }

        body {
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background: linear-gradient(rgba(0,0,0,0.8), rgba(0,0,0,0.8)), 
                        url('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=2070&auto=format&fit=crop');
            background-size: cover;
            background-position: center;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0;
            overflow: hidden;
            color: white;
        }

        /* பின்னணியில் மிதக்கும் ஐகான்கள் */
        .bg-icons {
            position: absolute;
            width: 100%;
            height: 100%;
            z-index: 1;
            pointer-events: none;
        }

        .bg-icons i {
            position: absolute;
            color: var(--brand-orange);
            opacity: 0.1;
            animation: float 10s linear infinite;
            bottom: -50px;
        }

        @keyframes float {
            0% { transform: translateY(0) rotate(0deg); opacity: 0; }
            20% { opacity: 0.15; }
            100% { transform: translateY(-110vh) rotate(360deg); opacity: 0; }
        }

        /* லாகின் கார்டு டிசைன் */
        .login-card {
            background: var(--card-glass);
            padding: 45px;
            border-radius: 20px;
            backdrop-filter: blur(15px);
            border: 1px solid rgba(255, 87, 34, 0.3);
            box-shadow: 0 0 40px rgba(0,0,0,0.9), 0 0 15px rgba(255, 87, 34, 0.1);
            width: 380px;
            text-align: center;
            position: relative;
            z-index: 10;
            animation: cardEntrance 0.8s cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        @keyframes cardEntrance {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        h2 { 
            color: #fff; 
            margin-bottom: 5px; 
            text-transform: uppercase; 
            letter-spacing: 3px;
            font-weight: 800;
        }

        h2 span { 
            color: var(--brand-orange); 
            text-shadow: 0 0 10px rgba(255, 87, 34, 0.5); 
        }

        .subtitle {
            color: var(--text-gray);
            font-size: 10px;
            letter-spacing: 2px;
            margin-bottom: 35px;
            display: block;
        }

        .input-group { margin-bottom: 25px; text-align: left; }
        
        label { 
            display: block; 
            margin-bottom: 8px; 
            font-size: 0.8em; 
            color: var(--brand-orange); 
            font-weight: bold;
            letter-spacing: 1px;
        }

        input {
            width: 100%;
            padding: 14px;
            border-radius: 8px;
            border: 1px solid #333;
            background: rgba(255, 255, 255, 0.05);
            color: white;
            box-sizing: border-box;
            transition: 0.3s;
        }

        input:focus { 
            outline: none; 
            border-color: var(--brand-orange); 
            background: rgba(255, 255, 255, 0.1);
            box-shadow: 0 0 10px rgba(255, 87, 34, 0.2);
        }

        /* நியோன் பட்டன் */
        .btn-admin {
            width: 100%;
            padding: 15px;
            background: var(--brand-orange);
            border: none;
            border-radius: 8px;
            color: white;
            font-weight: bold;
            cursor: pointer;
            transition: 0.4s;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-top: 10px;
            box-shadow: 0 5px 15px rgba(255, 87, 34, 0.3);
        }

        .btn-admin:hover { 
            background: #ff7043; 
            box-shadow: 0 0 25px rgba(255, 87, 34, 0.5);
            transform: translateY(-2px); 
        }

        .back-link { 
            margin-top: 25px; 
            display: block; 
            color: var(--text-gray); 
            text-decoration: none; 
            font-size: 0.8em; 
            transition: 0.3s;
        }

        .back-link:hover { color: var(--brand-orange); }
    </style>
</head>
<body>

<div class="bg-icons" id="icons"></div>

<div class="login-card">
    <h2>FIT<span>NASE</span></h2>
    <span class="subtitle">ELITE GYM MANAGEMENT SYSTEM</span>

    <form action="Admindashboard.jsp" method="GET">
        <div class="input-group">
            <label><i class="fas fa-user"></i> USERNAME</label>
            <input type="text" name="adminUser" required placeholder="Admin Name">
        </div>
        <div class="input-group">
            <label><i class="fas fa-lock"></i> PASSWORD</label>
            <input type="password" name="adminPass" required placeholder="Password">
        </div>
        <button type="submit" class="btn-admin">Authorize Access</button>
    </form>
    
    <a href="index.jsp" class="back-link">← Back to Main Menu</a>
</div>

<script>
    // பின்னணி ஐகான்களை உருவாக்குதல்
    const container = document.getElementById('icons');
    const iconList = ['fa-dumbbell', 'fa-bolt', 'fa-heart-pulse', 'fa-weight-hanging'];
    
    for (let i = 0; i < 15; i++) {
        const icon = document.createElement('i');
        icon.className = `fas ${iconList[Math.floor(Math.random() * iconList.length)]}`;
        icon.style.left = Math.random() * 100 + "vw";
        icon.style.fontSize = (Math.random() * 20 + 10) + "px";
        icon.style.animationDuration = (Math.random() * 5 + 5) + "s";
        icon.style.animationDelay = (Math.random() * 5) + "s";
        container.appendChild(icon);
    }
</script>

</body>
</html>