<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.util.*, java.text.SimpleDateFormat" %>
<%
    String targetMemberId = request.getParameter("memberId");
    String chosenPlan = request.getParameter("plan");
    String amountPaid = request.getParameter("amount");

    if (targetMemberId == null || targetMemberId.trim().isEmpty()) {
        targetMemberId = (String) session.getAttribute("memberId");
    }
    if (chosenPlan == null || chosenPlan.trim().isEmpty()) {
        chosenPlan = "Bronze";
    }
    if (amountPaid == null || amountPaid.trim().isEmpty()) {
        amountPaid = "0";
    }

    boolean loggedToPending = false;
    String errorFeedback = "";
    String transactionId = "TXN-" + System.currentTimeMillis() / 1000;
    String timestamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());

    if (targetMemberId != null && !targetMemberId.trim().isEmpty()) {
        targetMemberId = targetMemberId.trim();
        chosenPlan = chosenPlan.trim().toUpperCase();
        amountPaid = amountPaid.trim();

        String baseDir = application.getRealPath("/");
        File dataDir = new File(baseDir + "webappdata");
        if (!dataDir.exists()) { dataDir.mkdirs(); }
        File paymentsFile = new File(dataDir, "payments.txt");

        try (BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(paymentsFile, true), "UTF-8"))) {
            // Layout fields mapped safely: TxnID, MemberID, Date, Amount, ChosenPlan, Status
            String row = transactionId + "," + targetMemberId + "," + timestamp + "," + amountPaid + "," + chosenPlan + ",PENDING";
            writer.write(row);
            writer.newLine();
            writer.flush();
            loggedToPending = true;
        } catch (Exception e) {
            errorFeedback = e.getMessage();
            loggedToPending = false;
        }
    } else {
        errorFeedback = "Invalid user registration metadata payload transmission.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FITNASE | Order Verification Window</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&family=Oswald:wght@500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --brand-orange: #ff5722;
            --brand-glow: rgba(255, 87, 34, 0.35);
            --card-glass: rgba(20, 20, 20, 0.9);
            --text-gray: #bbbbbb;
        }
        body { 
            margin: 0; background: linear-gradient(rgba(0,0,0,0.85), rgba(0,0,0,0.85)), url('https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=1350&q=80'); 
            background-size: cover; background-position: center; background-attachment: fixed;
            color: white; font-family: 'Poppins', sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; 
        }
        .success-card { 
            background: var(--card-glass); backdrop-filter: blur(10px); padding: 50px 40px; border-radius: 4px; 
            width: 500px; text-align: center; border: 1px solid rgba(255, 87, 34, 0.2); box-shadow: 0 20px 50px rgba(0,0,0,0.8); box-sizing: border-box;
        }
        .icon-pending { font-size: 4rem; color: #ffb300; text-shadow: 0 0 20px rgba(255,179,0,0.4); margin-bottom: 20px; }
        .icon-error { font-size: 4rem; color: #ff4444; text-shadow: 0 0 20px rgba(255, 68, 68, 0.4); margin-bottom: 20px; }
        h2 { font-family: 'Oswald', sans-serif; font-size: 2.2rem; letter-spacing: 2px; margin: 0 0 10px 0; text-transform: uppercase; }
        h2 span { color: var(--brand-orange); }
        p { color: var(--text-gray); font-size: 0.95rem; line-height: 1.6; margin: 0 0 30px 0; }
        .invoice-details { background: rgba(0, 0, 0, 0.4); border: 1px solid #222; padding: 20px; border-radius: 2px; text-align: left; margin-bottom: 35px; }
        .invoice-row { display: flex; justify-content: space-between; padding: 8px 0; font-size: 0.85rem; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .invoice-row:last-child { border: none; }
        .invoice-row span { color: #888; text-transform: uppercase; letter-spacing: 0.5px; }
        .invoice-row b { color: white; }
        .btn-hub { 
            display: inline-block; width: 100%; padding: 15px; background: var(--brand-orange); border: none; color: white; text-decoration: none;
            font-family: 'Oswald', sans-serif; font-size: 1.1rem; letter-spacing: 1px; font-weight: bold; border-radius: 2px; transition: 0.3s; text-transform: uppercase; box-sizing: border-box;
        }
        .btn-hub:hover { background: #e64a19; box-shadow: 0 0 20px var(--brand-glow); }
    </style>
</head>
<body>
    <div class="success-card">
        <% if (loggedToPending) { %>
            <div class="icon-pending"><i class="fas fa-history"></i></div>
            <h2>PAYMENT <span>PENDING</span></h2>
            <p>Your payment registration was submitted successfully. Access will unlock as soon as an administrator verifies the receipt ledger entry.</p>

            <div class="invoice-details">
                <div class="invoice-row"><span>Receipt Order ID</span><b><%= transactionId %></b></div>
                <div class="invoice-row"><span>Account Target ID</span><b><%= targetMemberId %></b></div>
                <div class="invoice-row"><span>Requested Plan</span><b style="color:var(--brand-orange);"><%= chosenPlan %></b></div>
                <div class="invoice-row"><span>Total Amount</span><b>Rs. <%= amountPaid %></b></div>
                <div class="invoice-row"><span>Pipeline Status</span><b style="color: #ffb300;">AWAITING ADMIN APPROVAL</b></div>
            </div>
            
            <a href="Dashboard.jsp" class="btn-hub">Return To Hub Terminal</a>
        <% } else { %>
            <div class="icon-error"><i class="fas fa-exclamation-triangle"></i></div>
            <h2>ROUTING <span>ERROR</span></h2>
            <p>The transaction could not be written down to the payment flat-file verification ledger layer.</p>

            <div class="invoice-details">
                <div class="invoice-row"><span>Diagnostic Stack</span><b style="color: #ff4444;"><%= errorFeedback.isEmpty() ? "I/O Stream Interrupted" : errorFeedback %></b></div>
            </div>
            
            <a href="plan-selection.jsp" class="btn-hub" style="background: #333; border: 1px solid #444;">Retry Order Generation</a>
        <% } %>
    </div>
</body>
</html>