package com.fitness.model;

import java.time.LocalDate;

public class Member {
    private String memberId;
    private String fullName;
    private String email;
    private String passwordHash;
    private String role;
    private String phone;
    private LocalDate dob;
    private String gender;
    private String address;
    private String profilePicture;
    private double height;
    private double weight;
    private String fitnessGoal;
    private String emergencyContact;
    private String membershipPlan;
    private LocalDate joinDate;
    private LocalDate expiryDate;
    private String paymentStatus;
    private String status;

    public Member() {}

    public Member(String memberId, String fullName, String email, String passwordHash, String role,
                  String phone, LocalDate dob, String gender, String address, String profilePicture,
                  double height, double weight, String fitnessGoal, String emergencyContact,
                  String membershipPlan, LocalDate joinDate, LocalDate expiryDate,
                  String paymentStatus, String status) {
        this.memberId = memberId;
        this.fullName = fullName;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.phone = phone;
        this.dob = dob;
        this.gender = gender;
        this.address = address;
        this.profilePicture = profilePicture;
        this.height = height;
        this.weight = weight;
        this.fitnessGoal = fitnessGoal;
        this.emergencyContact = emergencyContact;
        this.membershipPlan = membershipPlan;
        this.joinDate = joinDate;
        this.expiryDate = expiryDate;
        this.paymentStatus = paymentStatus;
        this.status = status;
    }

    public String getMemberId() { return memberId; }
    public void setMemberId(String memberId) { this.memberId = memberId; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public LocalDate getDob() { return dob; }
    public void setDob(LocalDate dob) { this.dob = dob; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getProfilePicture() { return profilePicture; }
    public void setProfilePicture(String profilePicture) { this.profilePicture = profilePicture; }
    public double getHeight() { return height; }
    public void setHeight(double height) { this.height = height; }
    public double getWeight() { return weight; }
    public void setWeight(double weight) { this.weight = weight; }
    public String getFitnessGoal() { return fitnessGoal; }
    public void setFitnessGoal(String fitnessGoal) { this.fitnessGoal = fitnessGoal; }
    public String getEmergencyContact() { return emergencyContact; }
    public void setEmergencyContact(String emergencyContact) { this.emergencyContact = emergencyContact; }
    public String getMembershipPlan() { return membershipPlan; }
    public void setMembershipPlan(String membershipPlan) { this.membershipPlan = membershipPlan; }
    public LocalDate getJoinDate() { return joinDate; }
    public void setJoinDate(LocalDate joinDate) { this.joinDate = joinDate; }
    public LocalDate getExpiryDate() { return expiryDate; }
    public void setExpiryDate(LocalDate expiryDate) { this.expiryDate = expiryDate; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isAdmin() {
        return "ADMIN".equalsIgnoreCase(role);
    }
}
