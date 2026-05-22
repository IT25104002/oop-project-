package com.fitnaze.demo;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class FeedbackController {

    // This maps the URL "http://localhost:8080/feedback" to your JSP
    @GetMapping("/feedback")
    public String showFeedbackPage() {
        return "Feedback"; // Matches the name of Feedback.jsp
    }
}