<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%!
    private String old(jakarta.servlet.http.HttpServletRequest request, String name) {
        Object value = request.getAttribute(name);
        return value == null ? "" : String.valueOf(value).replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
    }
    private String selected(jakarta.servlet.http.HttpServletRequest request, String name, String value) {
        Object oldValue = request.getAttribute(name);
        return value.equals(oldValue) ? "selected" : "";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Register | FitPro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="auth-body premium-auth-body">
<div class="auth-shell register-shell">
    <section class="auth-hero-panel register-info-panel">
        <a class="auth-logo" href="${pageContext.request.contextPath}/"><span>FIT</span>PRO</a>
        <div class="auth-badge yellow-badge">New Member Registration</div>
        <h1>Create your premium fitness profile.</h1>
        <p>
           Create your member account in seconds and start your fitness journey with us. Once registered, you can log in anytime to
           update your profile, manage your details, and enjoy a smoother fitness experience.
        </p>
        <div class="register-progress-card">
            <div><b>Step 1</b><span>Create your fitness profile</span></div>
            <div><b>Step 2</b><span>Choose your membership plan</span></div>
            <div><b>Step 3</b><span>Start your fitness journey</span></div>
            <div><b>Step 4</b><span>Track your progress anytime</span></div>
            <div><b>Step 5</b><span>Stay connected with your gym community</span></div>
        </div>
    </section>

    <section class="auth-form-panel register-form-panel">
        <div class="form-glow"></div>
        <form class="auth-card premium-auth-card register-card" method="post" action="${pageContext.request.contextPath}/register">
            <div class="auth-card-header">
                <p class="eyebrow dark">Join FitPro</p>
                <h2>Member Registration</h2>
                <p>Fill the details below to create a new member profile.</p>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert error"><%= request.getAttribute("error") %></div>
            <% } %>

            <div class="form-grid register-grid">
                <div class="wide">
                    <label>Full Name <span class="required">*</span></label>
                    <input type="text" name="fullName" placeholder="Enter full name" required value="<%= old(request, "fullName") %>">
                </div>

                <div>
                    <label>Email Address <span class="required">*</span></label>
                    <input type="email" name="email" placeholder="member@email.com" required value="<%= old(request, "email") %>">
                </div>

                <div>
                    <label>Phone Number <span class="required">*</span></label>
                    <input type="text" name="phone" placeholder="+94771234567" required value="<%= old(request, "phone") %>">
                </div>

                <div>
                    <label>Date of Birth</label>
                    <input type="date" name="dob" value="<%= old(request, "dob") %>">
                </div>

                <div>
                    <label>Gender</label>
                    <select name="gender">
                        <option value="">Select Gender</option>
                        <option value="Male" <%= selected(request, "gender", "Male") %>>Male</option>
                        <option value="Female" <%= selected(request, "gender", "Female") %>>Female</option>
                        <option value="Other" <%= selected(request, "gender", "Other") %>>Other</option>
                    </select>
                </div>

                <div>
                    <label>Height cm</label>
                    <input type="number" step="0.1" name="height" placeholder="172" value="<%= old(request, "height") %>">
                </div>

                <div>
                    <label>Weight kg</label>
                    <input type="number" step="0.1" name="weight" placeholder="68" value="<%= old(request, "weight") %>">
                </div>

                <div>
                    <label>Fitness Goal</label>
                    <select name="fitnessGoal">
                        <option value="General Fitness" <%= selected(request, "fitnessGoal", "General Fitness") %>>General Fitness</option>
                        <option value="Weight Loss" <%= selected(request, "fitnessGoal", "Weight Loss") %>>Weight Loss</option>
                        <option value="Muscle Gain" <%= selected(request, "fitnessGoal", "Muscle Gain") %>>Muscle Gain</option>
                        <option value="Strength Training" <%= selected(request, "fitnessGoal", "Strength Training") %>>Strength Training</option>
                        <option value="Endurance" <%= selected(request, "fitnessGoal", "Endurance") %>>Endurance</option>
                    </select>
                </div>

                <div>
                    <label>Membership Plan</label>
                    <select name="membershipPlan">
                        <option value="Premium Monthly" <%= selected(request, "membershipPlan", "Premium Monthly") %>>Premium Monthly</option>
                        <option value="Quarterly" <%= selected(request, "membershipPlan", "Quarterly") %>>Quarterly</option>
                        <option value="Yearly" <%= selected(request, "membershipPlan", "Yearly") %>>Yearly</option>
                    </select>
                </div>

                <div>
                    <label>Emergency Contact</label>
                    <input type="text" name="emergencyContact" placeholder="Emergency phone" value="<%= old(request, "emergencyContact") %>">
                </div>

                <div class="wide">
                    <label>Address</label>
                    <textarea name="address" placeholder="Enter address"><%= old(request, "address") %></textarea>
                </div>

                <div>
                    <label>Password <span class="required">*</span></label>
                    <input type="password" name="password" placeholder="Strong password" required>
                    <small class="field-help">Minimum 8 characters with uppercase, number, and special character. Example: Member@123</small>
                </div>

                <div>
                    <label>Confirm Password <span class="required">*</span></label>
                    <input type="password" name="confirmPassword" placeholder="Confirm password" required>
                </div>
            </div>

            <button class="btn btn-green full auth-submit" type="submit">Create Member Account</button>

            <div class="auth-switch-box">
                <span>Already registered?</span>
                <a href="${pageContext.request.contextPath}/login">Login here</a>
            </div>

            <a class="back-link" href="${pageContext.request.contextPath}/">Back to Home</a>
        </form>
    </section>
</div>
</body>
</html>
