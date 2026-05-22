@echo off
echo ========================================
echo   STARTING GYM MANAGEMENT SYSTEM
echo ========================================
echo.
setlocal enabledelayedexpansion
cd /d "%~dp0"
if exist "mvnw.cmd" (
    echo Using Maven wrapper...
    set "MVN_CMD=%cd%\mvnw.cmd"
) else (
    echo Maven wrapper not found, falling back to system mvn...
    set "MVN_CMD=mvn"
)

echo Running Spring Boot application using Maven...
"%MVN_CMD%" -q spring-boot:run
endlocal
