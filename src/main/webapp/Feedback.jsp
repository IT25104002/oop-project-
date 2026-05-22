<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter, java.util.*" %>
<%
    String baseDir = application.getRealPath("/");
    File dataDir = new File(baseDir + "webappdata");
    if (!dataDir.exists()) { dataDir.mkdirs(); }
    File feedbackFile = new File(dataDir, "feedback.txt");
    File repliesFile = new File(dataDir, "replies.txt");

    String currentUser = "liza fox"; // Simulating current user log profile

    // Handle Form submission
    String action = request.getParameter("action");
    if ("submitFeedback".equals(action)) {
        try {
            String name = request.getParameter("f-name");
            String rating = request.getParameter("f-rating");
            String category = request.getParameter("f-category");
            String comment = request.getParameter("f-comment");
            String timestamp = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm").format(LocalDateTime.now());

            String entry = timestamp + "|" + name + "|" + rating + "|" + category + "|" + comment;
            try (BufferedWriter bw = new BufferedWriter(new FileWriter(feedbackFile, true))) {
                bw.write(entry); bw.newLine(); bw.flush();
            }
            out.println("<script>alert('Feedback Saved Successfully!'); window.location='Feedback.jsp';</script>");
        } catch (Exception e) {}
    }

    // --- CHECK FOR REPLIES FROM ADMIN LOGS ---
    List<String> adminMessages = new ArrayList<>();
    if (repliesFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(repliesFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split("\\|");
                if (parts.length >= 3 && parts[0].trim().equalsIgnoreCase(currentUser)) {
                    adminMessages.add(parts[2]); // Collect the admin responses
                }
            }
        } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Elite Gym | Feedback Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;600;700&family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        :root { --brand-orange: #ff5722; --dark-bg: #0f0f0f; --card-bg: #1a1a1a; --glow-orange: rgba(255, 87, 34, 0.4); }
        body { font-family: 'Poppins', sans-serif; background-color: var(--dark-bg); color: white; margin: 0; display: flex; flex-direction: column; align-items: center; min-height: 100vh; }
        .header-mock { width: 100%; background: #000; padding: 20px 50px; border-bottom: 2px solid var(--brand-orange); display: flex; justify-content: space-between; align-items: center; box-sizing: border-box; }
        .logo { font-family: 'Oswald', sans-serif; font-size: 1.5rem; color: white; text-decoration: none; }
        .logo span { color: var(--brand-orange); }
        .back-home-btn { background: transparent; color: white; border: 1px solid #444; padding: 8px 16px; text-decoration: none; font-family: 'Oswald', sans-serif; text-transform: uppercase; }
        .container { margin-top: 30px; margin-bottom: 50px; background: linear-gradient(145deg, #1a1a1a, #111111); padding: 40px; width: 90%; max-width: 600px; border-radius: 4px; border: 1px solid rgba(255, 87, 34, 0.15); box-shadow: 0 20px 50px rgba(0,0,0,0.5); }
        h2 { font-family: 'Oswald', sans-serif; color: var(--brand-orange); letter-spacing: 2px; text-transform: uppercase; margin-top: 0; }
        
        /* NEW: Notification Pop-in Inbox Box Style */
        .notification-popin {
            background: rgba(255, 87, 34, 0.08);
            border: 1px solid var(--brand-orange);
            padding: 15px 20px;
            border-radius: 4px;
            margin-bottom: 25px;
            box-shadow: 0 0 15px rgba(255, 87, 34, 0.15);
        }
        .popin-title {
            font-family: 'Oswald', sans-serif;
            color: var(--brand-orange);
            font-size: 1rem;
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            gap: 8px;
            letter-spacing: 0.5px;
        }
        .popin-msg { font-size: 0.88rem; color: #e0e0e0; line-height: 1.4; font-style: italic; }

        .input-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-size: 0.8rem; color: #bbb; }
        input, select, textarea { width: 100%; padding: 12px; background: #000; border: 1px solid #333; color: white; box-sizing: border-box; }
        input:focus, select:focus, textarea:focus { border-color: var(--brand-orange); outline: none; box-shadow: 0 0 10px var(--glow-orange); }
        .submit-btn { background: var(--brand-orange); color: white; padding: 15px; border: none; width: 100%; font-family: 'Oswald', sans-serif; font-size: 1.1rem; cursor: pointer; text-transform: uppercase; }
    </style>
</head>
<body>

    <div class="header-mock">
        <a href="Dashboard.jsp" class="logo">FIT<span>NASE</span> FEEDBACK</a>
        <a href="Dashboard.jsp" class="back-home-btn"><i class="fas fa-arrow-left"></i> Hub Terminal</a>
    </div>

    <div class="container">
        
        <% if (!adminMessages.isEmpty()) { 
            for (String msg : adminMessages) { %>
                <div class="notification-popin">
                    <div class="popin-title"><i class="fas fa-bell animate-bounce"></i> Response Message from HQ Desk</div>
                    <div class="popin-msg">"<%= msg %>"</div>
                </div>
        <%  } 
        } %>

        <h2>Submit Experience</h2>
        <form action="Feedback.jsp" method="POST">
            <input type="hidden" name="action" value="submitFeedback">
            <div class="input-group">
                <label>MEMBER NAME</label>
                <input type="text" name="f-name" value="liza fox" readonly required>
            </div>
            <div class="input-group">
                <label>RATING</label>
                <select name="f-rating">
                    <option value="5">⭐⭐⭐⭐⭐ (Excellent)</option>
                    <option value="4">⭐⭐⭐⭐ (Very Good)</option>
                </select>
            </div>
            <div class="input-group">
                <label>CATEGORY</label>
                <select name="f-category">
                    <option value="Equipment">Equipment</option>
                    <option value="Cleanliness">Cleanliness</option>
                </select>
            </div>
            <div class="input-group">
                <label>COMMENTS</label>
                <textarea name="f-comment" rows="4" placeholder="How can we improve?"></textarea>
            </div>
            <button type="submit" class="submit-btn">Send Feedback Matrix</button>
        </form>
    </div>

</body>
</html>