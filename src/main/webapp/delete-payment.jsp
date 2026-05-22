<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.util.ArrayList, java.util.List" %>
<%
    // 1. Capture our unique targeting parameters
    String targetMemberId = request.getParameter("memberId");
    String targetPlan = request.getParameter("plan");
    String targetLineIdStr = request.getParameter("lineId");

    if (targetMemberId != null && targetPlan != null && targetLineIdStr != null) {
        int targetLineId = Integer.parseInt(targetLineIdStr);
        
        String filePath = System.getProperty("user.dir") + File.separator + "src" + File.separator + "main" + File.separator + "webapp" + File.separator + "webappdata" + File.separator + "payments.txt";
        File file = new File(filePath);
        
        List<String> updatedLines = new ArrayList<>();
        
        if (file.exists()) {
            // 2. Read the file line by line
            try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                String line;
                int currentLineIndex = 0;
                
                while ((line = br.readLine()) != null) {
                    currentLineIndex++;
                    
                    // Check if this line matches our target line ID exactly
                    if (currentLineIndex == targetLineId) {
                        String[] parts = line.split(",");
                        if (parts.length >= 6 && parts[0].trim().equalsIgnoreCase(targetMemberId) && parts[1].trim().equalsIgnoreCase(targetPlan)) {
                            // Modify the status column (index 5) to Cancelled
                            parts[5] = "Cancelled";
                            // Reconstruct the line
                            line = String.join(",", parts);
                        }
                    }
                    updatedLines.add(line);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            // 3. Write the updated array back to the text file
            try (PrintWriter pw = new PrintWriter(new BufferedWriter(new FileWriter(file, false)))) {
                for (String updatedLine : updatedLines) {
                    pw.println(updatedLine);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    // 4. Silently send the user right back to their updated transaction log view
    response.sendRedirect("payment-history.jsp");
%>