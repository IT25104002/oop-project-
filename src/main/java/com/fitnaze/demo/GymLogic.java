package com.fitnaze.demo;

import java.util.*;

public class GymLogic {

    // --- COMPONENT 03: INSERTION SORT ---
    // This sorts the list by ID from smallest to largest
    public static void insertionSort(List<Member> members) {
        for (int i = 1; i < members.size(); i++) {
            Member key = members.get(i);
            int j = i - 1;
            
            // Loop backward through sorted elements to find key's correct placement
            while (j >= 0 && compareMemberIds(members.get(j).getMemberId(), key.getMemberId()) > 0) {
                members.set(j + 1, members.get(j));
                j = j - 1;
            }
            members.set(j + 1, key);
        }
    }

    // Safe helper method to compare IDs numerically if they look like "ID-001"
    private static int compareMemberIds(String id1, String id2) {
        try {
            // Strips "ID-" out cleanly if present, then extracts the number digits
            int num1 = Integer.parseInt(id1.replaceAll("[^0-9]", "").trim());
            int num2 = Integer.parseInt(id2.replaceAll("[^0-9]", "").trim());
            return Integer.compare(num1, num2);
        } catch (NumberFormatException e) {
            // Fallback to crisp alphabetical sorting if format changes completely
            return id1.compareTo(id2);
        }
    }

    // --- COMPONENT 02: RENEWAL QUEUE (FIFO) ---
    // This handles the "First-In, First-Out" logic for gym members
    private Queue<Member> renewalQueue = new LinkedList<>();

    // Add a member to the end of the line
    public void enqueue(Member m) {
        renewalQueue.add(m);
    }

    // Remove and return the member at the front of the line
    public Member dequeue() {
        if (renewalQueue.isEmpty()) {
            return null;
        }
        return renewalQueue.poll(); 
    }

    // Helper to see who is currently waiting
    public List<Member> getQueueAsList() {
        return new ArrayList<>(renewalQueue);
    }
}