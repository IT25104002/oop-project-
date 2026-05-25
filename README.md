<<<<<<< HEAD
# Fitness Member Profile Management System

A premium professional Java web application for a Fitness Management System member profile module.

This version is built for **IntelliJ IDEA + Apache Tomcat 10** and stores data in **text files**, not in a database.

## Built For

- IntelliJ IDEA
- Apache Tomcat 10+
- Java 17+
- Maven
- Jakarta Servlet / JSP
- Text file storage

## Theme Colors

- Neon Green: `#00E676`
- Sky Blue: `#00B0FF`
- Premium Yellow: `#FFEA00`
- Dark Background: `#0B0F14`
- Light Background: `#F5F7FA`

## Demo Login Accounts

### Admin

- Email: `admin@fitpro.com`
- Password: `admin123`

### Member

- Email: `ahamed@fitpro.com`
- Password: `member123`

## Text File Storage

All profile data is saved in text files inside:

```text
src/main/webapp/WEB-INF/data/
```

Included files:

```text
WEB-INF/data/members.txt
WEB-INF/data/activity-log.txt
WEB-INF/data/README-DATA-FILES.txt
WEB-INF/data/uploads/
```

### What each file/folder does

- `members.txt` saves all admin and member details in readable English text using TAB-separated fields.
- `activity-log.txt` saves update logs such as profile updates and password changes.
- `uploads/` saves uploaded profile photos.
- `README-DATA-FILES.txt` explains the storage files.

The system automatically reads and writes `members.txt`. You do not need MySQL, XAMPP, phpMyAdmin, or any database. The member fields are readable in English. Only the password is stored as a secure hash, so it will still look like a long code for security.

Important: Do not manually edit `members.txt` while Tomcat is running.

## IntelliJ Setup Guide

1. Extract the ZIP file.
2. Open IntelliJ IDEA.
3. Select **File > Open**.
4. Choose this project folder: `fitness-member-profile-system`.
5. Wait for Maven to load dependencies.
6. Go to **File > Project Structure**.
7. Set Project SDK to Java 17 or newer.
8. Go to **Run > Edit Configurations**.
9. Add a new **Tomcat Server > Local** configuration.
10. Select your Tomcat 10 installation folder.
11. In the **Deployment** tab, add artifact:

```text
fitness-member-profile-system:war exploded
```

12. Set Application Context to:

```text
/fitness-member-profile-system
```

13. Run Tomcat.
14. Open:

```text
http://localhost:8080/fitness-member-profile-system/
```

## Features Included

### Member Side

- Login
- View profile
- Edit profile
- Upload profile picture
- Change password
- View membership details
- Session-based access protection
- Save profile changes into `members.txt`

### Admin Side

- Admin dashboard
- View all members
- Search members
- View member profile
- Edit member information
- Activate/deactivate members
- Update membership details
- Save admin changes into `members.txt`

## Main Code Files

```text
src/main/java/com/fitness/controller/
src/main/java/com/fitness/dao/MemberDAO.java
src/main/java/com/fitness/model/Member.java
src/main/java/com/fitness/util/
src/main/java/com/fitness/listener/AppStartupListener.java
src/main/webapp/WEB-INF/views/
src/main/webapp/assets/css/style.css
src/main/webapp/WEB-INF/data/
```

## Data Storage Explanation for Your Report

This system uses file-based storage to maintain member profile data. All member records are saved in a text file named `members.txt`. The records are saved as readable English text with TAB-separated fields, so names, emails, phone numbers, addresses, membership plans, status, and fitness goals can be easily viewed. Passwords are stored in readable English/plain text in `members.txt` as requested for the coursework demonstration. When a member updates their profile, changes their password, uploads a profile photo, registers a new account, or when an admin updates member details, the system updates the text file automatically. This makes the system simple to run in a student project environment without requiring a separate database server.

## Readable members.txt Format

The old version saved fields as Base64 text. This version saves member details in readable English text. Example format:

```text
M001    Ahamed M. R. A.    ahamed@fitpro.com    password    MEMBER    +94771234567    2002-05-15    Male    Malabe, Sri Lanka    172.0    68.0    Muscle Gain    Active
```

Note: the real file has more columns, and columns are separated by TAB spaces. The password field is still a hash for security.

## Note About Deployment

When running with IntelliJ Tomcat `war exploded`, Tomcat writes data to the deployed web application copy. The source project includes the starter text files, and Tomcat uses them when the project is deployed.


## New Register Page

This updated version includes a complete member registration page.

URL:

```text
http://localhost:8080/fitness-member-profile-system/register
```

When a user registers:

1. The system validates required fields.
2. The system checks whether the email already exists.
3. The system validates strong password rules.
4. A new member ID is generated automatically, such as `M003`, `M004`, etc.
5. The new member is saved into:

```text
src/main/webapp/WEB-INF/data/members.txt
```

New registered members are saved with:

```text
Role: MEMBER
Status: Active
Payment Status: Pending
Join Date: Current date
Expiry Date: Based on selected plan
```

Password rule for new registration:

```text
Minimum 8 characters, at least one uppercase letter, at least one number, and at least one special character.
```

Example valid password:

```text
Member@123
```

## Updated Premium UI

The login and register pages were redesigned with a premium professional style using these project colors:

```text
#00E676 - Green accent
#00B0FF - Blue accent
#FFEA00 - Yellow highlight
#0B0F14 - Dark background
#F5F7FA - Light background
```

## Files Added or Updated

```text
src/main/java/com/fitness/controller/RegisterServlet.java
src/main/java/com/fitness/dao/MemberDAO.java
src/main/webapp/WEB-INF/views/register.jsp
src/main/webapp/WEB-INF/views/login.jsp
src/main/webapp/WEB-INF/views/index.jsp
src/main/webapp/assets/css/style.css
src/main/webapp/WEB-INF/data/members.txt
src/main/webapp/WEB-INF/data/activity-log.txt
```

## Important Note About TXT Storage

The data is stored inside the deployed web application folder at runtime. In IntelliJ/Tomcat, after running the project, Tomcat may copy the project to its deployment folder. The application will still save new registrations to `WEB-INF/data/members.txt` inside the running web app directory.

For your project demonstration, register a new member, then check `WEB-INF/data/members.txt` in the deployed project folder or IntelliJ exploded artifact output.


Admin can delete member profiles. Deleted records are removed from WEB-INF/data/members.txt and the action is recorded in activity-log.txt.
=======
# 🏋️ Elite Gym Management System

A high-performance, OOP-based member management system for FitNase Gym. Built with Java, JSP, and a custom Insertion Sort algorithm for data organization.

## 🚀 How to Run (One-Tap Setup)

To run this project on a new laptop, follow these simple steps:

1. **Install Java**: Make sure [Java (JDK 17 or 22)](https://www.oracle.com/java/technologies/downloads/) is installed.
2. **Download the Code**: Clone this repository or download the ZIP file and extract it.
3. **Double-Click**: Open the folder and double-click the `run_project.bat` file.
4. **Access the Website**: Open your browser and go to:
   [http://localhost:8080/Dashboard.jsp](http://localhost:8080/Dashboard.jsp)

## 📁 Key Features
- **Smart Sorting**: Uses a custom **Insertion Sort** logic to keep members organized by ID.
- **Fast Queue**: Implements a **FIFO Queue** for membership renewals.
- **Local Persistence**: Saves all data locally to `members.txt`—no SQL installation required.
- **Modern UI**: A premium dark-themed dashboard with responsive design.

## 🛠️ Project Structure
- `src/main/java/main`: Core Java logic (Member, GymLogic, Filehandler).
- `src/main/webapp`: User Interface (JSP, CSS, Images).
- `run_project.bat`: One-click compile and launch script.

---
*Created for the OOP Project 2026.*
>>>>>>> origin/main
