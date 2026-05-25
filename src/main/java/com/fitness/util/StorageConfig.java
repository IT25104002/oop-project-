package com.fitness.util;

import java.nio.file.Path;
import java.nio.file.Paths;

public final class StorageConfig {
    private static Path dataDirectory;

    private StorageConfig() {}

    public static synchronized void setDataDirectory(String realPath) {
        if (realPath == null || realPath.trim().isEmpty()) {
            dataDirectory = Paths.get(System.getProperty("user.home"), "fitness-member-profile-system-data");
        } else {
            dataDirectory = Paths.get(realPath);
        }
    }

    public static synchronized Path getDataDirectory() {
        if (dataDirectory == null) {
            dataDirectory = Paths.get(System.getProperty("user.home"), "fitness-member-profile-system-data");
        }
        return dataDirectory;
    }
}
