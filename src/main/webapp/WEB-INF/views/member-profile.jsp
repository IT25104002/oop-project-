<%@ page import="com.fitness.model.Member" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% Member member = (Member) request.getAttribute("member"); %>
<!DOCTYPE html>
<html>
<head>
    <title>My Profile | FitPro</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="app-body">
<aside class="sidebar">
    <div class="brand"><span>FIT</span>PRO</div>
    <a class="active" href="${pageContext.request.contextPath}/member/profile">My Profile</a>
    <a href="${pageContext.request.contextPath}/member/edit">Edit Profile</a>
    <a href="${pageContext.request.contextPath}/member/change-password">Change Password</a>
    <a href="${pageContext.request.contextPath}/logout">Logout</a>
</aside>
<main class="main-content">
    <header class="page-header">
        <div><p class="eyebrow">Member Dashboard</p><h1>My Profile</h1></div>
        <a class="btn btn-blue" href="${pageContext.request.contextPath}/member/edit">Edit Profile</a>
    </header>
    <% if (request.getParameter("success") != null) { %><div class="alert success"><%= request.getParameter("success") %></div><% } %>
    <% if (request.getParameter("error") != null) { %><div class="alert error"><%= request.getParameter("error") %></div><% } %>

    <section class="profile-layout">
        <div class="profile-card premium-card">
            <div class="avatar-large">
                <% if (member.getProfilePicture() != null) { %>
                    <img src="${pageContext.request.contextPath}/profile-photo?memberId=<%= member.getMemberId() %>" alt="Profile Picture">
                <% } else { %>
                    <span><%= member.getFullName().substring(0,1).toUpperCase() %></span>
                <% } %>
            </div>
            <h2><%= member.getFullName() %></h2>
            <p><%= member.getEmail() %></p>
            <span class="status-pill <%= member.getStatus().toLowerCase() %>"><%= member.getStatus() %></span>
            <form class="upload-form" method="post" enctype="multipart/form-data" action="${pageContext.request.contextPath}/member/upload-photo">
                <input type="file" name="profilePicture" accept="image/png,image/jpeg,image/jpg" required>
                <button class="btn btn-yellow full" type="submit">Upload Photo</button>
            </form>
        </div>
        <div class="details-grid">
            <div class="info-card"><h3>Personal Details</h3>
                <p><strong>Member ID:</strong> <%= member.getMemberId() %></p>
                <p><strong>Full Name:</strong> <%= member.getFullName() %></p>
                <p><strong>Date of Birth:</strong> <%= member.getDob() %></p>
                <p><strong>Gender:</strong> <%= member.getGender() %></p>
            </div>
            <div class="info-card"><h3>Contact Details</h3>
                <p><strong>Email:</strong> <%= member.getEmail() %></p>
                <p><strong>Phone:</strong> <%= member.getPhone() %></p>
                <p><strong>Address:</strong> <%= member.getAddress() %></p>
                <p><strong>Emergency:</strong> <%= member.getEmergencyContact() %></p>
            </div>
            <div class="info-card"><h3>Fitness Details</h3>
                <p><strong>Height:</strong> <%= member.getHeight() %> cm</p>
                <p><strong>Weight:</strong> <%= member.getWeight() %> kg</p>
                <p><strong>Fitness Goal:</strong> <%= member.getFitnessGoal() %></p>
            </div>
            <div class="info-card"><h3>Membership Details</h3>
                <p><strong>Plan:</strong> <%= member.getMembershipPlan() %></p>
                <p><strong>Join Date:</strong> <%= member.getJoinDate() %></p>
                <p><strong>Expiry Date:</strong> <%= member.getExpiryDate() %></p>
                <p><strong>Payment:</strong> <%= member.getPaymentStatus() %></p>
            </div>
        </div>
    </section>
</main>
</body>
</html>
