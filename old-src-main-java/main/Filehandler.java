package main;

import java.io.*;
import java.util.*;

public class Filehandler {

    private String filePath;

    // --- CONSTRUCTOR ---
    // The Dashboard (JSP) uses this to send the exact location of members.txt
    public Filehandler(String fullPath) {
        this.filePath = fullPath;
    }

    // -------- CREATE: ADD NEW MEMBER --------
    public void addMember(Member member) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true))) {
            writer.write(member.getMemberId() + "," +
                    member.getName() + "," +
                    member.getAge() + "," +
                    member.getContactNumber() + "," +
                    member.getMembershipType() + "," +
                    member.getRenewalDate());
            writer.newLine();
            System.out.println("Member saved to file!");
        } catch (IOException e) {
            System.out.println("Error saving member: " + e.getMessage());
        }
    }

    // -------- READ: LOAD ALL INTO LIST --------
    public List<Member> readMembersToList() {
        List<Member> members = new ArrayList<>();
        File file = new File(filePath);

        if (!file.exists()) return members;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;

                String[] data = line.split(",");
                if (data.length >= 6) {
                    Member member = new Member(
                            data[0].trim(),
                            data[1].trim(),
                            Integer.parseInt(data[2].trim()),
                            data[3].trim(),
                            data[4].trim(),
                            data[5].trim()
                    );
                    members.add(member);
                }
            }
        } catch (IOException | NumberFormatException e) {
            System.out.println("Error reading file: " + e.getMessage());
        }
        return members;
    }

    // -------- DELETE: REMOVE BY ID --------
    public void deleteMember(String memberId) {
        List<String> remainingLines = new ArrayList<>();

        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.trim().startsWith(memberId + ",")) {
                    remainingLines.add(line);
                }
            }
        } catch (IOException e) { return; }

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (String l : remainingLines) {
                writer.write(l);
                writer.newLine();
            }
        } catch (IOException e) { }
    }
}