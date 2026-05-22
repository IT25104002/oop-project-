<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.util.*" %>
<%
    String baseDir = application.getRealPath("/");
    File dataDir = new File(baseDir + "webappdata"); 
    File feedbackFile = new File(dataDir, "feedback.txt");
    File repliesFile = new File(dataDir, "replies.txt");

    // Handle the Dispatch Action save
    String action = request.getParameter("adminAction");
    if ("dispatchReply".equals(action)) {
        String targetUser = request.getParameter("targetUser");
        String category = request.getParameter("category");
        String messageSnippet = request.getParameter("messageSnippet");
        
        // Format: Username | Category | Reply Message
        String replyEntry = targetUser + "|" + category + "|Our administration floor has processed your request about " + category + " ('" + messageSnippet + "'). We are taking immediate steps to resolve it!";
        
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(repliesFile, true))) {
            bw.write(replyEntry);
            bw.newLine();
            bw.flush();
        } catch(Exception e) {}
        
        out.println("<script>alert('Message dispatched and posted to " + targetUser + "\'s portal dashboard!'); window.location='admin-feedback.jsp';</script>");
    }

    List<String[]> feedbackEntries = new ArrayList<>();
    if (feedbackFile.exists()) {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(feedbackFile), "UTF-8"))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split("\\|"); 
                feedbackEntries.add(parts);
            }
        } catch (Exception e) {}
    }
    Collections.reverse(feedbackEntries);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FITNASE | Athlete Feedback Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&family=Oswald:wght@500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --brand-orange: #ff5722; --card-glass: rgba(18, 18, 18, 0.96); --text-secondary: #999999; }
        body { margin: 0; background: linear-gradient(rgba(0,0,0,0.85), rgba(0,0,0,0.85)), url('https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1350&q=80'); background-size: cover; background-attachment: fixed; color: #ffffff; font-family: 'Poppins', sans-serif; padding: 40px 20px; }
        .container { max-width: 950px; margin: 0 auto; background: var(--card-glass); border: 1px solid rgba(255, 87, 34, 0.15); padding: 45px; border-radius: 6px; border-top: 4px solid var(--brand-orange); box-shadow: 0 20px 50px rgba(0,0,0,0.8); }
        h1 { font-family: 'Oswald', sans-serif; text-transform: uppercase; letter-spacing: 1.5px; font-size: 2.4rem; margin: 0 0 5px 0; }
        h1 span { color: var(--brand-orange); }
        .subtitle { color: var(--text-secondary); font-size: 0.9rem; margin-bottom: 40px; text-transform: uppercase; letter-spacing: 1px; border-bottom: 1px solid rgba(255, 255, 255, 0.08); padding-bottom: 15px; }
        .feedback-list { display: flex; flex-direction: column; gap: 30px; }
        .feedback-card { background: #1a1a1a; border: 1px solid rgba(255, 255, 255, 0.08); padding: 25px; border-radius: 6px; }
        .card-top-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; }
        .user-info { display: flex; align-items: center; gap: 12px; }
        .avatar-icon { font-size: 2.2rem; color: var(--brand-orange); }
        .username { font-family: 'Oswald', sans-serif; font-size: 1.25rem; text-transform: uppercase; margin: 0; }
        .timestamp { color: var(--text-secondary); font-size: 0.8rem; }
        .badge { padding: 5px 12px; border-radius: 4px; font-weight: 600; font-size: 0.75rem; text-transform: uppercase; }
        .badge.category { background: rgba(255, 255, 255, 0.05); color: #ffffff; border: 1px solid rgba(255, 255, 255, 0.15); }
        .message-body { background: #111111; padding: 18px 20px; border-radius: 4px; border-left: 3px solid var(--brand-orange); color: #eeeeee; font-size: 0.95rem; margin-bottom: 20px; }
        .auto-reply-box { background: rgba(255, 87, 34, 0.02); border: 1px solid rgba(255, 87, 34, 0.08); padding: 20px; border-radius: 4px; }
        .reply-header { font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: var(--text-secondary); margin-bottom: 12px; display: flex; align-items: center; gap: 6px; }
        .email-template { font-size: 0.85rem; color: #a5d6a7; background: rgba(76, 175, 80, 0.04); padding: 15px; border-radius: 4px; border: 1px dashed rgba(76, 175, 80, 0.2); margin-bottom: 15px; }
        .action-button { background: var(--brand-orange); color: #ffffff; border: none; font-family: 'Oswald', sans-serif; font-size: 0.8rem; text-transform: uppercase; padding: 8px 18px; border-radius: 3px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; }
        .back-link { display: inline-flex; align-items: center; gap: 8px; margin-bottom: 25px; color: var(--brand-orange); text-decoration: none; font-family: 'Oswald', sans-serif; font-size: 0.9rem; text-transform: uppercase; }
    </style>
</head>
<body>
    <div class="container">
        <a href="admin-dashboard.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Return to Terminal Hub</a>
        <h1>Athlete Feedback <span>Intelligence</span></h1>
        <p class="subtitle">Review and interact with verified system log profiles recorded from facility users.</p>
        
        <div class="feedback-list">
            <% for (String[] record : feedbackEntries) { 
                String timestampStr = (record.length > 0) ? record[0].trim() : "N/A";
                String memberName   = (record.length > 1) ? record[1].trim() : "ANONYMOUS";
                String ratingVal    = (record.length > 2) ? record[2].trim() : "5";
                String categoryTag  = (record.length > 3) ? record[3].trim() : "GENERAL";
                String actualMessage = (record.length > 4) ? record[4].trim() : "";
            %>
                <div class="feedback-card">
                    <div class="card-top-row">
                        <div class="user-info">
                            <i class="fas fa-user-circle avatar-icon"></i>
                            <div>
                                <div class="username"><%= memberName %></div>
                                <div class="timestamp"><i class="far fa-clock"></i> <%= timestampStr %></div>
                            </div>
                        </div>
                        <span class="badge category"><%= categoryTag %></span>
                    </div>
                    <div class="message-body">"<%= actualMessage %>"</div>

                    <div class="auto-reply-box">
                        <span class="reply-header"><i class="fas fa-reply-all"></i> Dispatch Action Module</span>
                        <div class="email-template">
                            <strong>To User:</strong> <%= memberName %><br>
                            <strong>Broadcast Message:</strong> Action token will update this athlete's layout regarding their <strong><%= categoryTag %></strong> ticket note.
                        </div>
                        <form action="admin-feedback.jsp" method="POST">
                            <input type="hidden" name="adminAction" value="dispatchReply">
                            <input type="hidden" name="targetUser" value="<%= memberName %>">
                            <input type="hidden" name="category" value="<%= categoryTag %>">
                            <input type="hidden" name="messageSnippet" value="<%= actualMessage.length() > 20 ? actualMessage.substring(0,20)+"..." : actualMessage %>">
                            <button type="submit" class="action-button">
                                <i class="fas fa-paper-plane"></i> Dispatch to User Dashboard
                            </button>
                        </form>
                    </div>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>