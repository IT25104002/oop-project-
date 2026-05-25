<%@ page import="com.fitness.model.Member" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% Member member = (Member) request.getAttribute("member"); %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Profile | FitPro</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="app-body">
<aside class="sidebar">
    <div class="brand"><span>FIT</span>PRO</div>
    <a href="${pageContext.request.contextPath}/member/profile">My Profile</a>
    <a class="active" href="${pageContext.request.contextPath}/member/edit">Edit Profile</a>
    <a href="${pageContext.request.contextPath}/member/change-password">Change Password</a>
    <a href="${pageContext.request.contextPath}/logout">Logout</a>
</aside>
<main class="main-content">
    <header class="page-header"><div><p class="eyebrow">Profile Maintenance</p><h1>Edit My Details</h1></div></header>
    <% if (request.getAttribute("error") != null) { %><div class="alert error"><%= request.getAttribute("error") %></div><% } %>
    <form class="form-card" method="post" action="${pageContext.request.contextPath}/member/edit">
        <div class="form-grid">
            <div><label>Full Name</label><input name="fullName" value="<%= member.getFullName() %>" required></div>
            <div><label>Phone</label><input name="phone" value="<%= member.getPhone() %>" required></div>
            <div><label>Date of Birth</label><input type="date" name="dob" value="<%= member.getDob() %>"></div>
            <div><label>Gender</label><select name="gender"><option <%= "Male".equals(member.getGender()) ? "selected" : "" %>>Male</option><option <%= "Female".equals(member.getGender()) ? "selected" : "" %>>Female</option><option <%= "Other".equals(member.getGender()) ? "selected" : "" %>>Other</option></select></div>
            <div><label>Height cm</label><input type="number" step="0.01" name="height" value="<%= member.getHeight() %>"></div>
            <div><label>Weight kg</label><input type="number" step="0.01" name="weight" value="<%= member.getWeight() %>"></div>
            <div><label>Fitness Goal</label><input name="fitnessGoal" value="<%= member.getFitnessGoal() %>"></div>
            <div><label>Emergency Contact</label><input name="emergencyContact" value="<%= member.getEmergencyContact() %>"></div>
            <div class="wide"><label>Address</label><textarea name="address"><%= member.getAddress() %></textarea></div>
        </div>
        <div class="form-actions">
            <button class="btn btn-green" type="submit">Save Changes</button>
            <a class="btn btn-outline-dark" href="${pageContext.request.contextPath}/member/profile">Cancel</a>
        </div>
    </form>
</main>
</body>
</html>
