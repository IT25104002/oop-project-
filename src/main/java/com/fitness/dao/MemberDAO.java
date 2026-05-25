package com.fitness.dao;

import com.fitness.model.Member;
import com.fitness.util.PasswordUtil;
import com.fitness.util.StorageConfig;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

public class MemberDAO {
    private static final Map<String, Member> members = new ConcurrentHashMap<>();
    private static boolean loaded = false;
    private static final Object LOCK = new Object();
    private static final String MEMBERS_FILE = "members.txt";
    private static final String LOG_FILE = "activity-log.txt";
    private static final DateTimeFormatter LOG_TIME = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public static void initializeStorage() {
        synchronized (LOCK) {
            try {
                Files.createDirectories(StorageConfig.getDataDirectory());
                Path uploads = StorageConfig.getDataDirectory().resolve("uploads");
                Files.createDirectories(uploads);
                Path membersPath = membersPath();
                if (!Files.exists(membersPath)) {
                    seedDefaultMembers();
                    saveAll("SYSTEM", "Initial members.txt file created with demo accounts");
                } else {
                    loadFromFile();
                    migrateOldEncodedFileIfNeeded();
                }
                createReadMeFile();
                loaded = true;
            } catch (IOException e) {
                throw new RuntimeException("Unable to initialize text file storage", e);
            }
        }
    }

    private static void ensureLoaded() {
        synchronized (LOCK) {
            if (!loaded) {
                initializeStorage();
            }
        }
    }

    private static Path membersPath() {
        return StorageConfig.getDataDirectory().resolve(MEMBERS_FILE);
    }

    private static Path logPath() {
        return StorageConfig.getDataDirectory().resolve(LOG_FILE);
    }

    private static void createReadMeFile() throws IOException {
        Path readme = StorageConfig.getDataDirectory().resolve("README-DATA-FILES.txt");
        if (!Files.exists(readme)) {
            List<String> lines = List.of(
                    "Fitness Member Profile System - Text File Storage",
                    "",
                    "members.txt stores all admin and member profile records in readable English text.",
                    "Fields in members.txt are separated by TAB characters.",
                    "Passwords are stored in readable English/plain text for this coursework demonstration.",
                    "activity-log.txt stores simple update/change logs.",
                    "uploads folder stores uploaded profile images.",
                    "",
                    "Important: Do not manually edit members.txt while Tomcat is running.",
                    "The application reads and writes this file automatically."
            );
            Files.write(readme, lines, StandardCharsets.UTF_8);
        }
    }

    private static void seedDefaultMembers() {
        members.clear();
        Member admin = new Member(
                "A001", "Fitness Admin", "admin@fitpro.com", "admin123", "ADMIN",
                "+94770000000", LocalDate.of(1995, 1, 1), "Male", "Colombo, Sri Lanka", null,
                175, 70, "System Management", "+94771111111", "Staff", LocalDate.of(2024, 1, 1),
                LocalDate.of(2030, 1, 1), "Paid", "Active"
        );
        Member member1 = new Member(
                "M001", "Ahamed M. R. A.", "ahamed@fitpro.com", "member123", "MEMBER",
                "+94771234567", LocalDate.of(2002, 5, 15), "Male", "Malabe, Sri Lanka", null,
                172, 68, "Muscle Gain", "+94779876543", "Premium Monthly", LocalDate.now().minusMonths(2),
                LocalDate.now().plusMonths(1), "Paid", "Active"
        );
        Member member2 = new Member(
                "M002", "Nimal Perera", "nimal@fitpro.com", "member123", "MEMBER",
                "+94775556666", LocalDate.of(1998, 8, 22), "Male", "Kandy, Sri Lanka", null,
                169, 74, "Weight Loss", "+94774443333", "Quarterly", LocalDate.now().minusMonths(5),
                LocalDate.now().minusDays(5), "Pending", "Expired"
        );
        members.put(admin.getMemberId(), admin);
        members.put(member1.getMemberId(), member1);
        members.put(member2.getMemberId(), member2);
    }

    private static void loadFromFile() throws IOException {
        members.clear();
        Path path = membersPath();
        if (!Files.exists(path)) {
            seedDefaultMembers();
            saveAll("SYSTEM", "Created members.txt because it was missing");
            return;
        }

        try (BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8)) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty() || line.startsWith("#")) continue;
                Member member = deserialize(line);
                if (member != null && member.getMemberId() != null) {
                    members.put(member.getMemberId(), member);
                }
            }
        }

        if (members.isEmpty()) {
            seedDefaultMembers();
            saveAll("SYSTEM", "Recreated default members because members.txt was empty");
        }
    }

    private static void migrateOldEncodedFileIfNeeded() throws IOException {
        Path path = membersPath();
        if (!Files.exists(path)) return;
        try (BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8)) {
            String line;
            while ((line = reader.readLine()) != null) {
                String trimmed = line.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("#")) continue;
                if (trimmed.contains("|") && !trimmed.contains("\t")) {
                    saveAll("SYSTEM", "Converted members.txt from Base64 format to readable English text format");
                }
                return;
            }
        }
    }

    private static void saveAll(String actor, String action) throws IOException {
        Files.createDirectories(StorageConfig.getDataDirectory());
        try (BufferedWriter writer = Files.newBufferedWriter(membersPath(), StandardCharsets.UTF_8)) {
            writer.write("# Fitness Member Profile System member records");
            writer.newLine();
            writer.write("# This file is saved in readable English text. Fields are separated by TAB characters.");
            writer.newLine();
            writer.write("# Passwords are stored in readable English/plain text for this coursework demonstration.");
            writer.newLine();
            writer.write("# Fields: memberId\tfullName\temail\tpassword\trole\tphone\tdob\tgender\taddress\tprofilePicture\theight\tweight\tfitnessGoal\temergencyContact\tmembershipPlan\tjoinDate\texpiryDate\tpaymentStatus\tstatus");
            writer.newLine();
            for (Member member : members.values().stream().sorted(Comparator.comparing(Member::getMemberId)).toList()) {
                writer.write(serialize(member));
                writer.newLine();
            }
        }
        appendLog(actor, action);
    }

    private static void appendLog(String actor, String action) throws IOException {
        Files.createDirectories(StorageConfig.getDataDirectory());
        String line = LocalDateTime.now().format(LOG_TIME) + " | " + actor + " | " + action;
        Files.writeString(logPath(), line + System.lineSeparator(), StandardCharsets.UTF_8,
                Files.exists(logPath()) ? java.nio.file.StandardOpenOption.APPEND : java.nio.file.StandardOpenOption.CREATE);
    }

    private static String serialize(Member m) {
        return String.join("\t",
                esc(m.getMemberId()), esc(m.getFullName()), esc(m.getEmail()), esc(m.getPasswordHash()), esc(m.getRole()),
                esc(m.getPhone()), esc(dateToString(m.getDob())), esc(m.getGender()), esc(m.getAddress()), esc(m.getProfilePicture()),
                esc(String.valueOf(m.getHeight())), esc(String.valueOf(m.getWeight())), esc(m.getFitnessGoal()), esc(m.getEmergencyContact()),
                esc(m.getMembershipPlan()), esc(dateToString(m.getJoinDate())), esc(dateToString(m.getExpiryDate())),
                esc(m.getPaymentStatus()), esc(m.getStatus())
        );
    }

    private static Member deserialize(String line) {
        try {
            String[] p;
            if (line.contains("\t")) {
                p = line.split("\t", -1);
                if (p.length < 19) return null;
                return new Member(
                        unesc(p[0]), unesc(p[1]), unesc(p[2]), PasswordUtil.convertKnownDemoHashToPlainText(unesc(p[3])), unesc(p[4]),
                        unesc(p[5]), parseDate(unesc(p[6])), unesc(p[7]), unesc(p[8]), blankToNull(unesc(p[9])),
                        parseDouble(unesc(p[10])), parseDouble(unesc(p[11])), unesc(p[12]), unesc(p[13]), unesc(p[14]),
                        parseDate(unesc(p[15])), parseDate(unesc(p[16])), unesc(p[17]), unesc(p[18])
                );
            }

            // Backward compatibility: old versions saved every field in Base64 separated by |.
            // If an old encoded members.txt exists, the app will read it and rewrite it as readable English text after the next save.
            p = line.split("\\|", -1);
            if (p.length < 19) return null;
            return new Member(
                    oldBase64Decode(p[0]), oldBase64Decode(p[1]), oldBase64Decode(p[2]), PasswordUtil.convertKnownDemoHashToPlainText(oldBase64Decode(p[3])), oldBase64Decode(p[4]),
                    oldBase64Decode(p[5]), parseDate(oldBase64Decode(p[6])), oldBase64Decode(p[7]), oldBase64Decode(p[8]), blankToNull(oldBase64Decode(p[9])),
                    parseDouble(oldBase64Decode(p[10])), parseDouble(oldBase64Decode(p[11])), oldBase64Decode(p[12]), oldBase64Decode(p[13]), oldBase64Decode(p[14]),
                    parseDate(oldBase64Decode(p[15])), parseDate(oldBase64Decode(p[16])), oldBase64Decode(p[17]), oldBase64Decode(p[18])
            );
        } catch (Exception e) {
            return null;
        }
    }

    private static String esc(String value) {
        if (value == null) return "";
        return value
                .replace("\\", "\\\\")
                .replace("\t", "\\t")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }

    private static String unesc(String value) {
        if (value == null || value.isEmpty()) return "";
        StringBuilder result = new StringBuilder();
        boolean escaping = false;
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            if (escaping) {
                switch (c) {
                    case 't' -> result.append('\t');
                    case 'r' -> result.append('\r');
                    case 'n' -> result.append('\n');
                    case '\\' -> result.append('\\');
                    default -> {
                        result.append('\\');
                        result.append(c);
                    }
                }
                escaping = false;
            } else if (c == '\\') {
                escaping = true;
            } else {
                result.append(c);
            }
        }
        if (escaping) result.append('\\');
        return result.toString();
    }

    private static String oldBase64Decode(String value) {
        if (value == null || value.isEmpty()) return "";
        return new String(java.util.Base64.getDecoder().decode(value), StandardCharsets.UTF_8);
    }

    private static String dateToString(LocalDate date) {
        return date == null ? "" : date.toString();
    }

    private static LocalDate parseDate(String value) {
        if (value == null || value.isBlank()) return null;
        return LocalDate.parse(value);
    }

    private static double parseDouble(String value) {
        try {
            return Double.parseDouble(value);
        } catch (Exception e) {
            return 0;
        }
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value;
    }

    public Member login(String email, String password) {
        ensureLoaded();
        return members.values().stream()
                .filter(m -> m.getEmail().equalsIgnoreCase(email))
                .filter(m -> PasswordUtil.verifyPassword(password, m.getPasswordHash()))
                .findFirst()
                .orElse(null);
    }



    public boolean emailExists(String email) {
        ensureLoaded();
        if (email == null || email.trim().isEmpty()) return false;
        String target = email.trim().toLowerCase();
        return members.values().stream()
                .anyMatch(m -> m.getEmail() != null && m.getEmail().equalsIgnoreCase(target));
    }

    public Member register(Member member) {
        ensureLoaded();
        synchronized (LOCK) {
            if (member == null) {
                throw new IllegalArgumentException("Member cannot be null");
            }
            if (emailExists(member.getEmail())) {
                throw new IllegalArgumentException("Email already exists");
            }
            String newId = generateNextMemberId();
            member.setMemberId(newId);
            if (member.getRole() == null || member.getRole().isBlank()) member.setRole("MEMBER");
            if (member.getStatus() == null || member.getStatus().isBlank()) member.setStatus("Active");
            if (member.getPaymentStatus() == null || member.getPaymentStatus().isBlank()) member.setPaymentStatus("Pending");
            members.put(newId, member);
            try {
                saveAll(newId, "Registered new member: " + newId + " (" + member.getEmail() + ")");
            } catch (IOException e) {
                throw new RuntimeException("Unable to save new registration into members.txt", e);
            }
            return member;
        }
    }

    private String generateNextMemberId() {
        int max = 0;
        for (String id : members.keySet()) {
            if (id != null && id.matches("M\\d+")) {
                try {
                    max = Math.max(max, Integer.parseInt(id.substring(1)));
                } catch (NumberFormatException ignored) {
                }
            }
        }
        return String.format("M%03d", max + 1);
    }

    public Member findById(String memberId) {
        ensureLoaded();
        return members.get(memberId);
    }

    public List<Member> findAll() {
        ensureLoaded();
        return members.values().stream()
                .sorted(Comparator.comparing(Member::getMemberId))
                .collect(Collectors.toList());
    }

    public List<Member> search(String keyword) {
        ensureLoaded();
        if (keyword == null || keyword.trim().isEmpty()) {
            return findAll();
        }
        String q = keyword.toLowerCase();
        return members.values().stream()
                .filter(m -> m.getMemberId().toLowerCase().contains(q)
                        || m.getFullName().toLowerCase().contains(q)
                        || m.getEmail().toLowerCase().contains(q)
                        || m.getStatus().toLowerCase().contains(q)
                        || m.getMembershipPlan().toLowerCase().contains(q))
                .sorted(Comparator.comparing(Member::getMemberId))
                .collect(Collectors.toList());
    }

    public void update(Member member) {
        ensureLoaded();
        synchronized (LOCK) {
            members.put(member.getMemberId(), member);
            try {
                saveAll(member.getMemberId(), "Updated member profile: " + member.getMemberId());
            } catch (IOException e) {
                throw new RuntimeException("Unable to save member data into members.txt", e);
            }
        }
    }

    public boolean changePassword(String memberId, String currentPassword, String newPassword) {
        ensureLoaded();
        synchronized (LOCK) {
            Member member = findById(memberId);
            if (member == null) return false;
            if (!PasswordUtil.verifyPassword(currentPassword, member.getPasswordHash())) return false;
            member.setPasswordHash(newPassword);
            try {
                saveAll(memberId, "Changed password for member: " + memberId);
            } catch (IOException e) {
                throw new RuntimeException("Unable to save password change into members.txt", e);
            }
            return true;
        }
    }

    public boolean deleteMember(String memberId, String actorId) {
        ensureLoaded();
        synchronized (LOCK) {
            Member member = findById(memberId);
            if (member == null) return false;
            if (member.isAdmin()) {
                throw new IllegalArgumentException("Admin accounts cannot be deleted.");
            }
            members.remove(memberId);
            try {
                saveAll(actorId == null ? "ADMIN" : actorId, "Deleted member profile: " + memberId + " (" + member.getEmail() + ")");
            } catch (IOException e) {
                throw new RuntimeException("Unable to delete member from members.txt", e);
            }
            return true;
        }
    }

    public int activeCount() {
        ensureLoaded();
        return (int) members.values().stream()
                .filter(m -> !m.isAdmin())
                .filter(m -> "Active".equalsIgnoreCase(m.getStatus()))
                .count();
    }

    public int expiredCount() {
        ensureLoaded();
        return (int) members.values().stream()
                .filter(m -> !m.isAdmin())
                .filter(m -> "Expired".equalsIgnoreCase(m.getStatus()))
                .count();
    }

    public List<Member> membersOnly() {
        ensureLoaded();
        List<Member> result = new ArrayList<>();
        for (Member m : members.values()) {
            if (!m.isAdmin()) result.add(m);
        }
        result.sort(Comparator.comparing(Member::getMemberId));
        return result;
    }
}
