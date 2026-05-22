package com.example.gymsystem.model;

public class Booking {
    private String memberId;
    private String trainerName;
    private String classType;
    private int availableSlots;

    public Booking(String memberId, String trainerName, String classType, int availableSlots) {
        this.memberId = memberId;
        this.trainerName = trainerName;
        this.classType = classType;
        this.availableSlots = availableSlots;
    }

    public String getMemberId() { return memberId; }
    public String getTrainerName() { return trainerName; }
    public String getClassType() { return classType; }
    public int getAvailableSlots() { return availableSlots; }
}