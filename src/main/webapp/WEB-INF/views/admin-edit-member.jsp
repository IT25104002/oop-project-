<%@ page import="com.fitness.model.Member" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% Member member = (Member) request.getAttribute("member"); %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Member | FitPro</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="app-body">
<aside class="sidebar admin">
    <div class="brand"><span>FIT</span>PRO</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
    <a class="active" href="${pageContext.request.contextPath}/admin/members">Manage Members</a>
    <a href="${pageContext.request.contextPath}/logout">Logout</a>
</aside>
<main class="main-content">
    <header class="page-header"><div><p class="eyebrow">Admin Update</p><h1>Edit Member Details</h1></div></header>
    <% if (request.getAttribute("error") != null) { %><div class="alert error"><%= request.getAttribute("error") %></div><% } %>
    <form class="form-card" method="post" action="${pageContext.request.contextPath}/admin/member/edit">
        <input type="hidden" name="memberId" value="<%= member.getMemberId() %>">
        <div class="form-grid">
            <div><label>Full Name</label><input name="fullName" value="<%= member.getFullName() %>" required></div>
            <div><label>Phone</label><input name="phone" value="<%= member.getPhone() %>"></div>
            <div><label>Date of Birth</label><input type="date" name="dob" value="<%= member.getDob() %>"></div>
            <div><label>Gender</label><select name="gender"><option <%= "Male".equals(member.getGender()) ? "selected" : "" %>>Male</option><option <%= "Female".equals(member.getGender()) ? "selected" : "" %>>Female</option><option <%= "Other".equals(member.getGender()) ? "selected" : "" %>>Other</option></select></div>
            <div><label>Height cm</label><input type="number" step="0.01" name="height" value="<%= member.getHeight() %>"></div>
            <div><label>Weight kg</label><input type="number" step="0.01" name="weight" value="<%= member.getWeight() %>"></div>
            <div><label>Fitness Goal</label><input name="fitnessGoal" value="<%= member.getFitnessGoal() %>"></div>
            <div><label>Emergency Contact</label><input name="emergencyContact" value="<%= member.getEmergencyContact() %>"></div>
            <div><label>Membership Plan</label><select name="membershipPlan"><option <%= "Premium Monthly".equals(member.getMembershipPlan()) ? "selected" : "" %>>Premium Monthly</option><option <%= "Quarterly".equals(member.getMembershipPlan()) ? "selected" : "" %>>Quarterly</option><option <%= "Yearly".equals(member.getMembershipPlan()) ? "selected" : "" %>>Yearly</option></select></div>
            <div><label>Payment Status</label><select name="paymentStatus"><option <%= "Paid".equals(member.getPaymentStatus()) ? "selected" : "" %>>Paid</option><option <%= "Pending".equals(member.getPaymentStatus()) ? "selected" : "" %>>Pending</option><option <%= "Failed".equals(member.getPaymentStatus()) ? "selected" : "" %>>Failed</option></select></div>
            <div><label>Account Status</label><select name="status"><option <%= "Active".equals(member.getStatus()) ? "selected" : "" %>>Active</option><option <%= "Inactive".equals(member.getStatus()) ? "selected" : "" %>>Inactive</option><option <%= "Expired".equals(member.getStatus()) ? "selected" : "" %>>Expired</option></select></div>
            <div><label>Join Date</label><input type="date" name="joinDate" value="<%= member.getJoinDate() %>"></div>
            <div><label>Expiry Date</label><input type="date" name="expiryDate" value="<%= member.getExpiryDate() %>"></div>
            <div class="wide"><label>Address</label><textarea name="address"><%= member.getAddress() %></textarea></div>
        </div>
        <div class="form-actions">
            <button class="btn btn-green" type="submit">Save Member</button>
            <a class="btn btn-outline-dark" href="${pageContext.request.contextPath}/admin/member/view?id=<%= member.getMemberId() %>">Cancel</a>
        </div>
    </form>
</main>
</body>
</html>
