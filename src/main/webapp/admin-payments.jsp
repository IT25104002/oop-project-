<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.util.*" %>
<%
    // Pointing directly to the active webappdata directory visible in your file structure
    String baseDir = application.getRealPath("/");
    File dataDir = new File(baseDir + "webappdata"); 
    File paymentsFile = new File(dataDir, "payments.txt");
    File membersFile = new File(dataDir, "members.txt");

    String reqAction = request.getParameter("action");
    String targetTxnId = request.getParameter("txnId");

    if (reqAction != null && targetTxnId != null) {
        targetTxnId = targetTxnId.trim();
        List<String> paymentLines = new ArrayList<>();
        String associatedMemberId = "";
        String designatedPlan = "";
        boolean txnStateChanged = false;

        if (paymentsFile.exists()) {
            try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(paymentsFile), "UTF-8"))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] parts = line.split(",");
                    
                    // Filter lines that do not match transaction criteria safely
                    if (parts.length >= 6 && parts[0].trim().equalsIgnoreCase(targetTxnId)) {
                        if ("approve".equalsIgnoreCase(reqAction)) {
                            parts[5] = "APPROVED";
                            associatedMemberId = parts[1].trim();
                            designatedPlan = parts[4].trim().toUpperCase();
                            txnStateChanged = true;
                        } else if ("reject".equalsIgnoreCase(reqAction)) {
                            parts[5] = "REJECTED";
                            txnStateChanged = true;
                        }
                        StringBuilder updatedRow = new StringBuilder();
                        for (int i = 0; i < parts.length; i++) {
                            updatedRow.append(parts[i].trim()).append(i < parts.length - 1 ? "," : "");
                        }
                        paymentLines.add(updatedRow.toString());
                    } else {
                        paymentLines.add(line);
                    }
                }
            } catch (Exception e) {}
        }

        if (txnStateChanged) {
            try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(paymentsFile, false), "UTF-8"))) {
                for (String pLine : paymentLines) { bw.write(pLine); bw.newLine(); }
                bw.flush();
            } catch (Exception e) {}

            // Multi-Index Upgrader logic updating indices 5 and 8
            if ("approve".equalsIgnoreCase(reqAction) && !associatedMemberId.isEmpty()) {
                List<String> memberLines = new ArrayList<>();
                if (membersFile.exists()) {
                    try (BufferedReader mbrReader = new BufferedReader(new InputStreamReader(new FileInputStream(membersFile), "UTF-8"))) {
                        String line;
                        while ((line = mbrReader.readLine()) != null) {
                            if (line.trim().isEmpty()) continue;
                            String[] mParts = line.split(",");
                            if (mParts.length >= 1 && mParts[0].trim().equalsIgnoreCase(associatedMemberId)) {
                                
                                if (mParts.length < 6) {
                                    String[] extended = new String[6];
                                    Arrays.fill(extended, "");
                                    System.arraycopy(mParts, 0, extended, 0, mParts.length);
                                    mParts = extended;
                                }
                                
                                if (mParts.length > 5) mParts[5] = designatedPlan; 
                                if (mParts.length > 8) mParts[8] = designatedPlan; 

                                StringBuilder sb = new StringBuilder();
                                for (int i = 0; i < mParts.length; i++) {
                                    sb.append(mParts[i].trim()).append(i < mParts.length - 1 ? "," : "");
                                }
                                memberLines.add(sb.toString());
                            } else {
                                memberLines.add(line);
                            }
                        }
                    } catch (Exception e) {}
                }

                try (BufferedWriter mbrWriter = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(membersFile, false), "UTF-8"))) {
                    for (String mLine : memberLines) { mbrWriter.write(mLine); mbrWriter.newLine(); }
                    mbrWriter.flush();
                } catch (Exception e) {}
            }
            response.sendRedirect("admin-payments.jsp");
            return;
        }
    }

    List<String[]> incomingTransactions = new ArrayList<>();
    if (paymentsFile.exists()) {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(paymentsFile), "UTF-8"))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] items = line.split(",");
                
                // Only load structured transaction entries (rows 7-10 in your screenshot)
                if (items.length >= 6 && items[0].trim().startsWith("TXN-")) {
                    incomingTransactions.add(items);
                }
            }
        } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FITNASE | Core Operations Verification Vault</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&family=Oswald:wght@500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --brand-orange: #ff5722; --dark-bg: #0a0a0a; --card-glass: rgba(18, 18, 18, 0.95); }
        body {
            margin: 0; background: linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0.9)), url('https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1350&q=80');
            background-size: cover; color: white; font-family: 'Poppins', sans-serif; padding: 40px;
        }
        .container { max-width: 1100px; margin: 0 auto; background: var(--card-glass); border: 1px solid rgba(255, 87, 34, 0.15); padding: 40px; border-radius: 4px; border-top: 4px solid var(--brand-orange); }
        h1 { font-family: 'Oswald', sans-serif; text-transform: uppercase; letter-spacing: 2px; font-size: 2.2rem; margin-top: 0; }
        h1 span { color: var(--brand-orange); }
        p { color: #888; font-size: 0.9rem; margin-bottom: 30px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; text-align: left; font-size: 0.85rem; }
        th { font-family: 'Oswald', sans-serif; text-transform: uppercase; letter-spacing: 1px; color: var(--brand-orange); padding: 15px 10px; border-bottom: 2px solid #222; }
        td { padding: 15px 10px; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .badge { padding: 4px 10px; border-radius: 2px; font-weight: 600; font-size: 0.75rem; text-transform: uppercase; }
        .badge.pending { background: rgba(255, 179, 0, 0.15); color: #ffb300; border: 1px solid #ffb300; }
        .badge.approved { background: rgba(76, 175, 80, 0.15); color: #4caf50; border: 1px solid #4caf50; }
        .badge.rejected { background: rgba(244, 67, 54, 0.15); color: #f44336; border: 1px solid #f44336; }
        .act-btn { text-decoration: none; font-family: 'Oswald', sans-serif; font-size: 0.8rem; font-weight: bold; text-transform: uppercase; padding: 6px 14px; border-radius: 2px; letter-spacing: 0.5px; margin-right: 5px; display: inline-block; }
        .act-btn.approve { background: #4caf50; color: white; }
        .act-btn.reject { background: #f44336; color: white; }
        .act-btn:hover { opacity: 0.85; }
        .back-link { display: inline-block; margin-bottom: 20px; color: var(--brand-orange); text-decoration: none; font-family: 'Oswald', sans-serif; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 1px; }
        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <a href="admin-dashboard.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Return to Terminal Hub</a>
        <h1>Payment Verification <span>Clearing Vault</span></h1>
        <p>Review user financial sub-receipt entries and manually clear active premium package authorization variables.</p>
        
        <table>
            <thead>
                <tr>
                    <th>Txn ID</th>
                    <th>Member ID</th>
                    <th>Timestamp</th>
                    <th>Amount</th>
                    <th>Target Plan</th>
                    <th>Status</th>
                    <th>Action Controller Matrix</th>
                </tr>
            </thead>
            <tbody>
                <% if(incomingTransactions.isEmpty()){ %>
                    <tr><td colspan="7" style="text-align:center; color:#555;">No records indexed inside system file logs yet.</td></tr>
                <% } else { 
                    for(String[] txn : incomingTransactions) { 
                        String statusStr = txn[5].trim().toUpperCase();
                    %>
                    <tr>
                        <td><b><%= txn[0] %></b></td>
                        <td><%= txn[1] %></td>
                        <td style="color:#aaa;"><%= txn[2] %></td>
                        <td>Rs. <%= txn[3] %></td>
                        <td><span style="color:var(--brand-orange); font-weight:600;"><%= txn[4] %></span></td>
                        <td>
                            <span class="badge <%= statusStr.toLowerCase() %>"><%= statusStr %></span>
                        </td>
                        <td>
                            <% if("PENDING".equalsIgnoreCase(statusStr)) { %>
                                <a href="admin-payments.jsp?action=approve&txnId=<%= txn[0] %>" class="act-btn approve"><i class="fas fa-check"></i> Approve</a>
                                <a href="admin-payments.jsp?action=reject&txnId=<%= txn[0] %>" class="act-btn reject"><i class="fas fa-times"></i> Reject</a>
                            <% } else { %>
                                <span style="color:#444; font-weight:500;">LOG LOCKED</span>
                            <% } %>
                        </td>
                    </tr>
                <%  } 
               } %>
            </tbody>
        </table>
    </div>
</body>
</html>