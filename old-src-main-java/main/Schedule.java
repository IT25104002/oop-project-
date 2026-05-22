package com.example.gymsystem.model;

public class Schedule {
    private String memberId, trainer, classType, timeSlot, status, date;

    public Schedule(String memberId, String trainer, String classType, String timeSlot, String status, String date) {
        this.memberId = memberId; this.trainer = trainer; this.classType = classType;
        this.timeSlot = timeSlot; this.status = status; this.date = date;
    }

    public String getMemberId() { return memberId; }
    public String getTrainer() { return trainer; }
    public String getClassType() { return classType; }
    public String getTimeSlot() { return timeSlot; }
    public String getStatus() { return status; }
    public String getDate() { return date; }
    public void setStatus(String status) { this.status = status; }
}