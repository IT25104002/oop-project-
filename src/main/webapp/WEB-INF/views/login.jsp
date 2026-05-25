<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login | FitPro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="auth-body premium-auth-body">
<div class="auth-shell">
    <section class="auth-hero-panel">
        <a class="auth-logo" href="${pageContext.request.contextPath}/"><span>FIT</span>PRO</a>
        <div class="auth-badge">Member Profile Management</div>
        <h1>Train smarter. Manage profiles beautifully.</h1>
        <p>
            Manage fitness profiles, memberships, and member records effortlessly
            in one sleek, professional dashboard designed for a smarter fitness experience.
        </p>


    </section>

    <section class="auth-form-panel">
        <div class="form-glow"></div>
        <form class="auth-card premium-auth-card" method="post" action="${pageContext.request.contextPath}/login">
            <div class="auth-card-header">
                <p class="eyebrow dark">Welcome Back</p>
                <h2>Sign in to FitPro</h2>
                <p>Enter your login details to continue.</p>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert error"><%= request.getAttribute("error") %></div>
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                <div class="alert error"><%= request.getParameter("error") %></div>
            <% } %>
            <% if (request.getParameter("success") != null) { %>
                <div class="alert success"><%= request.getParameter("success") %></div>
            <% } %>

            <label>Email Address</label>
            <div class="input-icon">
                <span>@</span>
                <input type="email" name="email" placeholder="example@fitpro.com" required>
            </div>

            <label>Password</label>
            <div class="input-icon">
                <span>●</span>
                <input type="password" name="password" placeholder="Enter your password" required>
            </div>

            <button class="btn btn-green full auth-submit" type="submit">Login Securely</button>

            <div class="auth-switch-box">
                <span>New member?</span>
                <a href="${pageContext.request.contextPath}/register">Create your account</a>
            </div>

            <a class="back-link" href="${pageContext.request.contextPath}/">Back to Home</a>
        </form>
    </section>
</div>
</body>
</html>
