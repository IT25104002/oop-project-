Fitness Member Profile System - Text File Storage

members.txt stores all admin and member profile records in readable English text.
Fields in members.txt are separated by TAB characters.
Passwords are stored in readable English/plain text for this coursework demonstration.
activity-log.txt stores simple update/change/register logs.
uploads folder stores uploaded profile images.

Important: Do not manually edit members.txt while Tomcat is running.
The application reads and writes this file automatically.


Admin can delete member profiles. Deleted records are removed from WEB-INF/data/members.txt and the action is recorded in activity-log.txt.
