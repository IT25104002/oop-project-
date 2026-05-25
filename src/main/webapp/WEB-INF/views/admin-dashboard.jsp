<%@ page import="java.util.List" %>
<%@ page import="com.fitness.model.Member" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% List<Member> members = (List<Member>) request.getAttribute("members"); %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard | FitPro</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="app-body">
<aside class="sidebar admin">
    <div class="brand"><span>FIT</span>PRO</div>
    <a class="active" href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
    <a href="${pageContext.request.contextPath}/admin/members">Manage Members</a>
    <a href="${pageContext.request.contextPath}/logout">Logout</a>
</aside>
<main class="main-content">
    <header class="page-header">
        <div><p class="eyebrow">Admin Control Center</p><h1>Member Profile Management</h1></div>
        <a class="btn btn-blue" href="${pageContext.request.contextPath}/admin/members">Manage Members</a>
    </header>
    <section class="stats-grid">
        <div class="stat-card"><p>Total Members</p><h2><%= request.getAttribute("totalMembers") %></h2></div>
        <div class="stat-card green"><p>Active Members</p><h2><%= request.getAttribute("activeMembers") %></h2></div>
        <div class="stat-card yellow"><p>Expired Members</p><h2><%= request.getAttribute("expiredMembers") %></h2></div>
    </section>
    <section class="table-card">
        <div class="table-header"><h2>Recent Member Records</h2></div>
        <table>
            <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Plan</th><th>Status</th><th>Action</th></tr></thead>
            <tbody>
            <% for (Member m : members) { %>
                <tr>
                    <td><%= m.getMemberId() %></td>
                    <td><%= m.getFullName() %></td>
                    <td><%= m.getEmail() %></td>
                    <td><%= m.getMembershipPlan() %></td>
                    <td><span class="status-pill <%= m.getStatus().toLowerCase() %>"><%= m.getStatus() %></span></td>
                    <td><a class="small-link" href="${pageContext.request.contextPath}/admin/member/view?id=<%= m.getMemberId() %>">View</a></td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </section>
</main>
</body>
</html>
