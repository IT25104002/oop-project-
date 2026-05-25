<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*" %>
<%
    String baseDir = application.getRealPath("/");
    File dataDir = new File(baseDir + "webappdata");
    if (!dataDir.exists()) { dataDir.mkdirs(); }
    File membersFile = new File(dataDir, "members.txt");


    String selectedMemberId = request.getParameter("targetMemberId");
    String reqAction = request.getParameter("action");
    String jsNotification = null;
    String activeDietContent = "";

    // Load available profile listings to populate administrative selection dropdowns
    List<String[]> eligibleMembers = new ArrayList<>();
    if (membersFile.exists()) {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(membersFile), "UTF-8"))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",");
                
                // FIXED LAYOUT DETECTION: Scan indices to find the tier label safely
                String tierFound = "BRONZE";
                for (String part : parts) {
                    String trimmedPart = part.trim();
                    if ("GOLD".equalsIgnoreCase(trimmedPart) || "SILVER".equalsIgnoreCase(trimmedPart)) {
                        tierFound = trimmedPart.toUpperCase();
                        break;
                    }
                }

                // Accept users who are part of the Premium Tiers
                if ("GOLD".equals(tierFound) || "SILVER".equals(tierFound)) {
                    // Create a normalized temporary 4-element block for display mapping: [ID, Name, Plan, Tier]
                    String id = parts.length > 0 ? parts[0].trim() : "UNKNOWN";
                    String name = parts.length > 2 ? parts[2].trim() : "No Name";
                    String plan = parts.length > 5 ? parts[5].trim() : "General Track";
                    
                    eligibleMembers.add(new String[]{ id, name, plan, tierFound });
                }
            }
        } catch (Exception e) {}
    }

    // Default to the first available premium member if none chosen yet
    if ((selectedMemberId == null || selectedMemberId.trim().isEmpty()) && !eligibleMembers.isEmpty()) {
        selectedMemberId = eligibleMembers.get(0)[0];
    }

    File dietFile = (selectedMemberId != null) ? new File(dataDir, selectedMemberId.toUpperCase() + "_diet.txt") : null;

    // --- SAVE / UPDATE DIET CONTROLLER ---
    if ("saveDiet".equals(reqAction) && dietFile != null) {
        String inputContent = request.getParameter("dietText");
        try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(dietFile, false), "UTF-8"))) {
            if (inputContent != null) {
                bw.write(inputContent.trim());
            }
            bw.flush();
            jsNotification = "saved";
            activeDietContent = inputContent.trim();
        } catch (Exception e) {
            jsNotification = "error";
        }
    } 
    // --- READ ACTIVE PLAN LAYER ---
    else if (dietFile != null && dietFile.exists()) {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(dietFile), "UTF-8"))) {
            String l;
            while ((l = br.readLine()) != null) {
                sb.append(l).append("\n");
            }
            activeDietContent = sb.toString().trim();
        } catch (Exception e) {}
    } else if (selectedMemberId != null) {
        // Safe baseline template format for empty files
        activeDietContent = "=== DAILY NUTRITIONAL MACRO MATRIX ===\n" +
                            "Breakfast (07:00 AM): Oats, Whey Protein & Almonds\n" +
                            "Lunch (01:00 PM): 200g Grilled Chicken Breast, Basmati Rice & Broccoli\n" +
                            "Dinner (08:00 PM): Baked Salmon or Lean Beef with Sweet Potatoes\n\n" +
                            "Target: 2500 kcal | 180g P / 220g C / 65g F";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FITNASE | Diet Control Panel</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;600;700&family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        :root {
            --brand-orange: #ff5722;
            --brand-glow: rgba(255, 87, 34, 0.25);
            --dark-bg: #0b0b0b;
            --panel-glass: rgba(18, 18, 18, 0.95);
            --border-line: rgba(255, 87, 34, 0.15);
        }
        body { 
            font-family: 'Poppins', sans-serif; background-color: var(--dark-bg); color: #fff; margin: 0; padding: 40px; 
            background: linear-gradient(rgba(10, 10, 10, 0.95), rgba(10, 10, 10, 0.95)), url('https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=1200&q=80');
            background-size: cover; background-attachment: fixed;
        }
        .header-area { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        h2 { font-family: 'Oswald', sans-serif; color: var(--brand-orange); text-transform: uppercase; margin: 0; letter-spacing: 1px; border-left: 4px solid var(--brand-orange); padding-left: 12px; }
        .back-btn { color: white; text-decoration: none; font-family: 'Oswald', sans-serif; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; border: 1px solid #333; padding: 10px 20px; border-radius: 4px; background: rgba(0,0,0,0.5); transition: 0.3s; }
        .back-btn:hover { border-color: var(--brand-orange); color: var(--brand-orange); }
        
        .layout { display: flex; gap: 30px; }
        .panel { background: var(--panel-glass); border: 1px solid var(--border-line); border-radius: 4px; padding: 25px; backdrop-filter: blur(10px); }
        .sidebar { width: 35%; }
        .workspace { width: 65%; }
        
        h3 { font-family: 'Oswald', sans-serif; margin-top: 0; text-transform: uppercase; letter-spacing: 1px; color: #fff; border-bottom: 1px solid #222; padding-bottom: 10px; }
        label { font-size: 11px; color: #888; text-transform: uppercase; letter-spacing: 1px; display: block; margin-bottom: 8px; }
        select { width: 100%; padding: 12px; background: #000; color: white; border: 1px solid #252525; border-radius: 2px; font-family: inherit; margin-bottom: 20px; }
        
        textarea { width: 100%; height: 320px; background: #000; color: #00ff66; border: 1px solid #252525; border-radius: 2px; padding: 15px; font-family: 'Courier New', Courier, monospace; font-size: 0.95rem; resize: none; box-sizing: border-box; line-height: 1.6; }
        textarea:focus { border-color: var(--brand-orange); outline: none; }
        
        .btn-action { width: 100%; padding: 14px; background: var(--brand-orange); color: white; border: none; font-family: 'Oswald', sans-serif; font-size: 1rem; font-weight: bold; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: 0.2s; border-radius: 2px; }
        .btn-action:hover { background: #e04c1b; box-shadow: 0 0 15px var(--brand-glow); }
        
        .member-row { padding: 10px; border-bottom: 1px solid rgba(255,255,255,0.02); display: flex; justify-content: space-between; align-items: center; font-size: 13px; }
        .badge { padding: 2px 6px; border-radius: 3px; font-size: 10px; font-weight: bold; }
        .badge-GOLD { background: rgba(255,165,0,0.15); color: #ffa500; border: 1px solid #ffa500; }
        .badge-SILVER { background: rgba(192,192,192,0.15); color: #c0c0c0; border: 1px solid #c0c0c0; }
    </style>
</head>
<body>

<div class="header-area">
    <h2>Diet Plan Management Matrix</h2>
    <a href="admin-dashboard.jsp" class="back-btn"><i class="fas fa-arrow-left"></i> Command Console</a>
</div>

<div class="layout">
    <div class="panel sidebar">
        <h3>Premium Active Tracks</h3>
        <% if (eligibleMembers.isEmpty()) { %>
            <p style="color: #666; font-size: 0.9rem;">No active premium tier members detected in system data.</p>
        <% } else { %>
            <form action="admin-diet.jsp" method="get" id="selectorForm">
                <label>Select Target Athlete Profile</label>
                <select name="targetMemberId" onchange="document.getElementById('selectorForm').submit();">
                    <% for (String[] member : eligibleMembers) { 
                        String id = member[0];
                        String name = member[1];
                        String isSelected = id.equalsIgnoreCase(selectedMemberId) ? "selected" : "";
                    %>
                        <option value="<%= id %>" <%= isSelected %>><%= id %> — <%= name %></option>
                    <% } %>
                </select>
            </form>
        <% } %>

        <div style="margin-top: 10px;">
            <label>Athlete Summary Matrix</label>
            <% for (String[] member : eligibleMembers) { 
                String id = member[0];
                String name = member[1];
                String tier = member[3];
                boolean isCurrent = id.equalsIgnoreCase(selectedMemberId);
            %>
                <div class="member-row" style="<%= isCurrent ? "border-left: 3px solid var(--brand-orange); padding-left: 7px; background: rgba(255,87,34,0.05);" : "" %>">
                    <span><%= name %> (<b><%= id %></b>)</span>
                    <span class="badge badge-<%= tier %>"><%= tier %></span>
                </div>
            <% } %>
        </div>
    </div>

    <div class="panel workspace">
        <h3>Live Macro Script Editor: <span style="color: var(--brand-orange);"><%= (selectedMemberId != null) ? selectedMemberId : "NONE SELECTED" %></span></h3>
        <% if (selectedMemberId == null) { %>
            <p style="color: #555; text-align: center; padding: 40px;">Please register or upgrade a member to a premium tier using the Manage Members tool to begin.</p>
        <% } else { %>
            <form action="admin-diet.jsp" method="post">
                <input type="hidden" name="action" value="saveDiet">
                <input type="hidden" name="targetMemberId" value="<%= selectedMemberId %>">
                
                <label>File Target: webappdata / <%= selectedMemberId.toUpperCase() %>_diet.txt</label>
                <textarea name="dietText"><%= activeDietContent %></textarea>
                
                <div style="margin-top: 20px;">
                    <button type="submit" class="btn-action"><i class="fas fa-save"></i> Push Macro Updates to Athlete Matrix</button>
                </div>
            </form>
        <% } %>
    </div>
</div>

<script>
    <% if (jsNotification != null) { %>
        const res = "<%= jsNotification %>";
        if (res === 'saved') {
            Swal.fire({ icon: 'success', title: 'Plan Pushed!', text: 'Diet matrix values rewritten successfully.', background: '#111', color: '#fff', confirmButtonColor: '#ff5722' });
        } else if (res === 'error') {
            Swal.fire({ icon: 'error', title: 'Write Fault', text: 'Unable to commit text structural change down to server disk.', background: '#111', color: '#fff', confirmButtonColor: '#ff5722' });
        }
    <% } %>
</script>

</body>
</html>