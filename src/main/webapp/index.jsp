<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FITNASE | Initialization</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@200;400;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand-orange: #ff5722;
            --black-bg: #050505;
        }

        body {
            font-family: 'Oswald', sans-serif;
            margin: 0;
            height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            background: linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0.85)), url('https://images.unsplash.com/photo-1593079831268-3381b0db4a77?q=80&w=2069&auto=format&fit=crop');
            background-size: cover;
            background-position: center;
            color: white;
            overflow: hidden;
        }

        .bg-icons {
            position: absolute;
            width: 100%; height: 100%;
            z-index: -1;
            overflow: hidden;
        }

        .bg-icons i, .bg-icons span {
            position: absolute;
            color: var(--brand-orange);
            filter: drop-shadow(0 0 5px var(--brand-orange));
            opacity: 0.15;
            animation: floatGym 15s linear infinite;
            bottom: -100px;
        }

        @keyframes floatGym {
            0% { transform: translateY(0) rotate(0deg); opacity: 0; }
            10% { opacity: 0.15; }
            100% { transform: translateY(-115vh) rotate(360deg); opacity: 0; }
        }

        .brand-container {
            text-align: center;
            z-index: 10;
        }

        .brand-logo {
            font-size: 80px;
            color: var(--brand-orange);
            text-shadow: 0 0 30px rgba(255, 87, 34, 0.5);
            margin-bottom: 20px;
            animation: pulseLogo 2s ease-in-out infinite;
        }

        h1 {
            letter-spacing: 15px;
            text-transform: uppercase;
            font-weight: 200;
            margin: 0;
            animation: fadeIn 2s ease-in;
        }
        
        h1 span {
            color: var(--brand-orange);
            font-weight: 700;
        }

        .loading-wrapper {
            width: 300px;
            margin-top: 50px;
            text-align: center;
        }

        .status-text {
            font-size: 11px;
            letter-spacing: 2px;
            color: var(--brand-orange);
            text-transform: uppercase;
            margin-bottom: 12px;
            height: 15px;
            font-weight: 400;
        }

        .progress-container {
            width: 100%;
            height: 3px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            overflow: hidden;
            position: relative;
        }

        .progress-bar {
            width: 0%;
            height: 100%;
            background: var(--brand-orange);
            box-shadow: 0 0 15px var(--brand-orange);
            transition: width 0.4s ease;
        }

        @keyframes pulseLogo {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.08); opacity: 0.9; }
        }

        @keyframes fadeIn {
            from { opacity: 0; letter-spacing: 5px; }
            to { opacity: 1; letter-spacing: 15px; }
        }
    </style>
</head>
<body>

    <div class="bg-icons"></div>

    <div class="brand-container">
        <div class="brand-logo">
            <i class="fas fa-bolt"></i>
        </div>
        <h1>FIT<span>NASE</span></h1>
        
        <div class="loading-wrapper">
            <div class="status-text" id="status">INITIALIZING SYSTEM...</div>
            <div class="progress-container">
                <div class="progress-bar" id="progress"></div>
            </div>
        </div>
    </div>

    <script>
        function createFitnessElements() {
            const container = document.querySelector('.bg-icons');
            const icons = ['fa-dumbbell', 'fa-weight-hanging', 'fa-bolt'];
            const emojis = ['💪', '🏆', '🔥'];
            for (let i = 0; i < 20; i++) {
                const isEmoji = Math.random() > 0.5;
                const element = document.createElement(isEmoji ? 'span' : 'i');
                if (isEmoji) { element.innerText = emojis[Math.floor(Math.random() * emojis.length)]; }
                else { element.className = `fas ${icons[Math.floor(Math.random() * icons.length)]}`; }
                element.style.left = Math.random() * 100 + "vw";
                element.style.animationDuration = (Math.random() * 8 + 10) + "s";
                element.style.animationDelay = (Math.random() * 5) + "s";
                container.appendChild(element);
            }
        }
        createFitnessElements();

        const statusText = document.getElementById('status');
        const progressBar = document.getElementById('progress');
        const messages = [
            "CONNECTING TO CORE...",
            "LOADING ELITE PROFILES...",
            "SECURING GYM ACCESS...",
            "BOOTING INTERFACE..."
        ];

        let step = 0;
        let progress = 0;

        const interval = setInterval(() => {
            progress += Math.random() * 12;
            if (progress > 100) progress = 100;
            
            progressBar.style.width = progress + "%";

            if (progress >= (step + 1) * 25 && step < messages.length) {
                statusText.innerText = messages[step];
                step++;
            }

            if (progress >= 100) {
                clearInterval(interval);
                setTimeout(() => {
                    // Edited route: Shifted destination target safely from registration screen to your updated gateway portal
                    window.location.href = "login.jsp";
                }, 600);
            }
        }, 300);
    </script>
</body>
</html>