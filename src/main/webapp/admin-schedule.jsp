<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*" %>
<%
    // --- SAFE INTEGRATION POINT: LOCAL FILE PATH ---
    String baseDir = application.getRealPath("/");
    File dataDir = new File(baseDir + "webappdata");
    File scheduleFile = new File(dataDir, "schedule.txt");

    // Pre-populate mock items if the flat-file doesn't exist yet to keep the system running
    if (!scheduleFile.exists()) {
        try {
            if (!dataDir.exists()) dataDir.mkdirs();
            try (BufferedWriter bw = new BufferedWriter(new FileWriter(scheduleFile))) {
                bw.write("MEM-103,2026-05-22,Coach Alex / CrossFit,09:00 AM - 10:30 AM,BOOKED"); bw.newLine();
                bw.write("MEM-104,2026-05-22,Coach Sarah / Yoga Flow,11:00 AM - 12:15 PM,BOOKED"); bw.newLine();
                bw.write("MEM-105,2026-05-23,Coach Mike / Strength Training,04:00 PM - 05:30 PM,DELETED"); bw.newLine();
                bw.flush();
            }
        } catch(Exception e) {}
    }

    // Read lines from flat file matrix
    List<String[]> scheduleList = new ArrayList<>();
    if (scheduleFile.exists()) {
        try (BufferedReader br = new BufferedReader(new FileReader(scheduleFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length >= 5) {
                    scheduleList.add(parts);
                }
            }
        } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FITNASE | Admin Schedule Manager</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;600;700&family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand-orange: #ff5722;
            --dark-surface: #111111;
            --border-gray: #222222;
        }
        body { 
            font-family: 'Poppins', sans-serif; 
            background: #000; 
            color: #fff; 
            padding: 40px; 
            margin: 0;
        }
        .header { 
            border-bottom: 2px solid var(--brand-orange); 
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            padding-bottom: 15px; 
            margin-bottom: 35px; 
        }
        .header-title {
            font-family: 'Oswald', sans-serif;
            font-size: 1.8rem;
            font-weight: bold;
            letter-spacing: 1.5px;
        }
        .orange { color: var(--brand-orange); }
        
        .btn-group {
            display: flex;
            gap: 12px;
        }
        .btn { 
            font-family: 'Oswald', sans-serif;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 10px 20px; 
            border: none; 
            font-weight: bold; 
            cursor: pointer; 
            border-radius: 3px; 
            text-decoration: none;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: 0.2s;
        }
        .btn-back {
            background: transparent;
            color: white;
            border: 1px solid #444;
        }
        .btn-back:hover {
            border-color: var(--brand-orange);
            color: var(--brand-orange);
        }
        .btn-print { 
            background: var(--brand-orange); 
            color: #000; 
        }
        .btn-print:hover {
            background: #f4511e;
        }

        .panel { 
            background: var(--dark-surface); 
            padding: 30px; 
            border-radius: 4px; 
            border: 1px solid var(--border-gray); 
            box-shadow: 0 15px 40px rgba(0,0,0,0.5);
        }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 14px 16px; text-align: left; border-bottom: 1px solid var(--border-gray); font-size: 0.95rem; }
        th { 
            font-family: 'Oswald', sans-serif;
            color: var(--brand-orange); 
            text-transform: uppercase; 
            letter-spacing: 1px;
            font-size: 1rem;
        }
        td b { color: #fff; font-weight: 600; }
        
        .status-badge {
            font-size: 0.75rem;
            font-weight: bold;
            text-transform: uppercase;
            padding: 4px 10px;
            border-radius: 3px;
            letter-spacing: 0.5px;
        }
        .status-booked { background: rgba(76, 175, 80, 0.15); color: #81c784; }
        .status-deleted { background: rgba(244, 67, 54, 0.15); color: #e57373; }

        @media print { 
            .btn-group { display: none; } 
            body { background: white; color: black; padding: 0; } 
            .panel { border: none; background: white; box-shadow: none; padding: 0; } 
            th { color: black; border-bottom: 2px solid black; } 
            td { border-bottom: 1px solid #ddd; color: black; }
            td b { color: black; }
            .status-booked { color: #2e7d32; background: none; padding: 0; }
            .status-deleted { color: #c62828; background: none; padding: 0; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-title">FIT<span class="orange">NASE</span> | SCHEDULE INTELLIGENCE</div>
    <div class="btn-group">
        <a href="admin-dashboard.jsp" class="btn btn-back"><i class="fas fa-arrow-left"></i> Core Console</a>
        <button class="btn btn-print" onclick="window.print()"><i class="fas fa-print"></i> Print Matrix Report</button>
    </div>
</div>

<div class="panel">
    <table>
        <thead>
            <tr>
                <th>Member ID</th>
                <th>Target Date</th>
                <th>Coach / Class Track</th>
                <th>Session Slot Block</th>
                <th>Current Status</th>
            </tr>
        </thead>
        <tbody>
            <% if (scheduleList.isEmpty()) { %>
                <tr>
                    <td colspan="5" style="text-align: center; color: #666; font-style: italic; padding: 30px;">
                        No active scheduling allocations found inside the file logs.
                    </td>
                </tr>
            <% } else { 
                for (String[] record : scheduleList) { 
                    String memId = record[0].trim();
                    String dateStr = record[1].trim();
                    String trainer = record[2].trim();
                    String slot = record[3].trim();
                    String status = record[4].trim();
            %>
                <tr>
                    <td><b><%= memId %></b></td>
                    <td><%= dateStr %></td>
                    <td><%= trainer %></td>
                    <td><%= slot %></td>
                    <td>
                        <% if ("BOOKED".equalsIgnoreCase(status)) { %>
                            <span class="status-badge status-booked">BOOKED</span>
                        <% } else { %>
                            <span class="status-badge status-deleted">DELETED</span>
                        <% } %>
                    </td>
                </tr>
            <% 
                } 
            } 
            %>
        </tbody>
    </table>
</div>

</body>
</html>