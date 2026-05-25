<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>FitPro | Fitness Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="landing-body">
<nav class="top-nav glass-nav">
    <div class="brand"><span>FIT</span>PRO</div>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/login" class="btn btn-blue">Login</a>
        <a href="${pageContext.request.contextPath}/register" class="btn btn-green">Register</a>
    </div>
</nav>
<section class="hero-section">
    <div class="hero-content">
        <p class="eyebrow">Premium Fitness Management</p>
        <h1>Member Profile Management System</h1>
        <p class="hero-text">Manage member profiles, fitness goals, memberships, and account details seamlessly in one secure, professional gym management website.
</p>
        <div class="hero-actions">
            <a class="btn btn-green" href="${pageContext.request.contextPath}/register">Register Now</a>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/login">Member Login</a>
            <a class="btn btn-outline" href="#features">View Features</a>
        </div>
    </div>
    <div class="hero-card premium-card">
        <div class="profile-orb">FP</div>
        <h3>Smart Member Profiles</h3>
        <p>Member details, membership plans, profile photos, fitness goals, account status, and admin tools—all managed in one place.</p>
        <div class="metric-grid">
            <div><strong>100%</strong><span>Secure</span></div>
            <div><strong>24/7</strong><span>Access</span></div>
            <div><strong>Pro</strong><span>Theme</span></div>
        </div>
    </div>
</section>
<section id="features" class="feature-section">
    <div class="section-title">
        <h2>Powerful Gym Management Features</h2>
    </div>
    <div class="feature-grid">
        <div class="feature-card"><h3>Smart Member Profiles</h3><p>View and manage complete member information, including personal details, contact info, profile image, and fitness goals.</p></div>
        <div class="feature-card"><h3>Easy Profile Updates</h3><p>Members can update their details anytime, keeping their profile, membership data, and progress goals accurate.</p></div>
        <div class="feature-card"><h3>Secure Admin Control</h3><p>Admins can search, edit, activate, deactivate, and maintain member records through a professional management panel.</p></div>
    </div>
</section>
</body>
</html>
