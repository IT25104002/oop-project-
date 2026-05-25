<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>

<%
    // --- INTEGRATION POINT: FILE PATH ---
    // This looks for 'feedback.txt' two levels up from the web app root.
    // Adjust this path if your team lead tells you to save it elsewhere.
    String feedbackPath = application.getRealPath("/") + "../../feedback.txt";

    String action = request.getParameter("action");
    if ("submitFeedback".equals(action)) {
        try {
            String name = request.getParameter("f-name");
            String rating = request.getParameter("f-rating");
            String category = request.getParameter("f-category");
            String comment = request.getParameter("f-comment");

            String timestamp = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm").format(LocalDateTime.now());

            // Formatting the data for the text file (CSV-style)
            String entry = timestamp + "|" + name + "|" + rating + "|" + category + "|" + comment + "\n";

            File file = new File(feedbackPath);
            BufferedWriter bw = new BufferedWriter(new FileWriter(file, true));
            bw.write(entry);
            bw.close();

            out.println("<script>alert('Feedback Saved Successfully!'); window.location='Feedback.jsp';</script>");
        } catch (Exception e) {
            out.println("<script>alert('Error: " + e.getMessage() + "');</script>");
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Elite Gym | Feedback Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --brand-orange: #ff5722;
            --dark-bg: #0f0f0f;
            --card-bg: #1a1a1a;
            --glow-orange: rgba(255, 87, 34, 0.4);
        }

        body {
            font-family: 'Oswald', sans-serif;
            background-color: var(--dark-bg);
            color: white;
            margin: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            min-height: 100vh;
        }

        /* Matches Dashboard Header Theme */
        .header-mock {
            width: 100%;
            background: #000;
            padding: 20px 50px;
            border-bottom: 2px solid var(--brand-orange);
            text-align: center;
            box-sizing: border-box;
        }

        .logo { font-size: 1.5rem; font-weight: bold; color: white; text-decoration: none; }
        .logo span { color: var(--brand-orange); }

        .container {
            margin-top: 50px;
            background: linear-gradient(145deg, #1a1a1a, #111111);
            padding: 40px;
            width: 90%;
            max-width: 600px;
            border-radius: 15px;
            border: 1px solid #333;
            box-shadow: 0 20px 50px rgba(0,0,0,0.5);
        }

        h2 { color: var(--brand-orange); letter-spacing: 2px; text-transform: uppercase; }

        .input-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-size: 0.8rem; color: #bbb; }

        input, select, textarea {
            width: 100%;
            padding: 12px;
            background: #000;
            border: 1px solid #444;
            color: white;
            border-radius: 5px;
            font-family: inherit;
        }

        input:focus, textarea:focus {
            border-color: var(--brand-orange);
            outline: none;
            box-shadow: 0 0 10px var(--glow-orange);
        }

        .submit-btn {
            background: var(--brand-orange);
            color: white;
            padding: 15px;
            border: none;
            width: 100%;
            font-weight: bold;
            cursor: pointer;
            text-transform: uppercase;
            transition: 0.3s;
        }

        .submit-btn:hover {
            transform: scale(1.02);
            box-shadow: 0 0 20px var(--glow-orange);
        }
    </style>
</head>
<body>

    <div class="header-mock">
        <div class="logo">FIT<span>NASE</span> FEEDBACK</div>
    </div>

    <div class="container">
        <h2>Submit Experience</h2>
        <form action="Feedback.jsp" method="POST">
            <input type="hidden" name="action" value="submitFeedback">

            <div class="input-group">
                <label>MEMBER NAME</label>
                <input type="text" name="f-name" required placeholder="John Doe">
            </div>

            <div class="input-group">
                <label>RATING</label>
                <select name="f-rating">
                    <option value="5">⭐⭐⭐⭐⭐ (Excellent)</option>
                    <option value="4">⭐⭐⭐⭐ (Very Good)</option>
                    <option value="3">⭐⭐⭐ (Average)</option>
                    <option value="2">⭐⭐ (Below Average)</option>
                    <option value="1">⭐ (Poor)</option>
                </select>
            </div>

            <div class="input-group">
                <label>CATEGORY</label>
                <select name="f-category">
                    <option value="Equipment">Equipment</option>
                    <option value="Cleanliness">Cleanliness</option>
                    <option value="Staff">Staff/Trainers</option>
                    <option value="App">Mobile App/Web</option>
                </select>
            </div>

            <div class="input-group">
                <label>COMMENTS</label>
                <textarea name="f-comment" rows="4" placeholder="How can we improve?"></textarea>
            </div>

            <button type="submit" class="submit-btn">Send Feedback</button>
        </form>
    </div>

</body>
</html>