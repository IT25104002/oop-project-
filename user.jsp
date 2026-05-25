<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.time.LocalDate, java.time.format.DateTimeFormatter" %>
<%
    // 1. Session & Access Verification Layer (Linked to Auth Controller)
    String sessionMemberId = (String) session.getAttribute("memberId");
    String currentName = (String) session.getAttribute("loggedInMemberName");

    // Enforce authentication barrier: Redirect to login if user session context is missing
    if (sessionMemberId == null || sessionMemberId.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }
    sessionMemberId = sessionMemberId.trim();

    String detectedPackage = "BRONZE"; // Default baseline safety tier
    boolean isApprovedAccount = false;  // Financial clearance flag

    // 2. Set up Directories and Flat-Files
    String baseDir = application.getRealPath("/");
    File dataDir = new File(baseDir + "webappdata");
    if (!dataDir.exists()) { dataDir.mkdirs(); }
    
    File structuralDataFile = new File(dataDir, "members.txt");
    File paymentFile = new File(dataDir, "payments.txt"); // FIXED: Matched to your actual file name 'payments.txt'
    File scheduleFile = new File(dataDir, "schedule.txt");

    // 3. Read profile metadata safely from members.txt matching active session
    if (structuralDataFile.exists()) {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(structuralDataFile), "UTF-8"))) {
            String lineEntry;
            while ((lineEntry = reader.readLine()) != null) {
                if (lineEntry.trim().isEmpty()) continue;
                String[] segments = lineEntry.split(",");
                
                // Confirm matching authenticated user profile database record
                if (segments.length >= 3 && segments[0].trim().equalsIgnoreCase(sessionMemberId)) {
                    currentName = segments[2].trim();
                    
                    // Dynamic package scanning sequence across structural columns
                    for (String col : segments) {
                        String cleanCol = col.trim().toUpperCase();
                        if ("GOLD".equals(cleanCol)) {
                            detectedPackage = "GOLD";
                            break;
                        } else if ("SILVER".equals(cleanCol)) {
                            detectedPackage = "SILVER";
                        }
                    }
                    break;
                }
            }
        } catch (Exception e) {}
    }

    // 4. Financial Audit Verification Check against payments.txt
    if (paymentFile.exists()) {
        try (BufferedReader paymentReader = new BufferedReader(new InputStreamReader(new FileInputStream(paymentFile), "UTF-8"))) {
            String payLine;
            while ((payLine = paymentReader.readLine()) != null) {
                if (payLine.trim().isEmpty()) continue;
                String[] paySegments = payLine.split(",");
                
                // Matched to your ledger format: TXN_ID, Member_ID, Date, Amount, Tier, Status
                if (paySegments.length >= 2 && paySegments[1].trim().equalsIgnoreCase(sessionMemberId)) {
                    // Scan line from right to left to find the 'APPROVED' or 'PAID' status token dynamically
                    for (String segment : paySegments) {
                        String cleanStatus = segment.trim().toUpperCase();
                        if ("APPROVED".equals(cleanStatus) || "PAID".equals(cleanStatus)) {
                            isApprovedAccount = true;
                            break;
                        }
                    }
                }
            }
        } catch (Exception e) {}
    }

    // Fallback block overrides access authorization mapping if account verification fails
    if (!isApprovedAccount) {
        detectedPackage = "BRONZE"; 
    }

    // --- PREMIUM TIERS NUTRITION TRACKER LOGIC ---
    String userDietContent = "";
    boolean isPremiumUser = "GOLD".equalsIgnoreCase(detectedPackage) || "SILVER".equalsIgnoreCase(detectedPackage);

    if (isPremiumUser) {
        File userDietFile = new File(dataDir, sessionMemberId.toUpperCase() + "_diet.txt");
        if (userDietFile.exists()) {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(userDietFile), "UTF-8"))) {
                String line;
                while ((line = br.readLine()) != null) {
                    sb.append(line).append("\n");
                }
                userDietContent = sb.toString().trim();
            } catch (Exception e) {
                userDietContent = "Error parsing personal nutritional target profile matrix.";
            }
        } else {
            // Default automated fallback if admin hasn't generated a tailored record yet
            userDietContent = "=== DAILY NUTRITIONAL MACRO MATRIX ===\n" +
                               "Breakfast (07:00 AM): Oats, Whey Protein & Almonds\n" +
                               "Lunch (01:00 PM): 200g Grilled Chicken Breast, Basmati Rice & Broccoli\n" +
                               "Dinner (08:00 PM): Baked Salmon or Lean Beef with Sweet Potatoes\n\n" +
                               "Target: 2500 kcal | 180g P / 220g C / 65g F\n\n" +
                               "(Standard baseline track profile. Request custom parameters from coach.)";
        }
    }

    // 5. TRANSACTION ENGINE: Handle Forms 
    String reqAction = request.getParameter("action");
    String jsRedirectStatus = null;

    if ("createBooking".equals(reqAction)) {
        // Enforce dual condition security check (Tier Access + Active Cleared Status)
        if (!isApprovedAccount || !"GOLD".equalsIgnoreCase(detectedPackage)) {
            jsRedirectStatus = "unauthorized";
        } else {
            String trainerAndClass = request.getParameter("trainerAndClass");
            String timeSlot = request.getParameter("timeSlot");
            String bookingDay = request.getParameter("bookingDay");
            String targetDate = LocalDate.now().toString(); 

            // Read existing entries to run counter checks
            int activeBookingCount = 0;
            if (scheduleFile.exists()) {
                try (BufferedReader br = new BufferedReader(new FileReader(scheduleFile))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        String[] parts = line.split(",");
                        if (parts.length >= 5 && parts[0].trim().equalsIgnoreCase(sessionMemberId) && "BOOKED".equalsIgnoreCase(parts[4].trim())) {
                            activeBookingCount++;
                        }
                    }
                } catch(Exception e){}
            }

            if (activeBookingCount >= 2) {
                jsRedirectStatus = "limit";
            } else {
                String rawRow = sessionMemberId + "," + targetDate + " (" + bookingDay + ")," + trainerAndClass + "," + timeSlot + ",BOOKED";
                try (BufferedWriter bw = new BufferedWriter(new FileWriter(scheduleFile, true))) {
                    bw.write(rawRow);
                    bw.newLine();
                    bw.flush();
                    jsRedirectStatus = "success";
                } catch (Exception e) {}
            }
        }
    } 
    else if ("cancelBooking".equals(reqAction)) {
        String targetClass = request.getParameter("targetClass");
        String targetSlot = request.getParameter("targetSlot");
        
        List<String> updatedLines = new ArrayList<>();
        if (scheduleFile.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(scheduleFile))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] parts = line.split(",");
                    if (parts.length >= 5 && 
                        parts[0].trim().equalsIgnoreCase(sessionMemberId) && 
                        parts[2].trim().equalsIgnoreCase(targetClass) && 
                        parts[3].trim().equalsIgnoreCase(targetSlot) && 
                        "BOOKED".equalsIgnoreCase(parts[4].trim())) {
                        
                        line = parts[0] + "," + parts[1] + "," + parts[2] + "," + parts[3] + ",DELETED";
                    }
                    updatedLines.add(line);
                }
            } catch(Exception e){}

            try (BufferedWriter bw = new BufferedWriter(new FileWriter(scheduleFile, false))) {
                for (String l : updatedLines) {
                    bw.write(l); bw.newLine();
                }
                bw.flush();
                jsRedirectStatus = "deleted";
            } catch(Exception e){}
        }
    }

    // 6. DATA QUERIES: Collect Live and Historic lists for logged-in user
    List<String[]> currentActiveBookings = new ArrayList<>();
    List<String[]> pastHistoryLogs = new ArrayList<>();
    int liveUserCounter = 0;

    if (scheduleFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(scheduleFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length >= 5 && parts[0].trim().equalsIgnoreCase(sessionMemberId)) {
                    if ("BOOKED".equalsIgnoreCase(parts[4].trim())) {
                        currentActiveBookings.add(parts);
                        liveUserCounter++;
                    } else {
                        pastHistoryLogs.add(parts);
                    }
                }
            }
        } catch(Exception e){}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FITNASE | User Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;600;700&family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        :root {
            --brand-orange: #ff5722;
            --brand-glow: rgba(255, 87, 34, 0.35);
            --dark-bg: #0f0f0f;
            --card-glass: rgba(20, 20, 20, 0.85);
            --card-border: rgba(255, 87, 34, 0.15);
            --text-gray: #bbbbbb;
        }
        body { 
            font-family: 'Poppins', sans-serif; 
            background: linear-gradient(rgba(10, 10, 10, 0.9), rgba(10, 10, 10, 0.9)), url('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1350&q=80'); 
            background-size: cover; background-position: center; background-attachment: fixed;
            color: #fff; margin: 0; padding: 0; min-height: 100vh;
        }
        header { 
            background: rgba(0, 0, 0, 0.9); padding: 20px 50px; border-bottom: 2px solid var(--brand-orange); 
            display: flex; justify-content: space-between; align-items: center; box-shadow: 0 4px 20px rgba(0,0,0,0.5); box-sizing: border-box;
        }
        .logo { font-family: 'Oswald', sans-serif; font-size: 1.8rem; font-weight: bold; letter-spacing: 2px; text-decoration: none; color: white;}
        .logo span { color: var(--brand-orange); }
        .main-container { max-width: 1200px; margin: 40px auto; padding: 0 50px; display: flex; gap: 40px; box-sizing: border-box; }
        .panel { background: var(--card-glass); padding: 30px; border-radius: 4px; border: 1px solid var(--card-border); margin-bottom: 30px; position: relative; backdrop-filter: blur(8px); }
        .left { width: 40%; } .right { width: 60%; }
        h3 { font-family: 'Oswald', sans-serif; color: var(--brand-orange); text-transform: uppercase; margin-top: 0; letter-spacing: 1px; border-left: 4px solid var(--brand-orange); padding-left: 12px; font-size: 1.4rem; }
        .btn-orange { width: 100%; padding: 14px; background: var(--brand-orange); color: #fff; border: none; font-family: 'Oswald', sans-serif; font-size: 1rem; letter-spacing: 1px; font-weight: bold; cursor: pointer; border-radius: 2px; text-transform: uppercase; transition: 0.2s; }
        .btn-orange:hover:not(:disabled) { background: #e04c1b; box-shadow: 0 0 15px var(--brand-glow); }
        .locked-overlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: rgba(10, 10, 10, 0.96); border-radius: 4px; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; padding: 20px; box-sizing: border-box; z-index: 10; border: 1px dashed rgba(255, 87, 34, 0.3); }
        .locked-overlay i { font-size: 2.5rem; color: var(--brand-orange); margin-bottom: 15px; }
        .locked-overlay h4 { font-family: 'Oswald', sans-serif; color: #fff; text-transform: uppercase; margin: 0 0 8px 0; font-size: 1.3rem; letter-spacing: 1px; }
        .locked-overlay p { color: #888; font-size: 0.85rem; max-width: 85%; line-height: 1.5; margin: 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { font-family: 'Oswald', sans-serif; text-align: left; color: var(--brand-orange); padding: 12px; border-bottom: 2px solid #333; text-transform: uppercase; font-size: 0.85rem; letter-spacing: 1px; }
        td { padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 0.9rem; color: var(--text-gray); }
        select { width: 100%; padding: 12px; background: #000; color: white; border: 1px solid #333; margin-bottom: 20px; border-radius: 2px; font-family: inherit; }
        select:focus { border-color: var(--brand-orange); outline: none; }
        label { font-size: 11px; color: #888; margin-bottom: 6px; display: block; text-transform: uppercase; letter-spacing: 1px; font-weight: 500; }
        .dashboard-btn { color: white; text-decoration: none; font-family: 'Oswald', sans-serif; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; border: 1px solid #444; padding: 8px 16px; border-radius: 4px; background: transparent; transition: 0.3s; }
        .dashboard-btn:hover { border-color: var(--brand-orange); color: var(--brand-orange); }
        .user-pill { background: rgba(255, 87, 34, 0.1); padding: 8px 18px; border-radius: 4px; border: 1px solid var(--brand-orange); font-size: 0.85rem; font-weight: 600; letter-spacing: 1px; display: flex; align-items: center; gap: 10px; }
        pre { background: #000; color: #00ff66; padding: 20px; border-radius: 2px; border: 1px solid #222; font-family: 'Courier New', monospace; font-size: 0.9rem; line-height: 1.6; white-space: pre-wrap; margin: 15px 0 0 0; }
    </style>
</head>
<body>

<header>
    <a href="Dashboard.jsp" class="logo">FIT<span>NASE</span></a>
    <div style="display: flex; align-items: center; gap: 20px;">
        <a href="Dashboard.jsp" class="dashboard-btn"><i class="fas fa-arrow-left"></i> Hub Terminal</a>
        <div class="user-pill"><i class="fas fa-user-ninja"></i> ID: <%= sessionMemberId %> | <%= currentName %></div>
    </div>
</header>

<div class="main-container">
    <div class="left">
        <div class="panel">
            <% if (!"GOLD".equalsIgnoreCase(detectedPackage)) { %>
                <div class="locked-overlay">
                    <i class="fas fa-lock"></i>
                    <h4>Gold Access Required</h4>
                    <p>Class scheduling and personal coach allocations are restricted exclusively to verified, approved Gold Tier gym members.</p>
                </div>
            <% } %>

            <h3>Book Session</h3>
            <p style="font-size: 12px; margin-bottom: 20px; color: <%= liveUserCounter >= 2 ? "#ff4444" : "#4CAF50" %>">
                <i class="fas fa-info-circle"></i> Weekly Limit: <%= liveUserCounter %> / 2 used
            </p>
            
            <form action="user.jsp" method="post">
                <input type="hidden" name="action" value="createBooking">

                <label>Select Class Type</label>
                <select name="trainerAndClass">
                    <option value="Cardio Blast (Mr. Saman)">Cardio Blast (Mr. Saman)</option>
                    <option value="Yoga & Flexibility (Mrs. Nimali)">Yoga & Flexibility (Mrs. Nimali)</option>
                    <option value="Power Lifting (Mr. Kamal)">Power Lifting (Mr. Kamal)</option>
                </select>

                <label>Preferred Time</label>
                <select name="timeSlot">
                    <option value="Morning Session (06:00 AM - 09:00 AM)">Morning Session (06:00 AM - 09:00 AM)</option>
                    <option value="Evening Session (05:00 PM - 08:00 PM)">Evening Session (05:00 PM - 08:00 PM)</option>
                </select>

                <label>Select Day</label>
                <select name="bookingDay">
                    <option value="MONDAY">Monday</option>
                    <option value="TUESDAY">Tuesday</option>
                    <option value="WEDNESDAY">Wednesday</option>
                    <option value="THURSDAY">Thursday</option>
                    <option value="FRIDAY">Friday</option>
                </select>

                <button type="submit" class="btn-orange" <%= liveUserCounter >= 2 ? "disabled style='background:#222; cursor:not-allowed; color:#555; border:1px solid #333;'" : "" %>>
                    <%= liveUserCounter >= 2 ? "LIMIT REACHED" : "CONFIRM BOOKING TERMINAL" %>
                </button>
            </form>
        </div>

        <div class="panel">
            <h3><%= detectedPackage %> Package Details</h3>
            <ul style="list-style:none; padding:0; font-size:14px; color:var(--text-gray); margin-top: 15px;">
                <li style="margin-bottom: 12px;"><i class="fas fa-check orange"></i> Unlimited Gym Access</li>
                <% if ("GOLD".equalsIgnoreCase(detectedPackage)) { %>
                    <li style="margin-bottom: 12px;"><i class="fas fa-check orange"></i> All Premium Classes (Cardio/Yoga/Power)</li>
                    <li style="margin-bottom: 12px;"><i class="fas fa-check orange"></i> 1-on-1 Personal Trainer Support</li>
                <% } else if ("SILVER".equalsIgnoreCase(detectedPackage)) { %>
                    <li style="margin-bottom: 12px;"><i class="fas fa-check orange"></i> Yoga & Cardio Shared Track Access</li>
                <% } else { %>
                    <li style="margin-bottom: 12px;"><i class="fas fa-check orange"></i> Standard Base Gym Equipment Only</li>
                <% } %>
            </ul>
        </div>
    </div>

    <div class="right">
        <% if (isPremiumUser) { %>
            <div class="panel">
                <h3><i class="fas fa-utensils"></i> My Personalized Nutrition Tracker</h3>
                <label>Active Strategy Frame &bull; Tier Allocation: <%= detectedPackage %></label>
                <pre><%= userDietContent %></pre>
            </div>
        <% } %>

        <div class="panel">
            <h3>My Active Schedule</h3>
            <table>
                <thead>
                    <tr>
                        <th>Date / Day</th>
                        <th>Coach & Track Class</th>
                        <th>Time Slot Frame</th>
                        <th style="text-align: center;">Cancel</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (currentActiveBookings.isEmpty()) { %>
                        <tr>
                            <td colspan="4" style="text-align: center; padding: 40px; color: #555;">No active reservations found for this cycle.</td>
                        </tr>
                    <% } else { 
                        for (String[] booking : currentActiveBookings) { %>
                            <tr>
                                <td><i class="far fa-calendar-alt orange"></i> &nbsp; <%= booking[1] %></td>
                                <td><b><%= booking[2] %></b></td>
                                <td><%= booking[3] %></td>
                                <td style="text-align: center;">
                                    <form action="user.jsp" method="post" onsubmit="return confirmDelete(event, this);">
                                        <input type="hidden" name="action" value="cancelBooking">
                                        <input type="hidden" name="targetClass" value="<%= booking[2] %>">
                                        <input type="hidden" name="targetSlot" value="<%= booking[3] %>">
                                        <button type="submit" style="background:none; border:none; color:#ff4444; cursor:pointer; font-size: 1.1rem;">
                                            <i class="fas fa-trash-alt"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                    <%  } 
                    } %>
                </tbody>
            </table>
        </div>

        <div class="panel" style="opacity:0.65;">
            <h3>Booking History</h3>
            <% if (pastHistoryLogs.isEmpty()) { %>
                <div style="padding: 15px 0; color: #555; font-size: 13px;">No past historical entries log.</div>
            <% } else { 
                for (String[] hist : pastHistoryLogs) { %>
                    <div style="padding:12px 0; border-bottom:1px solid rgba(255,255,255,0.05); font-size:13px; display: flex; justify-content: space-between;">
                        <span><%= hist[1] %> — <b><%= hist[2] %></b></span> 
                        <span class="orange" style="text-transform: uppercase; font-weight: bold; font-size: 0.75rem;"><%= hist[4] %></span>
                    </div>
            <%  } 
            } %>
        </div>
    </div>
</div>

<script>
    <% if (jsRedirectStatus != null) { %>
        const status = "<%= jsRedirectStatus %>";
        if(status === 'success') {
            Swal.fire({ icon: 'success', title: 'Booking Successful!', background: '#111', color: '#fff', confirmButtonColor: '#ff5722' });
        } else if(status === 'limit') {
            Swal.fire({ icon: 'error', title: 'Limit Exceeded!', text: 'Maximum 2 active bookings per week allowed.', background: '#111', color: '#fff', confirmButtonColor: '#ff5722' });
        } else if(status === 'deleted') {
            Swal.fire({ icon: 'info', title: 'Session Cancelled', text: 'Your booking reservation has been successfully removed.', background: '#111', color: '#fff', confirmButtonColor: '#ff5722' });
        } else if(status === 'unauthorized') {
            Swal.fire({ icon: 'error', title: 'Access Denied', text: 'Booking requests are strictly reserved for approved Gold plan members.', background: '#111', color: '#fff', confirmButtonColor: '#ff5722' });
        }
    <% } %>

    function confirmDelete(e, form) {
        e.preventDefault();
        Swal.fire({ 
            title: 'Cancel Session?', 
            text: "Are you sure you want to drop this reservation?", 
            icon: 'warning', 
            showCancelButton: true, 
            confirmButtonColor: '#ff4444', 
            cancelButtonColor: '#333',
            confirmButtonText: 'Yes, Cancel It',
            background: '#111', 
            color: '#fff' 
        }).then((result) => { 
            if (result.isConfirmed) form.submit(); 
        });
    }
</script>
</body>
</html>
