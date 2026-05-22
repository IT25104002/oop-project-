package com.example.gymsystem.controller;

import com.example.gymsystem.model.Schedule;
import com.example.gymsystem.service.GymService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.stream.Collectors;

@Controller
public class GymController {
    private final GymService service;

    public GymController(GymService service) { this.service = service; }

    @GetMapping("/user")
    public String showUserPage(Model model, HttpSession session) {
        String memberId = (String) session.getAttribute("loggedInMemberId");
        String memberName = (String) session.getAttribute("loggedInMemberName");

        if (memberId == null) memberId = "FN-2024-089";
        if (memberName == null) memberName = "Tharusha";

        String packageName = service.getMemberPackage(memberId);
        List<Schedule> all = service.getAllSchedules();
        final String finalId = memberId;

        List<Schedule> myBookings = all.stream()
                .filter(s -> s.getMemberId().equals(finalId) && s.getStatus().equals("BOOKED"))
                .collect(Collectors.toList());

        model.addAttribute("myBookings", myBookings);
        model.addAttribute("bookingCount", myBookings.size());

        model.addAttribute("history", all.stream()
                .filter(s -> s.getMemberId().equals(finalId))
                .sorted((a, b) -> b.getDate().compareTo(a.getDate()))
                .collect(Collectors.toList()));

        model.addAttribute("currentId", memberId);
        model.addAttribute("currentName", memberName);
        model.addAttribute("packageName", packageName);
        return "user";
    }

    @PostMapping("/book")
    public String book(@RequestParam String memberId, @RequestParam String trainerAndClass,
                       @RequestParam String timeSlot, @RequestParam String bookingDay) {


        long count = service.getAllSchedules().stream()
                .filter(s -> s.getMemberId().equals(memberId) && s.getStatus().equals("BOOKED"))
                .count();

        if (count >= 2) {
            return "redirect:/user?status=limit";
        }

        try {
            DayOfWeek day = DayOfWeek.valueOf(bookingDay.toUpperCase());
            String date = LocalDate.now().with(TemporalAdjusters.nextOrSame(day)).toString();
            String tr = trainerAndClass.split("\\|")[0].trim();
            String cl = trainerAndClass.split("\\|")[1].trim();
            service.saveSchedule(new Schedule(memberId, tr, cl, timeSlot, "BOOKED", date));
            return "redirect:/user?status=success";
        } catch (Exception e) { return "redirect:/user?error=true"; }
    }

    @PostMapping("/deleteSchedule")
    public String delete(@RequestParam String memberId, @RequestParam String timeSlot, @RequestParam String trainer) {
        service.updateStatusToDeleted(memberId, timeSlot, trainer);
        return "redirect:/user?status=deleted";
    }

    @GetMapping("/admin")
    public String showAdminPage(Model model) {
        model.addAttribute("allSchedules", service.getAllSchedules());
        return "admin";
    }
}