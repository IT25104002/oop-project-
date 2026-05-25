public class Member {

    // -------- Basic Information --------
    private int member_id;
    private String name;
    private String gender;
    private String date_of_birth;
    private String email;
    private String phone;
    private String address;

    // -------- Physical & Fitness Details --------
    private double height;
    private double weight;
    private double target_weight;
    private String fitness_goal;
    private String diet_type;

    // -------- Membership Details --------
    private String join_date;
    private String membership_end_date;
    private String plan_type;
    private String status;

    // -------- Preferences --------
    private String preferred_time;

    // -------- Payment --------
    private String payment_method;

    // -------- Optional --------
    private String emergency_contact;
    private String notes;

    // -------- Constructor --------
    public Member(int member_id, String name, String gender, String date_of_birth,
                  String email, String phone, String address,
                  double height, double weight, double target_weight,
                  String fitness_goal, String diet_type,
                  String join_date, String membership_end_date,
                  String plan_type, String status,
                  String preferred_time, String payment_method,
                  String emergency_contact, String notes) {

        this.member_id = member_id;
        this.name = name;
        this.gender = gender;
        this.date_of_birth = date_of_birth;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.height = height;
        this.weight = weight;
        this.target_weight = target_weight;
        this.fitness_goal = fitness_goal;
        this.diet_type = diet_type;
        this.join_date = join_date;
        this.membership_end_date = membership_end_date;
        this.plan_type = plan_type;
        this.status = status;
        this.preferred_time = preferred_time;
        this.payment_method = payment_method;
        this.emergency_contact = emergency_contact;
        this.notes = notes;
    }

    // -------- Getters & Setters --------

    public int getMember_id() {
        return member_id;
    }

    public void setMember_id(int member_id) {
        this.member_id = member_id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getDate_of_birth() {
        return date_of_birth;
    }

    public void setDate_of_birth(String date_of_birth) {
        this.date_of_birth = date_of_birth;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public double getHeight() {
        return height;
    }

    public void setHeight(double height) {
        this.height = height;
    }

    public double getWeight() {
        return weight;
    }

    public void setWeight(double weight) {
        this.weight = weight;
    }

    public double getTarget_weight() {
        return target_weight;
    }

    public void setTarget_weight(double target_weight) {
        this.target_weight = target_weight;
    }

    public String getFitness_goal() {
        return fitness_goal;
    }

    public void setFitness_goal(String fitness_goal) {
        this.fitness_goal = fitness_goal;
    }

    public String getDiet_type() {
        return diet_type;
    }

    public void setDiet_type(String diet_type) {
        this.diet_type = diet_type;
    }

    public String getJoin_date() {
        return join_date;
    }

    public void setJoin_date(String join_date) {
        this.join_date = join_date;
    }

    public String getMembership_end_date() {
        return membership_end_date;
    }

    public void setMembership_end_date(String membership_end_date) {
        this.membership_end_date = membership_end_date;
    }

    public String getPlan_type() {
        return plan_type;
    }

    public void setPlan_type(String plan_type) {
        this.plan_type = plan_type;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPreferred_time() {
        return preferred_time;
    }

    public void setPreferred_time(String preferred_time) {
        this.preferred_time = preferred_time;
    }

    public String getPayment_method() {
        return payment_method;
    }

    public void setPayment_method(String payment_method) {
        this.payment_method = payment_method;
    }

    public String getEmergency_contact() {
        return emergency_contact;
    }

    public void setEmergency_contact(String emergency_contact) {
        this.emergency_contact = emergency_contact;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}