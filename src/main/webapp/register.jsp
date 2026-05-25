<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*" %>
<%
    String action = request.getParameter("action");
    if ("register".equals(action)) {
        String name = request.getParameter("name");
        String pass = request.getParameter("pass");
        String phone = request.getParameter("phone");            
        String age = request.getParameter("age");                
        String packageTier = "Bronze"; 

        if (name != null && pass != null) {
            name = name.trim();
            pass = pass.trim();
            phone = (phone != null && !phone.isEmpty()) ? phone.trim() : "0000000000";
            age = (age != null && !age.isEmpty()) ? age.trim() : "25";

            // ✅ RUNTIME PATH STABILIZATION MATRIX
            String baseDir = application.getRealPath("/");
            File webappdataFolder = new File(baseDir + File.separator + "webappdata");
            if (!webappdataFolder.exists()) {
                webappdataFolder.mkdirs();
            }
            File memberFile = new File(webappdataFolder, "members.txt");

            int nextIdNum = 101; 
            if (memberFile.exists()) {
                try (BufferedReader br = new BufferedReader(new FileReader(memberFile))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        if (line.trim().isEmpty()) continue;
                        String[] parts = line.split(",");
                        if (parts.length > 0 && parts[0].startsWith("MEM-")) {
                            try {
                                int currentId = Integer.parseInt(parts[0].substring(4).trim());
                                if (currentId >= nextIdNum) { nextIdNum = currentId + 1; }
                            } catch (NumberFormatException e) { }
                        }
                    }
                } catch (IOException e) { }
            }
            String generatedId = "MEM-" + nextIdNum;

            // Database Matrix Structure formatting standard: 
            // ID, Password, Name, Status, Weight, Height, Goal, Phone, Package, Expiry
            String defaultRow = generatedId + "," + pass + "," + name + ",ACTIVE MEMBER,70,175,Weight Loss," + phone + "," + packageTier + ",2027-01-01";
            
            try (BufferedWriter bw = new BufferedWriter(new FileWriter(memberFile, true))) {
                bw.write(defaultRow);
                bw.newLine();
                bw.flush();
                
                out.println("<script>");
                out.println("alert('Profile Created Successfully!\\n\\nYOUR UNIQUE FITNASE SECURE ID IS: " + generatedId + "\\nUse this generated sequence to authorize access into your dashboard terminal.');");
                out.println("window.location.href='login.jsp';");
                out.println("</script>");
                return;
            } catch (IOException e) {
                out.println("<script>alert('System Storage Exception: " + e.getMessage() + "');</script>");
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FITNASE | Create Athlete Profile</title>
    <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;700&family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand-orange: #ff5722;
            --card-gray: rgba(12, 12, 12, 0.96);
            --input-bg: #000;
            --text-gray: #a0a0a0;
        }
        body {
            font-family: 'Poppins', sans-serif; margin: 0; min-height: 100vh; display: flex; justify-content: center; align-items: center;
            background: linear-gradient(rgba(0,0,0,0.85), rgba(0,0,0,0.7)), url('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1350&q=80');
            background-size: cover; background-position: center; padding: 20px; box-sizing: border-box;
        }
        .reg-card { background: var(--card-gray); padding: 45px 40px; border-radius: 8px; box-shadow: 0 15px 50px rgba(0,0,0,0.8); width: 100%; max-width: 460px; border-top: 4px solid var(--brand-orange); }
        h2 { font-family: 'Oswald', sans-serif; color: white; margin: 0; font-size: 2.2rem; letter-spacing: 3px; text-transform: uppercase; text-align: center; }
        h2 span { color: var(--brand-orange); }
        .subtitle { color: var(--text-gray); font-size: 11px; letter-spacing: 2px; text-align: center; margin-bottom: 35px; text-transform: uppercase; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .form-group { margin-bottom: 22px; text-align: left; }
        .full-width { grid-column: span 2; }
        label { color: var(--brand-orange); font-family: 'Oswald', sans-serif; font-size: 0.8rem; letter-spacing: 1px; display: block; margin-bottom: 8px; text-transform: uppercase; }
        input { width: 100%; padding: 12px 14px; background: var(--input-bg); border: 1px solid #222; border-radius: 4px; color: white; box-sizing: border-box; transition: 0.3s; font-family: inherit; }
        input:focus { outline: none; border-color: var(--brand-orange); background: #0f0f0f; }
        button { width: 100%; padding: 14px; background: var(--brand-orange); color: white; border: none; border-radius: 4px; font-family: 'Oswald', sans-serif; font-size: 1.1rem; text-transform: uppercase; letter-spacing: 2px; cursor: pointer; transition: 0.3s; margin-top: 15px; font-weight: bold; }
        button:hover { background: #e64a19; box-shadow: 0 0 20px rgba(255, 87, 34, 0.4); transform: translateY(-1px); }
        .footer-link { text-align: center; margin-top: 25px; font-size: 0.85rem; color: var(--text-gray); }
        .footer-link a { color: var(--brand-orange); text-decoration: none; font-weight: 600; }
    </style>
</head>
<body>
    <div class="reg-card">
        <h2>FIT<span>NASE</span></h2>
        <div class="subtitle">Create Your Athlete Profile</div>
        <form action="register.jsp" method="POST">
            <input type="hidden" name="action" value="register">
            <div class="form-row">
                <div class="form-group full-width">
                    <label>Full Name</label>
                    <input type="text" name="name" placeholder="Tharu Kulasekara" required autocomplete="off">
                </div>
                <div class="form-group full-width">
                    <label>Security Password</label>
                    <input type="password" name="pass" placeholder="••••••••" required>
                </div>
                <div class="form-group">
                    <label>Age</label>
                    <input type="number" name="age" placeholder="23" min="12" max="100" required>
                </div>
                <div class="form-group">
                    <label>Mobile Number</label>
                    <input type="text" name="phone" placeholder="0753883167" required>
                </div>
            </div>
            <button type="submit">Complete Profile Registration</button>
        </form>
        <div class="footer-link">Already registered? <a href="login.jsp">Authorize Entrance Here</a></div>
    </div>
</body>
</html>