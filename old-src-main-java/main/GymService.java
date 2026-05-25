package com.fitnaze.demo;

import com.fitnaze.demo.Schedule;
import com.fitnaze.demo.DietPlan;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class GymService {
    private final List<Schedule> scheduleList = new ArrayList<>();
    private final List<DietPlan> dietPlansList = new ArrayList<>();

    // ==========================================================
    // MEMBERSHIP & PACKAGES MOCK STUB CONTROLS
    // ==========================================================
    public String getPaymentStatus(String memberId) { 
        return "APPROVED"; 
    }
    
    public String getMemberPackage(String memberId) { 
        return "GOLD"; 
    }

    // ==========================================================
    // BOOKING SCHEDULE LOGIC (FILE / MEMORY ARRAY HANDLERS)
    // ==========================================================
    public List<Schedule> getAllSchedules() { 
        return scheduleList; 
    }
    
    public void saveSchedule(Schedule s) { 
        scheduleList.add(s); 
    }

    public long getSlotCount(String slot) {
        return scheduleList.stream()
                .filter(s -> s.getTimeSlot().equals(slot) && "BOOKED".equalsIgnoreCase(s.getStatus()))
                .count();
    }

    public void updateStatusToDeleted(String memberId, String timeSlot, String trainer) {
        for (Schedule s : scheduleList) {
            if (s.getMemberId().equalsIgnoreCase(memberId.trim()) && 
                s.getTimeSlot().equalsIgnoreCase(timeSlot.trim()) &&
                s.getTrainer().equalsIgnoreCase(trainer.trim()) && 
                "BOOKED".equalsIgnoreCase(s.getStatus())) {
                s.setStatus("DELETED");
                break;
            }
        }
    }

    // ==========================================================
    // NUTRITION & DIET PLAN DATA PERSISTENCE TRACKERS
    // ==========================================================
    public void saveDietPlan(DietPlan plan) {
        // Add to active runtime memory cache
        dietPlansList.add(plan);
        
        // Persist safely down into text file architecture
        try {
            String baseDir = System.getProperty("user.dir");
            File dietFile = new File(baseDir + File.separator + "src" + File.separator + "main" + File.separator + "webappdata" + File.separator + "dietplans.txt");
            if (!dietFile.exists()) {
                dietFile = new File(baseDir + File.separator + "webappdata" + File.separator + "dietplans.txt");
            }
            if (!dietFile.getParentFile().exists()) {
                dietFile.getParentFile().mkdirs();
            }

            // Write formatted data sequence flat row mapping
            try (BufferedWriter bw = new BufferedWriter(new FileWriter(dietFile, true))) {
                String lineRow = String.format("%s|%s|%s|%s|%d|%d|%d|%d|%.2f|%s",
                        plan.getPlanId(),
                        plan.getMemberId(),
                        plan.getDietType(),
                        plan.getFitnessGoal(),
                        plan.getCalories(),
                        plan.getProtein(),
                        plan.getCarbs(),
                        plan.getFats(),
                        plan.getWaterIntake(),
                        plan.getCreatedDate()
                );
                bw.write(lineRow);
                bw.newLine();
                bw.flush();
            }
        } catch (Exception e) {
            System.err.println("CRITICAL: Failed to write diet matrix log entry onto storage disk context.");
            e.printStackTrace();
        }
    }

    public List<DietPlan> getDietPlanHistoryByMember(String memberId) {
        // Filter elements out from memory context log tracker
        final String searchId = memberId.trim();
        return dietPlansList.stream()
                .filter(p -> p.getMemberId().equalsIgnoreCase(searchId))
                .collect(Collectors.toList());
    }
}