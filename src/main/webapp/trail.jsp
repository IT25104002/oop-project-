<style>
    :root {
        --brand-orange: #ff5722;
        --accent-soft: rgba(255, 87, 34, 0.3);
        --black-bg: #0a0a0a;
    }

    body {
        font-family: 'Oswald', sans-serif;
        margin: 0;
        height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        background-color: var(--black-bg);
        background-image: 
            radial-gradient(circle at center, #1a1a1a 0%, #050505 100%),
            linear-gradient(rgba(255, 87, 34, 0.02) 1px, transparent 1px),
            linear-gradient(90deg, rgba(255, 87, 34, 0.02) 1px, transparent 1px);
        background-size: 100% 100%, 30px 30px, 30px 30px;
        color: white;
        overflow: hidden;
    }

    /* Professional "Atmosphere" - A soft pulsing glow in the center */
    body::before {
        content: "";
        position: absolute;
        width: 400px;
        height: 400px;
        background: var(--brand-orange);
        filter: blur(150px);
        opacity: 0.1;
        border-radius: 50%;
        animation: atmosphere 8s ease-in-out infinite;
    }

    @keyframes atmosphere {
        0%, 100% { transform: scale(1); opacity: 0.08; }
        50% { transform: scale(1.3); opacity: 0.15; }
    }

    .container {
        position: relative;
        text-align: center;
        z-index: 10;
    }

    /* Kinetic Typography: Letters breath */
    h1 {
        font-size: 3.5rem;
        letter-spacing: 20px;
        text-transform: uppercase;
        font-weight: 200;
        margin: 0;
        color: #fff;
        display: flex;
        justify-content: center;
        padding-left: 20px; /* Offset for letter spacing */
        animation: tracking-in-expand 1.5s cubic-bezier(0.215, 0.610, 0.355, 1.000) both;
    }

    h1 span {
        color: var(--brand-orange);
        font-weight: 700;
        transition: 0.5s;
    }

    /* Refined Loading Bar */
    .loader-container {
        margin-top: 40px;
        width: 320px;
        position: relative;
    }

    .meta-data {
        display: flex;
        justify-content: space-between;
        font-family: monospace;
        font-size: 10px;
        color: var(--brand-orange);
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 8px;
        opacity: 0.8;
    }

    .progress-track {
        height: 2px;
        width: 100%;
        background: rgba(255, 255, 255, 0.05);
        border-radius: 4px;
        overflow: hidden;
        position: relative;
    }

    .progress-fill {
        height: 100%;
        width: 0%;
        background: linear-gradient(90deg, transparent, var(--brand-orange));
        box-shadow: 0 0 10px var(--brand-orange);
        position: relative;
        transition: width 0.3s ease;
    }

    /* Geometric Decoration */
    .bolt-icon {
        font-size: 2rem;
        color: var(--brand-orange);
        margin-bottom: 15px;
        animation: bolt-entry 1s ease-out forwards;
    }

    @keyframes tracking-in-expand {
        0% { letter-spacing: -0.5em; opacity: 0; }
        40% { opacity: 0.6; }
        100% { opacity: 1; }
    }

    @keyframes bolt-entry {
        0% { transform: translateY(-20px) scale(0); opacity: 0; }
        60% { transform: translateY(5px) scale(1.2); }
        100% { transform: translateY(0) scale(1); opacity: 1; }
    }
</style>

<body>

    <div class="container">
        <div class="bolt-icon">
            <i class="fas fa-bolt"></i>
        </div>
        
        <h1 id="main-title">FIT<span>NASE</span></h1>

        <div class="loader-container">
            <div class="meta-data">
                <span id="status-msg">Initializing...</span>
                <span id="percent-val">00%</span>
            </div>
            <div class="progress-track">
                <div class="progress-fill" id="fill"></div>
            </div>
        </div>
    </div>

    <script>
        const statusMsg = document.getElementById('status-msg');
        const percentVal = document.getElementById('percent-val');
        const fill = document.getElementById('fill');

        const phrases = [
            "Synchronizing Core...",
            "Loading Neural Assets...",
            "Encrypting Session...",
            "Optimization Complete"
        ];

        let progress = 0;
        
        // Professional Scramble Effect
        function scrambleText(text, element) {
            const chars = '!<>-_\\/[]{}—=+*^?#________';
            let iteration = 0;
            const interval = setInterval(() => {
                element.innerText = text.split("")
                    .map((char, index) => {
                        if(index < iteration) return text[index];
                        return chars[Math.floor(Math.random() * chars.length)];
                    })
                    .join("");
                
                if(iteration >= text.length) clearInterval(interval);
                iteration += 1 / 3;
            }, 30);
        }

        const loadingSimulation = setInterval(() => {
            progress += Math.floor(Math.random() * 5) + 1;
            
            if (progress > 100) progress = 100;
            
            fill.style.width = progress + "%";
            percentVal.innerText = progress.toString().padStart(2, '0') + "%";

            // Change text at specific milestones
            if (progress === 25) scrambleText(phrases[0], statusMsg);
            if (progress === 50) scrambleText(phrases[1], statusMsg);
            if (progress === 75) scrambleText(phrases[2], statusMsg);
            if (progress === 95) scrambleText(phrases[3], statusMsg);

            if (progress >= 100) {
                clearInterval(loadingSimulation);
                setTimeout(finalize, 500);
            }
        }, 120);

        function finalize() {
            // Smooth professional exit
            document.querySelector('.container').style.transition = "all 0.8s cubic-bezier(0.645, 0.045, 0.355, 1)";
            document.querySelector('.container').style.opacity = "0";
            document.querySelector('.container').style.transform = "translateY(-20px)";
            
            setTimeout(() => {
                window.location.href = "login.html";
            }, 800);
        }
    </script>
</body>