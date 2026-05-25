<%@ page import="com.fitness.model.Member" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% Member member = (Member) request.getAttribute("member"); %>
<!DOCTYPE html>
<html>
<head>
    <title>View Member | FitPro</title>
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
    <header class="page-header">
        <div><p class="eyebrow">Member Record</p><h1><%= member.getFullName() %></h1></div>
        <div class="header-actions">
            <a class="btn btn-blue" href="${pageContext.request.contextPath}/admin/member/edit?id=<%= member.getMemberId() %>">Edit Member</a>
            <form class="inline-delete-form" method="post" action="${pageContext.request.contextPath}/admin/member/delete" onsubmit="return confirm('Are you sure you want to delete this member? This will remove the record from members.txt.');">
                <input type="hidden" name="id" value="<%= member.getMemberId() %>">
                <button class="btn btn-red" type="submit">Delete Member</button>
            </form>
            <a class="btn btn-outline-dark" href="${pageContext.request.contextPath}/admin/members">Back</a>
        </div>
    </header>
    <% if (request.getParameter("success") != null) { %><div class="alert success"><%= request.getParameter("success") %></div><% } %>
    <section class="profile-layout">
        <div class="profile-card premium-card">
            <div class="avatar-large">
                <% if (member.getProfilePicture() != null) { %>
                    <img src="${pageContext.request.contextPath}/profile-photo?memberId=<%= member.getMemberId() %>" alt="Profile Picture">
                <% } else { %><span><%= member.getFullName().substring(0,1).toUpperCase() %></span><% } %>
            </div>
            <h2><%= member.getFullName() %></h2>
            <p><%= member.getEmail() %></p>
            <span class="status-pill <%= member.getStatus().toLowerCase() %>"><%= member.getStatus() %></span>
        </div>
        <div class="details-grid">
            <div class="info-card"><h3>Personal</h3><p><strong>ID:</strong> <%= member.getMemberId() %></p><p><strong>DOB:</strong> <%= member.getDob() %></p><p><strong>Gender:</strong> <%= member.getGender() %></p></div>
            <div class="info-card"><h3>Contact</h3><p><strong>Phone:</strong> <%= member.getPhone() %></p><p><strong>Address:</strong> <%= member.getAddress() %></p><p><strong>Emergency:</strong> <%= member.getEmergencyContact() %></p></div>
            <div class="info-card"><h3>Fitness</h3><p><strong>Height:</strong> <%= member.getHeight() %> cm</p><p><strong>Weight:</strong> <%= member.getWeight() %> kg</p><p><strong>Goal:</strong> <%= member.getFitnessGoal() %></p></div>
            <div class="info-card"><h3>Membership</h3><p><strong>Plan:</strong> <%= member.getMembershipPlan() %></p><p><strong>Join:</strong> <%= member.getJoinDate() %></p><p><strong>Expiry:</strong> <%= member.getExpiryDate() %></p><p><strong>Payment:</strong> <%= member.getPaymentStatus() %></p></div>
        </div>
    </section>
</main>
</body>
</html>
