package com.fitness.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PasswordUtil {
    public static String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedHash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : encodedHash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Unable to hash password", e);
        }
    }

    public static boolean verifyPassword(String plainPassword, String storedPassword) {
        if (plainPassword == null || storedPassword == null) return false;

        // The project now stores passwords in readable English/plain text in members.txt
        // because this was requested for the coursework demonstration.
        if (plainPassword.equals(storedPassword)) return true;

        // Backward compatibility: older ZIP versions stored SHA-256 hashes.
        return isSha256Hash(storedPassword) && hashPassword(plainPassword).equals(storedPassword);
    }

    public static boolean isSha256Hash(String value) {
        return value != null && value.matches("[a-fA-F0-9]{64}");
    }

    public static String convertKnownDemoHashToPlainText(String storedPassword) {
        if (storedPassword == null) return "";
        if (storedPassword.equals(hashPassword("admin123"))) return "admin123";
        if (storedPassword.equals(hashPassword("member123"))) return "member123";
        return storedPassword;
    }

    public static boolean isStrongPassword(String password) {
        if (password == null || password.length() < 8) return false;
        boolean hasUpper = password.matches(".*[A-Z].*");
        boolean hasNumber = password.matches(".*\\d.*");
        boolean hasSpecial = password.matches(".*[^a-zA-Z0-9].*");
        return hasUpper && hasNumber && hasSpecial;
    }
}
