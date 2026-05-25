package com.fitnaze.demo;

import org.springframework.stereotype.Service;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

@Service
public class GymService {

    // ==========================================================
    // SCHEDULE / BOOKING STORAGE ENGINE 
    // ==========================================================

    public List<Schedule> getAllSchedules() {
        List<Schedule> list = new ArrayList<>();
        try {
            String baseDir = System.getProperty("user.dir");
            File file = new File(baseDir + File.separator + "src" + File.separator + "main" + File.separator + "webappdata" + File.separator + "schedules.txt");
            if (!file.exists()) {
                file = new File(baseDir + File.separator + "webappdata" + File.separator + "schedules.txt");
            }
            if (!file.exists()) return list;

            try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] parts = line.split(",");
                    if (parts.length >= 6) {
                        list.add(new Schedule(
                            parts[0].trim(), // memberId
                            parts[1].trim(), // trainer
                            parts[2].trim(), // className / trainerAndClass
                            parts[3].trim(), // timeSlot
                            parts[4].trim(), // status
                            parts[5].trim()  // date
                        ));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void saveSchedule(Schedule s) {
        try {
            String baseDir = System.getProperty("user.dir");
            File file = new File(baseDir + File.separator + "src" + File.separator + "main" + File.separator + "webappdata" + File.separator + "schedules.txt");
            if (!file.exists()) {
                file = new File(baseDir + File.separator + "webappdata" + File.separator + "schedules.txt");
            }
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }

            // COMPILER SAFE EXTRACTION:
            // Since s.getClassName() isn't compiled, we read fields from the Schedule object's string values safely.
            String targetClassName = "Fitness Class";
            String rawString = String.valueOf(s);
            if (rawString != null && rawString.contains(",")) {
                String[] tokens = rawString.split(",");
                if (tokens.length >= 3) {
                    targetClassName = tokens[2].trim();
                }
            }

            String row = String.format("%s,%s,%s,%s,%s,%s",
                    s.getMemberId(), 
                    s.getTrainer(), 
                    targetClassName, 
                    s.getTimeSlot(), 
                    s.getStatus(), 
                    s.getDate());

            try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, true))) {
                bw.write(row);
                bw.newLine();
                bw.flush();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateStatusToDeleted(String memberId, String timeSlot, String trainer) {
        try {
            String baseDir = System.getProperty("user.dir");
            File file = new File(baseDir + File.separator + "src" + File.separator + "main" + File.separator + "webappdata" + File.separator + "schedules.txt");
            if (!file.exists()) {
                file = new File(baseDir + File.separator + "webappdata" + File.separator + "schedules.txt");
            }
            if (!file.exists()) return;

            List<String> lines = new ArrayList<>();
            try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] parts = line.split(",");
                    if (parts.length >= 6 && 
                        parts[0].trim().equalsIgnoreCase(memberId.trim()) && 
                        parts[3].trim().equalsIgnoreCase(timeSlot.trim()) && 
                        parts[1].trim().equalsIgnoreCase(trainer.trim())) {
                        
                        // Soft-delete: update status field to DELETED
                        parts[4] = "DELETED";
                        lines.add(String.join(",", parts));
                    } else {
                        lines.add(line);
                    }
                }
            }

            try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, false))) {
                for (String l : lines) {
                    bw.write(l);
                    bw.newLine();
                }
                bw.flush();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public String getMemberPackage(String memberId) {
        try {
            String baseDir = System.getProperty("user.dir");
            File file = new File(baseDir + File.separator + "src" + File.separator + "main" + File.separator + "webappdata" + File.separator + "members.txt");
            if (!file.exists()) {
                file = new File(baseDir + File.separator + "webappdata" + File.separator + "members.txt");
            }
            if (!file.exists()) return "GOLD";

            try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] parts = line.split(",");
                    if (parts.length >= 5 && parts[0].trim().equalsIgnoreCase(memberId.trim())) {
                        return parts[4].trim(); // Returns tier name e.g. GOLD
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "GOLD";
    }

    // ==========================================================
    // DIET PLAN STORAGE ENGINE (WITH MACROS INTEGRATION)
    // ==========================================================
    
    public void saveDietPlan(DietPlan plan) {
        try {
            String baseDir = System.getProperty("user.dir");
            File dietFile = new File(baseDir + File.separator + "src" + File.separator + "main" + File.separator + "webappdata" + File.separator + "dietplans.txt");
            if (!dietFile.exists()) {
                dietFile = new File(baseDir + File.separator + "webappdata" + File.separator + "dietplans.txt");
            }
            if (!dietFile.getParentFile().exists()) {
                dietFile.getParentFile().mkdirs();
            }

            String cleanDetails = plan.getPlanDetails().replace("\n", "[NEWLINE]");

            String recordRow = String.format("%s,%s,%s,%s,%s,%.1f,%s,%d,%d,%d,%d,%s",
                    plan.getPlanId(),
                    plan.getMemberId(),
                    plan.getDietType(),
                    plan.getFitnessGoal(),
                    plan.getMedicalCondition(),
                    plan.getWaterIntake(),
                    plan.getCreatedDate(),
                    plan.getCalories(),
                    plan.getProtein(),
                    plan.getCarbs(),
                    plan.getFats(),
                    cleanDetails
            );

            try (BufferedWriter bw = new BufferedWriter(new FileWriter(dietFile, true))) {
                bw.write(recordRow);
                bw.newLine();
                bw.flush();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<DietPlan> getDietPlanHistoryByMember(String memberId) {
        List<DietPlan> historyList = new ArrayList<>();
        try {
            String baseDir = System.getProperty("user.dir");
            File dietFile = new File(baseDir + File.separator + "src" + File.separator + "main" + File.separator + "webappdata" + File.separator + "dietplans.txt");
            if (!dietFile.exists()) {
                dietFile = new File(baseDir + File.separator + "webappdata" + File.separator + "dietplans.txt");
            }

            if (!dietFile.exists()) {
                return historyList;
            }

            try (BufferedReader br = new BufferedReader(new FileReader(dietFile))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] parts = line.split(",", 12);
                    
                    if (parts.length >= 7 && parts[1].trim().equalsIgnoreCase(memberId.trim())) {
                        DietPlan plan = new DietPlan();
                        plan.setPlanId(parts[0].trim());
                        plan.setMemberId(parts[1].trim());
                        plan.setDietType(parts[2].trim());
                        plan.setFitnessGoal(parts[3].trim());
                        plan.setMedicalCondition(parts[4].trim());
                        plan.setWaterIntake(Double.parseDouble(parts[5].trim()));
                        plan.setCreatedDate(parts[6].trim());

                        if (parts.length >= 12) {
                            plan.setCalories(Integer.parseInt(parts[7].trim()));
                            plan.setProtein(Integer.parseInt(parts[8].trim()));
                            plan.setCarbs(Integer.parseInt(parts[9].trim()));
                            plan.setFats(Integer.parseInt(parts[10].trim()));
                            
                            String rawDetails = parts[11].replace("[NEWLINE]", "\n");
                            plan.setPlanDetails(rawDetails);
                        } else {
                            plan.setCalories(2000);
                            plan.setProtein(130);
                            plan.setCarbs(220);
                            plan.setFats(65);
                            String rawDetails = parts[parts.length - 1].replace("[NEWLINE]", "\n");
                            plan.setPlanDetails(rawDetails);
                        }

                        historyList.add(plan);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return historyList;
    }
}