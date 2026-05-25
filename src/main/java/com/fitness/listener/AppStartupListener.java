package com.fitness.listener;

import com.fitness.dao.MemberDAO;
import com.fitness.util.StorageConfig;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AppStartupListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        String dataPath = sce.getServletContext().getRealPath("/WEB-INF/data");
        StorageConfig.setDataDirectory(dataPath);
        MemberDAO.initializeStorage();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // No database connection to close. All member data is stored in text files.
    }
}
