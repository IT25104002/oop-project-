<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*" %>
<%!
    private String cleanValue(String value) {
        if (value == null) return "";
        return value.trim().replace(",", " ");
    }

    private String safeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String safeJs(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                    .replace("'", "\\'")
                    .replace("\"", "\\\"")
                    .replace("\r", "")
                    .replace("\n", "\\n");
    }
%>
<%
    String systemRole = (String) session.getAttribute("role");
    if (systemRole == null || !"ADMIN".equals(systemRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String baseDir = application.getRealPath("/");
    File dataDir = new File(baseDir + "webappdata");
    if (!dataDir.exists()) { dataDir.mkdirs(); }
    File adminsFile = new File(dataDir, "admins.txt");

    if (!adminsFile.exists()) {
        try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(adminsFile), "UTF-8"))) {
            bw.write("admin,admin123,System Administrator,SUPER ADMIN,ACTIVE");
            bw.newLine();
        } catch (Exception e) {}
    }

    String reqAction = request.getParameter("action");
    String notificationStatus = null;

    if (reqAction != null) {
        List<String> fileLines = new ArrayList<>();
        if (adminsFile.exists()) {
            try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(adminsFile), "UTF-8"))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (!line.trim().isEmpty()) fileLines.add(line.trim());
                }
            } catch (Exception e) {}
        }

        if ("create".equals(reqAction)) {
            String username = cleanValue(request.getParameter("username")).toLowerCase();
            String password = cleanValue(request.getParameter("password"));
            String fullName = cleanValue(request.getParameter("fullName"));
            String adminLevel = cleanValue(request.getParameter("adminLevel"));
            String status = cleanValue(request.getParameter("status"));

            boolean exists = false;
            for (String line : fileLines) {
                String[] parts = line.split(",", -1);
                if (parts.length > 0 && parts[0].trim().equalsIgnoreCase(username)) {
                    exists = true;
                    break;
                }
            }

            if (exists) {
                notificationStatus = "duplicate";
            } else {
                fileLines.add(username + "," + password + "," + fullName + "," + adminLevel + "," + status);
                notificationStatus = "added";
            }
        } else if ("update".equals(reqAction)) {
            String username = cleanValue(request.getParameter("username")).toLowerCase();
            String password = cleanValue(request.getParameter("password"));
            String fullName = cleanValue(request.getParameter("fullName"));
            String adminLevel = cleanValue(request.getParameter("adminLevel"));
            String status = cleanValue(request.getParameter("status"));

            for (int i = 0; i < fileLines.size(); i++) {
                String[] parts = fileLines.get(i).split(",", -1);
                if (parts.length > 0 && parts[0].trim().equalsIgnoreCase(username)) {
                    String currentPassword = parts.length > 1 ? parts[1].trim() : "admin123";
                    String finalPassword = password.isEmpty() ? currentPassword : password;
                    fileLines.set(i, username + "," + finalPassword + "," + fullName + "," + adminLevel + "," + status);
                    notificationStatus = "updated";
                    break;
                }
            }
        } else if ("delete".equals(reqAction)) {
            String username = cleanValue(request.getParameter("username"));
            int activeCount = 0;
            for (String line : fileLines) {
                String[] parts = line.split(",", -1);
                if (parts.length >= 5 && "ACTIVE".equalsIgnoreCase(parts[4].trim())) activeCount++;
            }

            Iterator<String> iter = fileLines.iterator();
            while (iter.hasNext()) {
                String[] parts = iter.next().split(",", -1);
                if (parts.length > 0 && parts[0].trim().equalsIgnoreCase(username)) {
                    String targetStatus = parts.length >= 5 ? parts[4].trim() : "ACTIVE";
                    if (activeCount <= 1 && "ACTIVE".equalsIgnoreCase(targetStatus)) {
                        notificationStatus = "lastActive";
                    } else {
                        iter.remove();
                        notificationStatus = "deleted";
                    }
                    break;
                }
            }
        }

        try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(adminsFile, false), "UTF-8"))) {
            for (String entryLine : fileLines) {
                bw.write(entryLine);
                bw.newLine();
            }
        } catch (Exception e) {}
    }

    List<String[]> adminsList = new ArrayList<>();
    if (adminsFile.exists()) {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(adminsFile), "UTF-8"))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (!line.trim().isEmpty()) adminsList.add(line.split(",", -1));
            }
        } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FITNASE | Admin Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;600;700&family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        :root { --brand-orange:#ff5722; --brand-glow:rgba(255,87,34,.25); --dark-bg:#0b0b0b; --panel-glass:rgba(18,18,18,.95); --border-line:rgba(255,87,34,.15); --text-dim:#aaaaaa; }
        body { font-family:'Poppins',sans-serif; margin:0; padding:40px; color:#fff; background:linear-gradient(rgba(10,10,10,.94),rgba(10,10,10,.94)),url('https://images.unsplash.com/photo-1517963628607-235ccdd5476c?auto=format&fit=crop&w=1350&q=80'); background-size:cover; background-attachment:fixed; }
        .header-area { display:flex; justify-content:space-between; align-items:center; margin-bottom:30px; gap:20px; }
        h2 { font-family:'Oswald',sans-serif; color:var(--brand-orange); text-transform:uppercase; margin:0; letter-spacing:1px; border-left:4px solid var(--brand-orange); padding-left:12px; }
        .back-btn { color:white; text-decoration:none; font-family:'Oswald',sans-serif; font-size:.85rem; text-transform:uppercase; letter-spacing:1px; border:1px solid #333; padding:10px 20px; border-radius:4px; background:rgba(0,0,0,.5); transition:.3s; white-space:nowrap; }
        .back-btn:hover { border-color:var(--brand-orange); color:var(--brand-orange); box-shadow:0 0 10px var(--brand-glow); }
        .workspace-container { display:flex; gap:30px; align-items:flex-start; }
        .form-panel { width:34%; background:var(--panel-glass); padding:25px; border-radius:4px; border:1px solid var(--border-line); backdrop-filter:blur(10px); box-sizing:border-box; }
        .table-panel { width:66%; background:var(--panel-glass); padding:25px; border-radius:4px; border:1px solid var(--border-line); backdrop-filter:blur(10px); box-sizing:border-box; overflow:auto; }
        h3 { font-family:'Oswald',sans-serif; margin-top:0; color:#fff; text-transform:uppercase; letter-spacing:1px; font-size:1.1rem; border-bottom:1px solid #222; padding-bottom:10px; }
        label { font-size:11px; color:#888; text-transform:uppercase; letter-spacing:1px; display:block; margin-bottom:6px; margin-top:14px; }
        input, select { width:100%; padding:10px; background:#000; color:#fff; border:1px solid #252525; border-radius:2px; box-sizing:border-box; font-family:inherit; font-size:.9rem; }
        input:focus, select:focus { border-color:var(--brand-orange); outline:none; }
        .btn-submit { width:100%; padding:12px; background:var(--brand-orange); color:white; border:none; font-family:'Oswald',sans-serif; font-size:1rem; font-weight:bold; letter-spacing:1px; text-transform:uppercase; margin-top:20px; cursor:pointer; border-radius:2px; }
        .btn-submit:hover { background:#e04c1b; box-shadow:0 0 15px var(--brand-glow); }
        .btn-clear { width:100%; padding:8px; background:transparent; color:#777; border:1px solid #222; font-family:'Oswald',sans-serif; font-size:.85rem; letter-spacing:1px; text-transform:uppercase; margin-top:8px; cursor:pointer; }
        .btn-clear:hover { color:#fff; border-color:#444; }
        table { width:100%; border-collapse:collapse; min-width:720px; }
        th { font-family:'Oswald',sans-serif; text-align:left; color:var(--brand-orange); padding:12px; border-bottom:2px solid #222; text-transform:uppercase; font-size:.85rem; letter-spacing:1px; }
        td { padding:12px; border-bottom:1px solid rgba(255,255,255,.04); font-size:.9rem; color:#ddd; }
        tr:hover td { background:rgba(255,255,255,.02); }
        .badge { padding:3px 8px; border-radius:3px; font-size:11px; font-weight:bold; text-transform:uppercase; letter-spacing:.5px; border:1px solid #555; }
        .badge-super { color:#ffa500; border-color:#ffa500; background:rgba(255,165,0,.12); }
        .badge-staff { color:#44bbff; border-color:#44bbff; background:rgba(68,187,255,.12); }
        .badge-active { color:#4caf50; }
        .badge-disabled { color:#ff4444; }
        .action-icon-btn { background:none; border:none; color:#666; cursor:pointer; font-size:1rem; margin:0 6px; padding:4px; }
        .action-icon-btn.edit-btn:hover { color:#44bbff; }
        .action-icon-btn.delete-btn:hover { color:#ff4444; }
        @media (max-width:900px) { body{padding:22px;} .workspace-container{flex-direction:column;} .form-panel,.table-panel{width:100%;} .header-area{align-items:flex-start; flex-direction:column;} }
    </style>
</head>
<body>
<div class="header-area">
    <h2>Admin Management Console</h2>
    <a href="admin-dashboard.jsp" class="back-btn"><i class="fas fa-arrow-left"></i> Command Console</a>
</div>

<div class="workspace-container">
    <div class="form-panel">
        <h3 id="formTitle">Add Admin Account</h3>
        <form id="adminForm" action="admin-management.jsp" method="post">
            <input type="hidden" name="action" id="formAction" value="create">

            <label>Admin Username</label>
            <input type="text" name="username" id="field_username" placeholder="e.g., manager01" required>

            <label id="passwordLabel">Login Password</label>
            <input type="password" name="password" id="field_password" placeholder="Set secure password" required>

            <label>Full Name</label>
            <input type="text" name="fullName" id="field_name" placeholder="Admin full name" required>

            <label>Admin Access Level</label>
            <select name="adminLevel" id="field_level">
                <option value="SUPER ADMIN">SUPER ADMIN</option>
                <option value="STAFF ADMIN">STAFF ADMIN</option>
                <option value="PAYMENT ADMIN">PAYMENT ADMIN</option>
                <option value="OPERATIONS ADMIN">OPERATIONS ADMIN</option>
            </select>

            <label>Account Status</label>
            <select name="status" id="field_status">
                <option value="ACTIVE">ACTIVE</option>
                <option value="DISABLED">DISABLED</option>
            </select>

            <button type="submit" class="btn-submit" id="submitBtn">Save Admin Record</button>
            <button type="button" class="btn-clear" onclick="resetFormState()">Clear / Cancel Edit</button>
        </form>
    </div>

    <div class="table-panel">
        <h3>Administrator Registry</h3>
        <table>
            <thead>
                <tr>
                    <th>Username</th>
                    <th>Full Name</th>
                    <th>Access Level</th>
                    <th>Status</th>
                    <th style="text-align:center;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (adminsList.isEmpty()) { %>
                    <tr><td colspan="5" style="text-align:center; padding:30px; color:#555;">No admin records stored yet.</td></tr>
                <% } else {
                    for (String[] admin : adminsList) {
                        String username = admin.length > 0 ? admin[0].trim() : "";
                        String fullName = admin.length > 2 ? admin[2].trim() : "";
                        String adminLevel = admin.length > 3 ? admin[3].trim() : "STAFF ADMIN";
                        String status = admin.length > 4 ? admin[4].trim() : "ACTIVE";
                        String levelClass = "SUPER ADMIN".equalsIgnoreCase(adminLevel) ? "badge-super" : "badge-staff";
                        String statusClass = "ACTIVE".equalsIgnoreCase(status) ? "badge-active" : "badge-disabled";
                %>
                    <tr>
                        <td><b><%= safeHtml(username) %></b></td>
                        <td><%= safeHtml(fullName) %></td>
                        <td><span class="badge <%= levelClass %>"><%= safeHtml(adminLevel) %></span></td>
                        <td><span class="<%= statusClass %>"><i class="fas fa-circle" style="font-size:8px;"></i> <%= safeHtml(status) %></span></td>
                        <td style="text-align:center; white-space:nowrap;">
                            <button class="action-icon-btn edit-btn" title="Edit Admin"
                                    onclick="populateEditForm('<%= safeJs(username) %>', '<%= safeJs(fullName) %>', '<%= safeJs(adminLevel) %>', '<%= safeJs(status) %>')">
                                <i class="fas fa-user-gear"></i>
                            </button>
                            <form action="admin-management.jsp" method="post" style="display:inline;" onsubmit="confirmRecordDeletion(event, this, '<%= safeJs(username) %>')">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="username" value="<%= safeHtml(username) %>">
                                <button type="submit" class="action-icon-btn delete-btn" title="Delete Admin">
                                    <i class="fas fa-user-slash"></i>
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
    <% if (notificationStatus != null) { %>
        const status = "<%= notificationStatus %>";
        if (status === "added") {
            Swal.fire({ icon:"success", title:"Admin Added", text:"New administrator account saved.", background:"#111", color:"#fff", confirmButtonColor:"#ff5722" });
        } else if (status === "updated") {
            Swal.fire({ icon:"success", title:"Admin Updated", text:"Administrator account changes saved.", background:"#111", color:"#fff", confirmButtonColor:"#ff5722" });
        } else if (status === "deleted") {
            Swal.fire({ icon:"warning", title:"Admin Deleted", text:"Administrator record removed from flat-file storage.", background:"#111", color:"#fff", confirmButtonColor:"#ff5722" });
        } else if (status === "duplicate") {
            Swal.fire({ icon:"error", title:"Username Exists", text:"Choose another admin username.", background:"#111", color:"#fff", confirmButtonColor:"#ff5722" });
        } else if (status === "lastActive") {
            Swal.fire({ icon:"error", title:"Action Blocked", text:"At least one active admin must remain available.", background:"#111", color:"#fff", confirmButtonColor:"#ff5722" });
        }
    <% } %>

    function populateEditForm(username, fullName, adminLevel, status) {
        document.getElementById("formTitle").innerText = "Modify Admin: " + username;
        document.getElementById("formAction").value = "update";

        const usernameField = document.getElementById("field_username");
        usernameField.value = username;
        usernameField.readOnly = true;
        usernameField.style.background = "#151515";
        usernameField.style.color = "#888";

        const passwordField = document.getElementById("field_password");
        passwordField.value = "";
        passwordField.required = false;
        passwordField.placeholder = "Leave blank to keep current password";
        document.getElementById("passwordLabel").innerText = "New Password Optional";

        document.getElementById("field_name").value = fullName;
        document.getElementById("field_level").value = adminLevel;
        document.getElementById("field_status").value = status;
        document.getElementById("submitBtn").innerText = "Synchronize Admin Record";
        document.getElementById("submitBtn").style.background = "#0088cc";
    }

    function resetFormState() {
        document.getElementById("adminForm").reset();
        document.getElementById("formTitle").innerText = "Add Admin Account";
        document.getElementById("formAction").value = "create";

        const usernameField = document.getElementById("field_username");
        usernameField.readOnly = false;
        usernameField.style.background = "#000";
        usernameField.style.color = "#fff";

        const passwordField = document.getElementById("field_password");
        passwordField.required = true;
        passwordField.placeholder = "Set secure password";
        document.getElementById("passwordLabel").innerText = "Login Password";
        document.getElementById("submitBtn").innerText = "Save Admin Record";
        document.getElementById("submitBtn").style.background = "#ff5722";
    }

    function confirmRecordDeletion(e, form, username) {
        e.preventDefault();
        Swal.fire({
            title:"Delete Admin Account?",
            text:"Remove " + username + " from administrator access files?",
            icon:"warning",
            showCancelButton:true,
            confirmButtonColor:"#ff4444",
            cancelButtonColor:"#222",
            confirmButtonText:"Yes, Delete Admin",
            background:"#111",
            color:"#fff"
        }).then((result) => {
            if (result.isConfirmed) form.submit();
        });
    }
</script>
</body>
</html>
