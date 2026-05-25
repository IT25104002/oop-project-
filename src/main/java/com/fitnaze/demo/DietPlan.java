package com.fitnaze.demo;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class DietPlan implements Serializable {
    private static final long serialVersionUID = 1L;

    private String planId;
    private String memberId;
    private String memberName;
    private String dietType;
    private String fitnessGoal;
    private String medicalCondition;
    private String planDetails;
    private double waterIntake;
    private String createdDate;
    
    // Premium Dashboard Nutritional Expansion Metrics
    private int calories;
    private int protein;
    private int carbs;
    private int fats;

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

    // ==========================================================
    // GETTERS & SETTERS (Perfect JavaBeans Specification)
    // ==========================================================
    public String getPlanId() {
        return planId; }
    public void setPlanId(String planId) {
        this.planId = planId; }

    public String getMemberId() {
        return memberId; }
    public void setMemberId(String memberId) {
        this.memberId = memberId; }

    public String getMemberName() {
        return memberName; }
    public void setMemberName(String memberName) {
        this.memberName = memberName; }

    public String getDietType() {
        return dietType; }
    public void setDietType(String dietType) {
        this.dietType = dietType; }

    public String getFitnessGoal() {
        return fitnessGoal; }
    public void setFitnessGoal(String fitnessGoal) {
        this.fitnessGoal = fitnessGoal; }

    public String getMedicalCondition() {
        return medicalCondition; }
    public void setMedicalCondition(String medicalCondition) {
        this.medicalCondition = medicalCondition; }

    public String getPlanDetails() {
        return planDetails; }
    public void setPlanDetails(String planDetails) {
        this.planDetails = planDetails; }

    public double getWaterIntake() {
        return waterIntake; }
    public void setWaterIntake(double waterIntake) {
        this.waterIntake = waterIntake; }

    public String getCreatedDate() {
        return createdDate; }
    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate; }

    public int getCalories() {
        return calories; }
    public void setCalories(int calories) {
        this.calories = calories; }

    public int getProtein() {
        return protein; }
    public void setProtein(int protein) {
        this.protein = protein; }

    public int getCarbs() {
        return carbs; }
    public void setCarbs(int carbs) {
        this.carbs = carbs; }

    public int getFats() {
        return fats; }
    public void setFats(int fats) {
        this.fats = fats; }
}