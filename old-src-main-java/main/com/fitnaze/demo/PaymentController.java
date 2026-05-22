package main.com.fitnaze.demo;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

@Controller
public class PaymentController {

    // 1. Relative Path එක හැදීම (ප්‍රොජෙක්ට් ෆෝල්ඩරය ඇතුළේම සේව් වෙන්න)
    private final String FILE_PATH = System.getProperty("user.dir") + File.separator + "payments.txt";

    @GetMapping("/dashboard")
    public String showDashboard(Model model) {
        model.addAttribute("userName", "Tharusha");
        model.addAttribute("userId", "FN-2024-089");
        return "user-dashboard";
    }

    @GetMapping("/select-plan")
    public String showPlanSelection() {
        return "plan-selection";
    }

    @GetMapping("/payment")
    public String showPaymentPage(@RequestParam String plan, Model model) {
        model.addAttribute("selectedPlan", plan);
        model.addAttribute("userName", "Tharusha");
        model.addAttribute("userId", "FN-2024-089");
        return "payment-form";
    }

    // 2. Updated Payment Method with Validation
    @PostMapping("/addPayment")
    public String addPayment(@ModelAttribute Payment payment, RedirectAttributes redirectAttributes) {
        
        // සරල Backend Validation එකක්
        if (payment.getAmount() <= 0 || payment.getPlan() == null || payment.getName().isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Invalid payment details. Please try again.");
            return "redirect:/select-plan";
        }

        payment.setStatus("Pending"); 

        // Try-with-resources භාවිතයෙන් ගොනුවට ලිවීම (වැඩි ආරක්ෂාවට)
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(FILE_PATH, true))) {
            String record = String.format("%s|%s|%.2f|%s|%s",
                    payment.getName(),
                    payment.getPlan(),
                    payment.getAmount(),
                    payment.getStatus(),
                    payment.getPaymentMethod());
            
            bw.write(record);
            bw.newLine();
            return "payment-success";
            
        } catch (IOException e) {
            e.printStackTrace();
            return "error";
        }
    }

    @GetMapping("/payment-history")
    public String showHistory(Model model) {
        List<Payment> historyList = new ArrayList<>();
        File file = new File(FILE_PATH);

        if (file.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = br.readLine()) != null) {
                    String[] data = line.split("\\|");
                    if (data.length >= 5) {
                        Payment p = new Payment();
                        p.setName(data[0]);
                        p.setPlan(data[1]);
                        try {
                            p.setAmount(Double.parseDouble(data[2]));
                        } catch (NumberFormatException e) {
                            p.setAmount(0.0);
                        }
                        p.setStatus(data[3]);
                        p.setPaymentMethod(data[4]);
                        historyList.add(p);
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        
        model.addAttribute("history", historyList);
        return "payment-history";
    }

    @GetMapping("/delete-payment")
    public String deletePayment(@RequestParam String plan, @RequestParam double amount) {
        List<String> remainingLines = new ArrayList<>();
        
        try (BufferedReader br = new BufferedReader(new FileReader(FILE_PATH))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] data = line.split("\\|");
                if (data.length >= 5) {
                    // හරියටම ප්ලෑන් එක සහ ගාණ මැච් වෙන පේළිය අත හරිනවා
                    boolean isTarget = data[1].equals(plan) && Double.parseDouble(data[2]) == amount;
                    if (!isTarget) {
                        remainingLines.add(line);
                    }
                }
            }
        } catch (IOException e) { e.printStackTrace(); }

        writeAllToFile(remainingLines);
        return "redirect:/payment-history";
    }

    @GetMapping("/approve-payment")
    public String approvePayment(@RequestParam String plan, @RequestParam String name) {
        List<String> updatedLines = new ArrayList<>();
        
        try (BufferedReader br = new BufferedReader(new FileReader(FILE_PATH))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] data = line.split("\\|");
                if (data.length >= 5) {
                    if (data[0].equals(name) && data[1].equals(plan)) {
                        line = data[0] + "|" + data[1] + "|" + data[2] + "|Verified|" + data[4];
                    }
                }
                updatedLines.add(line);
            }
        } catch (IOException e) { e.printStackTrace(); }

        writeAllToFile(updatedLines);
        return "redirect:/admin-dashboard";
    }

    @GetMapping("/admin-dashboard")
    public String showAdminDashboard(Model model) {
        List<Payment> allPayments = new ArrayList<>();
        File file = new File(FILE_PATH);

        if (file.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = br.readLine()) != null) {
                    String[] data = line.split("\\|");
                    if (data.length >= 5) {
                        Payment p = new Payment();
                        p.setName(data[0]);
                        p.setPlan(data[1]);
                        p.setAmount(Double.parseDouble(data[2]));
                        p.setStatus(data[3]);
                        p.setPaymentMethod(data[4]);
                        allPayments.add(p);
                    }
                }
            } catch (IOException e) { e.printStackTrace(); }
        }
        model.addAttribute("allPayments", allPayments);
        return "admin-dashboard";
    }

    // Common Helper Method to write list back to file
    private void writeAllToFile(List<String> lines) {
        try (PrintWriter pw = new PrintWriter(new FileWriter(FILE_PATH))) {
            for (String l : lines) {
                pw.println(l);
            }
        } catch (IOException e) { e.printStackTrace(); }
    }
}