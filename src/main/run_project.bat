@echo off
pushd "%~dp0\..\.."
echo ========================================
echo   STARTING GYM MANAGEMENT SYSTEM (FIXED)
echo ========================================
echo.
echo Preparing Environment...
if exist "src\main\webapp\WEB-INF\classes" rmdir /s /q "src\main\webapp\WEB-INF\classes"
mkdir "src\main\webapp\WEB-INF\classes"

echo Compiling for Compatibility (Java 8 mode)...
for /R "src\main\java" %%F in (*.java) do (
    echo Compiling %%F
    javac --release 8 -cp "src\main\webapp\WEB-INF\lib\*" -d src\main\webapp\WEB-INF\classes "%%F"
)
echo.
echo Starting Server on http://localhost:8080/
echo Press Ctrl+C to stop the server. (KEEP THIS WINDOW OPEN)
echo.
java -jar jetty-runner.jar src/main/webapp
popd