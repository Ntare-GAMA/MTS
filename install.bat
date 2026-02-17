@echo off
echo ========================================
echo MTS Baker's Bakery - Installation
echo ========================================
echo.

echo Step 1: Installing Node.js dependencies...
call npm install
if errorlevel 1 (
    echo Error: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo Step 2: Setting up environment file...
if not exist .env (
    copy .env.example .env
    echo Created .env file. Please update it with your credentials.
) else (
    echo .env file already exists.
)

echo.
echo Step 3: Database setup...
echo Please ensure MySQL is running and execute database.sql
echo You can do this by running:
echo   mysql -u root -p ^< database.sql
echo.

echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Update .env file with your database and MTN MoMo credentials
echo 2. Import database.sql into MySQL
echo 3. Run: npm start
echo 4. Open http://localhost:3000 in your browser
echo.
pause
