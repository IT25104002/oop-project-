package main; // Added package to match your project structure

import java.util.*;

public class GymLogic {

    // --- COMPONENT 03: INSERTION SORT ---
    // This sorts the list by ID from smallest to largest
    public static void insertionSort(List<Member> members) {
        for (int i = 1; i < members.size(); i++) {
            Member key = members.get(i);
            int j = i - 1;
            
            // Note: We use Integer.parseInt to compare the IDs as numbers
            // If your IDs contain letters, use: members.get(j).getMemberId().compareTo(key.getMemberId()) > 0
            try {
                while (j >= 0 && Integer.parseInt(members.get(j).getMemberId()) > Integer.parseInt(key.getMemberId())) {
                    members.set(j + 1, members.get(j));
                    j = j - 1;
                }
                members.set(j + 1, key);
            } catch (NumberFormatException e) {
                // If ID is not a number, fallback to alphabetical comparison
                if (j >= 0 && members.get(j).getMemberId().compareTo(key.getMemberId()) > 0) {
                     members.set(j + 1, members.get(j));
                     j--;
                }
                members.set(j + 1, key);
            }
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