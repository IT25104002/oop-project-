<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Change Password | FitPro</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="app-body">
<aside class="sidebar">
    <div class="brand"><span>FIT</span>PRO</div>
    <a href="${pageContext.request.contextPath}/member/profile">My Profile</a>
    <a href="${pageContext.request.contextPath}/member/edit">Edit Profile</a>
    <a class="active" href="${pageContext.request.contextPath}/member/change-password">Change Password</a>
    <a href="${pageContext.request.contextPath}/logout">Logout</a>
</aside>
<main class="main-content">
    <header class="page-header"><div><p class="eyebrow">Account Security</p><h1>Change Password</h1></div></header>
    <% if (request.getAttribute("error") != null) { %><div class="alert error"><%= request.getAttribute("error") %></div><% } %>
    <form class="form-card narrow" method="post" action="${pageContext.request.contextPath}/member/change-password">
        <label>Current Password</label>
        <input type="password" name="currentPassword" required>
        <label>New Password</label>
        <input type="password" name="newPassword" required>
        <label>Confirm New Password</label>
        <input type="password" name="confirmPassword" required>
        <p class="helper-text">Use minimum 8 characters with uppercase letter, number, and special character.</p>
        <div class="form-actions">
            <button class="btn btn-green" type="submit">Update Password</button>
            <a class="btn btn-outline-dark" href="${pageContext.request.contextPath}/member/profile">Cancel</a>
        </div>
    </form>
</main>
</body>
</html>
