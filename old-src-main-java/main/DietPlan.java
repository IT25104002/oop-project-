package main;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class DietPlan implements Serializable {
    private String planId;
    private String memberId;
    private String memberName;
    private String dietType;
    private String fitnessGoal;
    private String medicalCondition;
    private String planDetails;
    private double waterIntake;
    private String createdDate;

    public DietPlan() {
        // Default constructor
    }

    // Constructor without member details
    public DietPlan(String planId, String dietType, String fitnessGoal, String medicalCondition, String planDetails, double waterIntake) {
        this.planId = planId;
        this.dietType = dietType;
        this.fitnessGoal = fitnessGoal;
        this.medicalCondition = medicalCondition;
        this.planDetails = planDetails;
        this.waterIntake = waterIntake;
        
        // Auto-generate current date
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
        this.createdDate = dtf.format(LocalDateTime.now());
    }

    // Constructor with member details included
    public DietPlan(String planId, String memberId, String memberName, String dietType, String fitnessGoal, String medicalCondition, String planDetails, double waterIntake) {
        this.planId = planId;
        this.memberId = memberId;
        this.memberName = memberName;
        this.dietType = dietType;
        this.fitnessGoal = fitnessGoal;
        this.medicalCondition = medicalCondition;
        this.planDetails = planDetails;
        this.waterIntake = waterIntake;
        
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
        this.createdDate = dtf.format(LocalDateTime.now());
    }

    // Getters - These MUST match the names used in your JSP
    public String getPlanId() { return planId; }
    public String getMemberId() { return memberId; }
    public String getMemberName() { return memberName; }
    public String getDietType() { return dietType; }
    public String getFitnessGoal() { return fitnessGoal; }
    public String getMedicalCondition() { return medicalCondition; }
    public String getPlanDetails() { return planDetails; }
    public double getWaterIntake() { return waterIntake; }
    public String getCreatedDate() { return createdDate; }

    // Setters
    public void setPlanId(String planId) { this.planId = planId; }
    public void setMemberId(String memberId) { this.memberId = memberId; }
    public void setMemberName(String memberName) { this.memberName = memberName; }
    public void setDietType(String dietType) { this.dietType = dietType; }
    public void setFitnessGoal(String fitnessGoal) { this.fitnessGoal = fitnessGoal; }
    public void setMedicalCondition(String medicalCondition) { this.medicalCondition = medicalCondition; }
    public void setPlanDetails(String planDetails) { this.planDetails = planDetails; }
    public void setWaterIntake(double waterIntake) { this.waterIntake = waterIntake; }
    public void setCreatedDate(String createdDate) { this.createdDate = createdDate; }
}