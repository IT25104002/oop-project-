<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*" %>
<%
    String baseDir = application.getRealPath("/");
    File dataDir = new File(baseDir + "webappdata");
    if (!dataDir.exists()) { dataDir.mkdirs(); }
    File membersFile = new File(dataDir, "members.txt");

    String reqAction = request.getParameter("action");
    String notificationStatus = null;

    // --- CRUD CONTROLLER LAYER ---
    if (reqAction != null) {
        List<String> fileLines = new ArrayList<>();
        
        // Load current records into memory if file exists
        if (membersFile.exists()) {
            try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(membersFile), "UTF-8"))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (!line.trim().isEmpty()) {
                        fileLines.add(line.trim());
                    }
                }
            } catch (Exception e) {}
        }

        if ("create".equals(reqAction)) {
            String newId = request.getParameter("memberId").trim().toUpperCase();
            String newPass = request.getParameter("password").trim();
            String newName = request.getParameter("fullName").trim();
            String newStatus = request.getParameter("status").trim();
            String newPlan = request.getParameter("currentPlan").trim();
            String newTrack = request.getParameter("focusTrack").trim();
            String newExpiry = "2027-01-01"; // Fallback placeholder date matching your storage schema

            // Duplicate Prevention Check
            boolean idExists = false;
            for (String line : fileLines) {
                if (line.startsWith(newId + ",")) {
                    idExists = true;
                    break;
                }
            }

            if (idExists) {
                notificationStatus = "duplicate";
            } else {
                // Layout pattern: ID, Password, Name, Status, PlanIndex, FocusTrack, TierUpper, Expiry
                String newRecord = newId + "," + newPass + "," + newName + "," + newStatus + ",60," + newPlan + "," + newTrack + "," + newExpiry;
                fileLines.add(newRecord);
                notificationStatus = "added";
            }
        } 
        else if ("update".equals(reqAction)) {
            String targetId = request.getParameter("memberId").trim();
            String updateName = request.getParameter("fullName").trim();
            String updateStatus = request.getParameter("status").trim();
            String updatePlan = request.getParameter("currentPlan").trim();
            String updateTrack = request.getParameter("focusTrack").trim();

            for (int i = 0; i < fileLines.size(); i++) {
                String[] segments = fileLines.get(i).split(",");
                if (segments.length > 0 && segments[0].trim().equalsIgnoreCase(targetId)) {
                    String existingPass = segments.length > 1 ? segments[1] : "1111";
                    String existingIndexNum = segments.length > 4 ? segments[4] : "60";
                    String existingExpiry = segments.length > 7 ? segments[7] : "2027-01-01";

                    fileLines.set(i, targetId + "," + existingPass + "," + updateName + "," + updateStatus + "," + existingIndexNum + "," + updatePlan + "," + updateTrack + "," + existingExpiry);
                    notificationStatus = "updated";
                    break;
                }
            }
        } 
        else if ("delete".equals(reqAction)) {
            String targetId = request.getParameter("memberId").trim();
            Iterator<String> iter = fileLines.iterator();
            while (iter.hasNext()) {
                String[] segments = iter.next().split(",");
                if (segments.length > 0 && segments[0].trim().equalsIgnoreCase(targetId)) {
                    iter.remove();
                    notificationStatus = "deleted";
                    break;
                }
            }
        }

        // Flush memory modifications safely back to flat file database
        try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(membersFile, false), "UTF-8"))) {
            for (String entryLine : fileLines) {
                bw.write(entryLine);
                bw.newLine();
            }
            bw.flush();
        } catch (Exception e) {}
    }

    // --- READ LAYER ---
    List<String[]> membersList = new ArrayList<>();
    if (membersFile.exists()) {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(membersFile), "UTF-8"))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                membersList.add(line.split(","));
            }
        } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FITNASE | Manage Members Matrix</title>
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
            --text-dim: #aaaaaa;
        }
        body { 
            font-family: 'Poppins', sans-serif; background-color: var(--dark-bg); color: #fff; margin: 0; padding: 40px; 
            background: linear-gradient(rgba(10, 10, 10, 0.95), rgba(10, 10, 10, 0.95)), url('https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=1200&q=80');
            background-size: cover; background-attachment: fixed;
        }
        .header-area { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        h2 { font-family: 'Oswald', sans-serif; color: var(--brand-orange); text-transform: uppercase; margin: 0; letter-spacing: 1px; border-left: 4px solid var(--brand-orange); padding-left: 12px; }
        
        .back-btn { color: white; text-decoration: none; font-family: 'Oswald', sans-serif; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; border: 1px solid #333; padding: 10px 20px; border-radius: 4px; background: rgba(0,0,0,0.5); transition: 0.3s; }
        .back-btn:hover { border-color: var(--brand-orange); color: var(--brand-orange); box-shadow: 0 0 10px var(--brand-glow); }
        
        .workspace-container { display: flex; gap: 30px; align-items: flex-start; }
        .form-panel { width: 35%; background: var(--panel-glass); padding: 25px; border-radius: 4px; border: 1px solid var(--border-line); backdrop-filter: blur(10px); }
        .table-panel { width: 65%; background: var(--panel-glass); padding: 25px; border-radius: 4px; border: 1px solid var(--border-line); backdrop-filter: blur(10px); }
        
        h3 { font-family: 'Oswald', sans-serif; margin-top: 0; color: #fff; text-transform: uppercase; letter-spacing: 1px; font-size: 1.1rem; border-bottom: 1px solid #222; padding-bottom: 10px; }
        
        label { font-size: 11px; color: #888; text-transform: uppercase; letter-spacing: 1px; display: block; margin-bottom: 6px; margin-top: 14px; }
        input, select { width: 100%; padding: 10px; background: #000; color: white; border: 1px solid #252525; border-radius: 2px; box-sizing: border-box; font-family: inherit; font-size: 0.9rem; }
        input:focus, select:focus { border-color: var(--brand-orange); outline: none; }
        
        .btn-submit { width: 100%; padding: 12px; background: var(--brand-orange); color: white; border: none; font-family: 'Oswald', sans-serif; font-size: 1rem; font-weight: bold; letter-spacing: 1px; text-transform: uppercase; margin-top: 20px; cursor: pointer; transition: 0.2s; border-radius: 2px; }
        .btn-submit:hover { background: #e04c1b; box-shadow: 0 0 15px var(--brand-glow); }
        .btn-clear { width: 100%; padding: 8px; background: transparent; color: #666; border: 1px solid #222; font-family: 'Oswald', sans-serif; font-size: 0.85rem; letter-spacing: 1px; text-transform: uppercase; margin-top: 8px; cursor: pointer; transition: 0.2s; }
        .btn-clear:hover { color: #fff; border-color: #444; }

        table { width: 100%; border-collapse: collapse; }
        th { font-family: 'Oswald', sans-serif; text-align: left; color: var(--brand-orange); padding: 12px; border-bottom: 2px solid #222; text-transform: uppercase; font-size: 0.85rem; letter-spacing: 1px; }
        td { padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.03); font-size: 0.9rem; color: #dddddd; }
        tr:hover td { background: rgba(255,255,255,0.01); }

        .badge { padding: 3px 8px; border-radius: 3px; font-size: 11px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; }
        .badge-gold { background: rgba(255,165,0,0.15); color: #ffa500; border: 1px solid #ffa500; }
        .badge-silver { background: rgba(192,192,192,0.15); color: #c0c0c0; border: 1px solid #c0c0c0; }
        .badge-bronze { background: rgba(205,127,50,0.15); color: #cd7f32; border: 1px solid #cd7f32; }

        .action-icon-btn { background: none; border: none; color: #666; cursor: pointer; font-size: 1rem; margin: 0 6px; transition: 0.2s; padding: 4px; }
        .action-icon-btn.edit-btn:hover { color: #44bbff; }
        .action-icon-btn.delete-btn:hover { color: #ff4444; }
    </style>
</head>
<body>

<div class="header-area">
    <h2>Manage Members Control Matrix</h2>
    <a href="admin-dashboard.jsp" class="back-btn"><i class="fas fa-arrow-left"></i> Command Console</a>
</div>

<div class="workspace-container">
    <div class="form-panel">
        <h3 id="formTitle">Register Profile Entry</h3>
        <form id="memberForm" action="admin-members.jsp" method="post">
            <input type="hidden" name="action" id="formAction" value="create">

            <label>Member ID ID</label>
            <input type="text" name="memberId" id="field_id" placeholder="e.g., MEM-104" required>

            <div id="passwordWrapper">
                <label>Security Access Password</label>
                <input type="password" name="password" id="field_password" value="1111" required>
            </div>

            <label>Full Name</label>
            <input type="text" name="fullName" id="field_name" placeholder="Client Name" required>

            <label>System Authorization Status</label>
            <select name="status" id="field_status">
                <option value="ACTIVE MEMBER">ACTIVE MEMBER</option>
                <option value="SUSPENDED">SUSPENDED</option>
            </select>

            <label>Focus Track Focus Program</label>
            <input type="text" name="currentPlan" id="field_plan" placeholder="e.g., Muscle Building or Weight Loss" required>

            <label>Tier Access Level Allocation</label>
            <select name="focusTrack" id="field_track">
                <option value="GOLD">GOLD (Premium Booking Access)</option>
                <option value="SILVER">SILVER (Standard Track)</option>
                <option value="BRONZE">BRONZE (Base Tier Only)</option>
            </select>

            <button type="submit" class="btn-submit" id="submitBtn">Save Member Record</button>
            <button type="button" class="btn-clear" onclick="resetFormState()">Clear / Cancel Edit</button>
        </form>
    </div>

    <div class="table-panel">
        <h3>System Database Registries</h3>
        <table>
            <thead>
                <tr>
                    <th>Member ID</th>
                    <th>Full Name</th>
                    <th>Status</th>
                    <th>Focus Track</th>
                    <th>Tier Allocation</th>
                    <th style="text-align: center;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (membersList.isEmpty()) { %>
                    <tr><td colspan="6" style="text-align:center; padding: 30px; color: #555;">No profiles stored within database flat files.</td></tr>
                <% } else { 
                    for (String[] member : membersList) { 
                        // Map internal array values down accurately based on file architecture layout
                        String id = member.length > 0 ? member[0].trim() : "";
                        String name = member.length > 2 ? member[2].trim() : "";
                        String status = member.length > 3 ? member[3].trim() : "";
                        String plan = member.length > 5 ? member[5].trim() : "";
                        String track = member.length > 6 ? member[6].trim() : "BRONZE";
                        
                        String badgeStyleClass = "badge-bronze";
                        if ("GOLD".equalsIgnoreCase(track)) badgeStyleClass = "badge-gold";
                        else if ("SILVER".equalsIgnoreCase(track)) badgeStyleClass = "badge-silver";
                %>
                        <tr>
                            <td><b><%= id %></b></td>
                            <td><%= name %></td>
                            <td><span style="color: <%= "ACTIVE MEMBER".equalsIgnoreCase(status) ? "#4CAF50" : "#ff4444" %>; font-size:12px;"><i class="fas fa-circle" style="font-size:8px; vertical-align:middle;"></i> <%= status %></span></td>
                            <td><%= plan %></td>
                            <td><span class="badge <%= badgeStyleClass %>"><%= track %></span></td>
                            <td style="text-align: center; white-space: nowrap;">
                                <button class="action-icon-btn edit-btn" title="Edit Profile Mapping" 
                                        onclick="populateEditForm('<%= id %>', '<%= name %>', '<%= status %>', '<%= plan %>', '<%= track %>')">
                                    <i class="fas fa-user-edit"></i>
                                </button>
                                
                                <form action="admin-members.jsp" method="post" style="display:inline;" onsubmit="confirmRecordDeletion(event, this, '<%= id %>')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="memberId" value="<%= id %>">
                                    <button type="submit" class="action-icon-btn delete-btn" title="Purge Record">
                                        <i class="fas fa-user-minus"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                <%  } 
                } %>
            </tbody>
        </table>
    </div>
</div>

<script>
    // System UI Notification Handling Actions via SweetAlert2
    <% if (notificationStatus != null) { %>
        const status = "<%= notificationStatus %>";
        if(status === 'added') {
            Swal.fire({ icon: 'success', title: 'Record Registered', text: 'New member profile entry appended safely.', background: '#111', color: '#fff', confirmButtonColor: '#ff5722' });
        } else if(status === 'updated') {
            Swal.fire({ icon: 'success', title: 'Registry Restructured', text: 'Target account changes synchronized.', background: '#111', color: '#fff', confirmButtonColor: '#ff5722' });
        } else if(status === 'deleted') {
            Swal.fire({ icon: 'warning', title: 'Profile Purged', text: 'Account file mapping has been cleared.', background: '#111', color: '#fff', confirmButtonColor: '#ff5722' });
        } else if(status === 'duplicate') {
            Swal.fire({ icon: 'error', title: 'Identity Clash!', text: 'The target Member ID already exists in the flat-file database.', background: '#111', color: '#fff', confirmButtonColor: '#ff5722' });
        }
    <% } %>

    // Dynamic UI Interlock - Changes layout to Update Action
    function populateEditForm(id, name, status, plan, track) {
        document.getElementById("formTitle").innerText = "Modify Member Profile: " + id;
        document.getElementById("formAction").value = "update";
        
        const idField = document.getElementById("field_id");
        idField.value = id;
        idField.readOnly = true; // Protect primary key consistency
        idField.style.background = "#151515";
        idField.style.color = "#888";

        document.getElementById("passwordWrapper").style.display = "none";
        document.getElementById("field_password").required = false;
        
        document.getElementById("field_name").value = name;
        document.getElementById("field_status").value = status;
        document.getElementById("field_plan").value = plan;
        document.getElementById("field_track").value = track;
        
        document.getElementById("submitBtn").innerText = "Synchronize Database File";
        document.getElementById("submitBtn").style.background = "#0088cc";
    }

    // Reset layout frame back to default Insertion Action
    function resetFormState() {
        document.getElementById("formTitle").innerText = "Register Profile Entry";
        document.getElementById("formAction").value = "create";
        
        const idField = document.getElementById("field_id");
        idField.value = "";
        idField.readOnly = false;
        idField.style.background = "#000";
        idField.style.color = "#fff";

        document.getElementById("passwordWrapper").style.display = "block";
        document.getElementById("field_password").required = true;
        
        document.getElementById("memberForm").reset();
        
        document.getElementById("submitBtn").innerText = "Save Member Record";
        document.getElementById("submitBtn").style.background = "#ff5722";
    }

    // Protection intercept layer before structural file deletion drops
    function confirmRecordDeletion(e, form, targetId) {
        e.preventDefault();
        Swal.fire({ 
            title: 'Purge Profile Record?', 
            text: "Are you certain you want to erase " + targetId + " from system files entirely?", 
            icon: 'warning', 
            showCancelButton: true, 
            confirmButtonColor: '#ff4444', 
            cancelButtonColor: '#222',
            confirmButtonText: 'Yes, Purge From Disk',
            background: '#111', 
            color: '#fff' 
        }).then((result) => { 
            if (result.isConfirmed) form.submit(); 
        });
    }
</script>
</body>
</html>