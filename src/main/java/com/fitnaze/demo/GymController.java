package com.fitnaze.demo;

import com.fitnaze.demo.Schedule;
import com.fitnaze.demo.GymService;
import com.fitnaze.demo.DietPlan;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

@Controller
public class GymController {
    private final GymService service;

    public GymController(GymService service) { 
        this.service = service; 
    }

    @PostMapping("/registerMember")
    public String registerMember(@RequestParam String name, 
                                 @RequestParam String pass,
                                 @RequestParam String age, 
                                 @RequestParam String phone,
                                 @RequestParam String packageTier,
                                 HttpSession session,
                                 Model model) {
        try {
            String baseDir = System.getProperty("user.dir");
            File memberFile = new File(baseDir + File.separator + "src" + File.separator + "main" + File.separator + "webappdata" + File.separator + "members.txt");
            if (!memberFile.exists()) {
                memberFile = new File(baseDir + File.separator + "webappdata" + File.separator + "members.txt");
            }
            if (!memberFile.getParentFile().exists()) {
                memberFile.getParentFile().mkdirs();
            }

            int nextIdNum = 101; 
            if (memberFile.exists()) {
                try (BufferedReader br = new BufferedReader(new FileReader(memberFile))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        if (line.trim().isEmpty()) continue;
                        String[] parts = line.split(",");
                        if (parts.length > 0 && parts[0].trim().startsWith("MEM-")) {
                            try {
                                int currentId = Integer.parseInt(parts[0].trim().substring(4).trim());
                                if (currentId >= nextIdNum) {
                                    nextIdNum = currentId + 1;
                                }
                            } catch (NumberFormatException e) {
                                // Skip format layout reading anomalies safely
                            }
                        }
                    }
                }
            }
            String generatedId = "MEM-" + nextIdNum;
            String defaultExpDate = LocalDate.now().plusYears(1).toString();

            String recordRow = String.format("%s,%s,%s,%s,%s,%s",
                    generatedId,
                    name.trim(),
                    age.trim(),
                    phone.trim(),
                    packageTier.trim(),
                    defaultExpDate
            );

            try (BufferedWriter bw = new BufferedWriter(new FileWriter(memberFile, true))) {
                bw.write(recordRow);
                bw.newLine();
                bw.flush();
            }

            session.setAttribute("loggedInMemberId", generatedId);
            session.setAttribute("loggedInMemberName", name.trim());
            model.addAttribute("alertMessage", "Registration Completed! Your System ID is: " + generatedId);
            
            return "redirect:/user?status=success";
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/register.jsp?error=system_write_failure";
        }
    }

    @GetMapping("/user")
    public String showUserPage(Model model, HttpSession session) {
        String memberId = (String) session.getAttribute("loggedInMemberId");
        String memberName = (String) session.getAttribute("loggedInMemberName");

        if (memberId == null) {
            memberId = "MEM-101";
            session.setAttribute("loggedInMemberId", "MEM-101");
        }
        if (memberName == null) {
            memberName = "Tharu Kulasekara";
            session.setAttribute("loggedInMemberName", "Tharu Kulasekara");
        }

        memberId = memberId.trim();
        String packageName = service.getMemberPackage(memberId);
        if (packageName == null) {
            packageName = "GOLD";
        }
        packageName = packageName.toUpperCase().trim();

        List<Schedule> all = service.getAllSchedules();
        final String finalId = memberId;

        List<Schedule> myBookings = all.stream()
                .filter(s -> s.getMemberId().trim().equalsIgnoreCase(finalId) && "BOOKED".equalsIgnoreCase(s.getStatus()))
                .collect(Collectors.toList());

        model.addAttribute("myBookings", myBookings);
        model.addAttribute("bookingCount", myBookings.size());

        model.addAttribute("history", all.stream()
                .filter(s -> s.getMemberId().trim().equalsIgnoreCase(finalId))
                .sorted((a, b) -> b.getDate().compareTo(a.getDate()))
                .collect(Collectors.toList()));

        model.addAttribute("currentId", memberId);
        model.addAttribute("currentName", memberName);
        model.addAttribute("packageName", packageName);
        
        return "user";
    }

    @PostMapping("/book")
    public String book(@RequestParam String memberId, @RequestParam String trainerAndClass,
                       @RequestParam String timeSlot, @RequestParam String bookingDay,
                       HttpSession session) {
        String sessionMemberId = (String) session.getAttribute("loggedInMemberId");
        if (sessionMemberId == null) sessionMemberId = memberId;
        sessionMemberId = sessionMemberId.trim();

        String packageName = service.getMemberPackage(sessionMemberId);
        if (packageName == null || !"GOLD".equalsIgnoreCase(packageName.trim())) {
            return "redirect:/user?status=unauthorized";
        }

        final String finalBookerId = sessionMemberId;
        long count = service.getAllSchedules().stream()
                .filter(s -> s.getMemberId().trim().equalsIgnoreCase(finalBookerId) && "BOOKED".equalsIgnoreCase(s.getStatus()))
                .count();

        if (count >= 2) {
            return "redirect:/user?status=limit";
        }

        try {
            DayOfWeek day = DayOfWeek.valueOf(bookingDay.toUpperCase().trim());
            String date = LocalDate.now().with(TemporalAdjusters.nextOrSame(day)).toString();
            
            String tr = "General Coach";
            String cl = trainerAndClass.trim();

            if (trainerAndClass.contains("|")) {
                String[] parts = trainerAndClass.split("\\|");
                if (parts.length >= 2) {
                    tr = parts[0].trim();
                    cl = parts[1].trim();
                }
            }

            service.saveSchedule(new Schedule(sessionMemberId, tr, cl, timeSlot, "BOOKED", date));
            return "redirect:/user?status=success";
        } catch (Exception e) { 
            e.printStackTrace();
            return "redirect:/user?error=true"; 
        }
    }

    @PostMapping("/deleteSchedule")
    public String delete(@RequestParam String memberId, @RequestParam String timeSlot, 
                         @RequestParam String trainer, HttpSession session) {
        String sessionMemberId = (String) session.getAttribute("loggedInMemberId");
        if (sessionMemberId == null) sessionMemberId = memberId;
        
        service.updateStatusToDeleted(sessionMemberId.trim(), timeSlot, trainer);
        return "redirect:/user?status=deleted";
    }

    @GetMapping("/admin")
    public String showAdminPage(Model model) {
        model.addAttribute("allSchedules", service.getAllSchedules());
        return "admin";
    }

    // ==========================================================
    // DIET PLAN ROUTE CONTROL DISPATCHERS
    // ==========================================================
    @GetMapping("/dietplan")
    public String viewDietPlan(HttpSession session, @RequestParam(required = false) String action, Model model) {
        String memberId = (String) session.getAttribute("loggedInMemberId");
        if (memberId == null) {
            memberId = "MEM-101"; 
            session.setAttribute("loggedInMemberId", memberId);
        }
        memberId = memberId.trim();
        session.setAttribute("memberId", memberId);
        
        List<DietPlan> userHistory = service.getDietPlanHistoryByMember(memberId);
        model.addAttribute("dietHistory", userHistory);
        model.addAttribute("action", action != null ? action : "list");
        return "memberdiet";
    }

    @PostMapping("/dietplan")
    public String processDietPlanGeneration(@RequestParam String dietType,
                                            @RequestParam String fitnessGoal,
                                            @RequestParam(defaultValue = "medium") String activityLevel,
                                            @RequestParam(defaultValue = "NO") String medicalCondition,
                                            HttpSession session, Model model) {
        String memberId = (String) session.getAttribute("loggedInMemberId");
        if (memberId == null) memberId = "MEM-101";
        memberId = memberId.trim();
        
        StringBuilder details = new StringBuilder();
        String cleanType = dietType.toLowerCase().trim();
        String cleanGoal = fitnessGoal.toLowerCase().trim();
        String cleanActivity = activityLevel.toLowerCase().trim();

        int baseCalories = 2000;
        double activityMultiplier = 1.4;
        
        if (cleanActivity.equals("low")) activityMultiplier = 1.2;
        if (cleanActivity.equals("high")) activityMultiplier = 1.65;
        
        int computedCalories = (int) (baseCalories * activityMultiplier);
        if (cleanGoal.contains("loss")) {
            computedCalories -= 400; 
        } else if (cleanGoal.contains("gain")) {
            computedCalories += 500; 
        }

        int proteinGrams = (int) (computedCalories * 0.25 / 4);
        int carbGrams = (int) (computedCalories * 0.50 / 4);
        int fatGrams = (int) (computedCalories * 0.25 / 9);
        double waterCalculated = cleanGoal.contains("gain") ? 4.2 : (cleanGoal.contains("loss") ? 3.5 : 3.0);

        if (cleanType.contains("veg") && !cleanType.contains("non")) {
            if (cleanGoal.contains("loss")) {
                details.append("Breakfast (08:00 AM):\n")
                       .append("- Scrambled Tofu (180g) with spinach, bell peppers, and turmeric\n")
                       .append("- 1 Cup of unsweetened Green Tea\n\n")
                       .append("Lunch (01:00 PM):\n")
                       .append("- Spiced Chickpea & Quinoa Salad (1 Cup cooked chickpeas with cucumber & tomatoes)\n")
                       .append("- 1 tbsp light Lemon-Tahini dressing\n\n")
                       .append("Dinner (08:00 PM):\n")
                       .append("- Grilled Low-Fat Paneer (120g) marinated in mixed green herbs\n")
                       .append("- Steamed broccoli florets, asparagus, and sauteed green beans");
            } 
            else if (cleanGoal.contains("gain")) {
                details.append("Breakfast (08:00 AM):\n")
                       .append("- High-Calorie Oats: 1.5 Cups rolled oats boiled in rich creamy soy/dairy milk\n")
                       .append("- 2 tbsp Organic Peanut Butter, 1 chopped Banana, and 1 tbsp Chia Seeds\n\n")
                       .append("Lunch (01:00 PM):\n")
                       .append("- Thick Lentil Curry (Dal Tadka - 1.5 Cups) with 1.5 Cups of Basmati Rice\n")
                       .append("- Premium Malai Paneer cubes (150g) tossed gently in pure cow ghee\n\n")
                       .append("Dinner (08:00 PM):\n")
                       .append("- Roasted Sweet Potato Mash (250g) seasoned with extra virgin olive oil\n")
                       .append("- Grilled Tempeh or Tofu Steaks (150g) served with buttered sweet corn");
            } 
            else { 
                details.append("Breakfast (08:00 AM):\n")
                       .append("- Moong Dal Chilla (2 savory lentil pancakes) stuffed with crumbled home-made paneer\n")
                       .append("- 1 Cup of oatmeal topped with fresh raspberries and raw walnuts\n\n")
                       .append("Lunch (01:00 PM):\n")
                       .append("- Brown Rice (1 Cup) paired with high-protein Edamame and Mixed Vegetable Stir-fry\n")
                       .append("- 1 Cup of low-fat Greek Yogurt for probiotic digestion\n\n")
                       .append("Dinner (08:00 PM):\n")
                       .append("- Oven-baked herb Tofu Blocks (150g)\n")
                       .append("- Creamy cauliflower mash and garlic-rubbed sauteed green beans");
            }
        }
        else { 
            if (cleanGoal.contains("loss")) {
                details.append("Breakfast (08:00 AM):\n")
                       .append("- 3 Egg White Omelet with mushrooms, baby spinach, and white onions\n")
                       .append("- 1/2 Sliced Hass Avocado\n\n")
                       .append("Lunch (01:00 PM):\n")
                       .append("- 160g Rosemary Oven-Grilled Chicken Breast (skinless)\n")
                       .append("- Tossed garden salad with cucumber slices and freshly squeezed lemon\n\n")
                       .append("Dinner (08:00 PM):\n")
                       .append("- 150g Baked White Fish Fillet (Cod or Tilapia)\n")
                       .append("- Steamed asparagus spears and broccoli with olive oil drizzle");
            } 
            else if (cleanGoal.contains("gain")) {
                details.append("Breakfast (08:00 AM):\n")
                       .append("- 3 Whole Eggs scrambled in dairy butter with 3 strips of Turkey Bacon\n")
                       .append("- 2 Slices of toasted artisanal sourdough bread\n\n")
                       .append("Lunch (01:00 PM):\n")
                       .append("- 200g Juicy Flame-Grilled Chicken Thighs\n")
                       .append("- 2 Full Cups of long-grain Basmati Rice cooked using rich chicken bone broth\n")
                       .append("- 1 Cup of roasted broccoli and honey-glazed carrots\n\n")
                       .append("Dinner (08:00 PM):\n")
                       .append("- 200g Grilled Atlantic Salmon Fillet (high omega-3 density)\n")
                       .append("- 1 Large baked sweet potato (250g) with a dollop of premium sour cream\n")
                       .append("- Side of 1 crisp buttered green peas");
            } 
            else { 
                details.append("Breakfast (08:00 AM):\n")
                       .append("- 2 Whole Eggs prepared sunny-side up + 2 slices of Multi-grain Toast\n")
                       .append("- 1 Fresh green apple on the side\n\n")
                       .append("Lunch (01:00 PM):\n")
                       .append("- 180g Lean Ground Beef or Ground Turkey mince vegetable stir-fry\n")
                       .append("- 1 Cup of fluffy cooked white Organic Quinoa\n\n")
                       .append("Dinner (08:00 PM):\n")
                       .append("- 180g Grilled Yellowfin Tuna Steak or Pan-seared Chicken Breast\n")
                       .append("- 150g Roasted baby red potatoes tossed in rosemary\n")
                       .append("- Steamed zucchini slices resting on a bed of ribboned spinach");
            }
        }

        DietPlan plan = new DietPlan();
        plan.setPlanId(String.valueOf(new Random().nextInt(9000) + 1000));
        plan.setMemberId(memberId);
        plan.setDietType(dietType.toUpperCase());
        plan.setFitnessGoal(fitnessGoal.toUpperCase());
        plan.setMedicalCondition(medicalCondition.toUpperCase());
        plan.setPlanDetails(details.toString());
        plan.setWaterIntake(waterCalculated);
        
        plan.setCalories(computedCalories);
        plan.setProtein(proteinGrams);
        plan.setCarbs(carbGrams);
        plan.setFats(fatGrams);
        
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
        plan.setCreatedDate(dtf.format(LocalDateTime.now()));

        service.saveDietPlan(plan);

        // Store the active plan instance inside the user session memory for download tracking
        session.setAttribute("activeGeneratedPlan", plan);

        model.addAttribute("generatedPlan", plan);
        model.addAttribute("dietHistory", service.getDietPlanHistoryByMember(memberId));
        model.addAttribute("action", "view");
        
        return "memberdiet";
    }

    @GetMapping("/dietplan/download")
    public void downloadDietPDF(@RequestParam String planId, HttpSession session, HttpServletResponse response) {
        try {
            // Read directly from secure state cache instead of flaky URL text mappings
            DietPlan plan = (DietPlan) session.getAttribute("activeGeneratedPlan");
            
            // Fallback safety lookup if session is missing
            if (plan == null) {
                String memberId = (String) session.getAttribute("loggedInMemberId");
                if (memberId == null) memberId = "MEM-101";
                List<DietPlan> userHistory = service.getDietPlanHistoryByMember(memberId.trim());
                plan = userHistory.stream()
                        .filter(p -> p.getPlanId().equalsIgnoreCase(planId.trim()))
                        .findFirst()
                        .orElse(null);
            }

            if (plan == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Target Diet Plan Not Found.");
                return;
            }

            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=FitNaze_DietPlan_" + planId + ".pdf");
            
            com.lowagie.text.Document document = new com.lowagie.text.Document();
            com.lowagie.text.pdf.PdfWriter.getInstance(document, response.getOutputStream());
            
            document.open();
            
            com.lowagie.text.Font companyFont = com.lowagie.text.FontFactory.getFont(com.lowagie.text.FontFactory.HELVETICA_BOLD, 22, new java.awt.Color(255, 87, 34));
            com.lowagie.text.Font sectionHeading = com.lowagie.text.FontFactory.getFont(com.lowagie.text.FontFactory.HELVETICA_BOLD, 14, new java.awt.Color(255, 87, 34));
            com.lowagie.text.Font metaLabel = com.lowagie.text.FontFactory.getFont(com.lowagie.text.FontFactory.HELVETICA_BOLD, 11, java.awt.Color.DARK_GRAY);
            com.lowagie.text.Font mainBody = com.lowagie.text.FontFactory.getFont(com.lowagie.text.FontFactory.HELVETICA, 11, java.awt.Color.BLACK);
            
            document.add(new com.lowagie.text.Paragraph("FITNAZE COMPRESSED NUTRITION MATRIX\n", companyFont));
            document.add(new com.lowagie.text.Paragraph("Official Personalized Fitness Report Profile\n\n", com.lowagie.text.FontFactory.getFont(com.lowagie.text.FontFactory.HELVETICA, 10, java.awt.Color.GRAY)));
            document.add(new com.lowagie.text.Paragraph("------------------------------------------------------------------------------------------------------------------------\n\n"));
            
            document.add(new com.lowagie.text.Paragraph("Plan Reference Token: #" + plan.getPlanId(), metaLabel));
            document.add(new com.lowagie.text.Paragraph("Allocated System Strategy: " + plan.getDietType().toUpperCase(), metaLabel));
            document.add(new com.lowagie.text.Paragraph("Target Output Goal: " + plan.getFitnessGoal().toUpperCase() + "\n\n", metaLabel));
            
            document.add(new com.lowagie.text.Paragraph("DAILY TARGET MACRONUTRIENT LOGS:\n", sectionHeading));
            document.add(new com.lowagie.text.Paragraph(String.format("Energy Limit: %d kcal | Protein Target: %dg | Carbs: %dg | Fats: %dg | Target Hydration: %.1fL\n\n", 
                    plan.getCalories(), plan.getProtein(), plan.getCarbs(), plan.getFats(), plan.getWaterIntake()), mainBody));
            
            document.add(new com.lowagie.text.Paragraph("DAILY CONFIGURATION FOOD BREAKDOWN SCHEDULE:\n\n", sectionHeading));
            document.add(new com.lowagie.text.Paragraph(plan.getPlanDetails(), mainBody));
            
            document.add(new com.lowagie.text.Paragraph("\n\n------------------------------------------------------------------------------------------------------------------------\n"));
            document.add(new com.lowagie.text.Paragraph("FitNaze Gym Ecosystem © 2026. All nutrition schedules are optimized dynamically based on standard caloric base equations.", com.lowagie.text.FontFactory.getFont(com.lowagie.text.FontFactory.HELVETICA_OBLIQUE, 9, java.awt.Color.GRAY)));
            
            document.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}