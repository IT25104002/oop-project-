<%@ page import="java.util.List" %>
<%@ page import="com.fitness.model.Member" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% List<Member> members = (List<Member>) request.getAttribute("members"); %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Members | FitPro</title>
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
    <header class="page-header"><div><p class="eyebrow">Admin Maintenance</p><h1>Manage Member Profiles</h1></div></header>
    <% if (request.getParameter("success") != null) { %><div class="alert success"><%= request.getParameter("success") %></div><% } %>
    <% if (request.getParameter("error") != null) { %><div class="alert error"><%= request.getParameter("error") %></div><% } %>
    <form class="search-bar" method="get" action="${pageContext.request.contextPath}/admin/members">
        <input name="q" placeholder="Search by ID, name, email, or status" value="<%= request.getAttribute("q") %>">
        <button class="btn btn-green" type="submit">Search</button>
        <a class="btn btn-outline-dark" href="${pageContext.request.contextPath}/admin/members">Clear</a>
    </form>
    <section class="table-card">
        <table>
            <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Phone</th><th>Plan</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
            <% for (Member m : members) { if (!m.isAdmin()) { %>
                <tr>
                    <td><%= m.getMemberId() %></td>
                    <td><%= m.getFullName() %></td>
                    <td><%= m.getEmail() %></td>
                    <td><%= m.getPhone() %></td>
                    <td><%= m.getMembershipPlan() %></td>
                    <td><span class="status-pill <%= m.getStatus().toLowerCase() %>"><%= m.getStatus() %></span></td>
                    <td>
                        <a class="small-link" href="${pageContext.request.contextPath}/admin/member/view?id=<%= m.getMemberId() %>">View</a>
                        <a class="small-link yellow-link" href="${pageContext.request.contextPath}/admin/member/edit?id=<%= m.getMemberId() %>">Edit</a>
                        <form class="inline-delete-form" method="post" action="${pageContext.request.contextPath}/admin/member/delete" onsubmit="return confirm('Are you sure you want to delete this member? This will remove the record from members.txt.');">
                            <input type="hidden" name="id" value="<%= m.getMemberId() %>">
                            <button class="small-link danger-link" type="submit">Delete</button>
                        </form>
                    </td>
                </tr>
            <% }} %>
            </tbody>
        </table>
    </section>
</main>
</body>
</html>
