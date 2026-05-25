package main; // IMPORTANT: Add this to match your folder structure

public class Member {

    private String memberId;
    private String name;
    private int age;
    private String contactNumber;
    private String membershipType;
    private String renewalDate; // format: "YYYY-MM-DD"


    // Constructor
    public Member(String memberId, String name, int age,
                  String contactNumber, String membershipType, String renewalDate) {
        this.memberId = memberId;
        this.name = name;
        this.age = age;
        this.contactNumber = contactNumber;
        this.membershipType = membershipType;
        this.renewalDate = renewalDate;
    }

    // Getters and Setters
    public String getMemberId() {
        return memberId;
    }

    public void setMemberId(String memberId) {
        this.memberId = memberId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getContactNumber() {
        return contactNumber;
    }

    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }

    public String getMembershipType() {
        return membershipType;
    }

    public void setMembershipType(String membershipType) {
        this.membershipType = membershipType;
    }

    public String getRenewalDate() {
        return renewalDate;
    }

    public void setRenewalDate(String renewalDate) {
        this.renewalDate = renewalDate;
    }
}