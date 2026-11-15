@echo off
echo ========================================================
echo Memasang Backend API PuncakKu ke XAMPP htdocs...
echo ========================================================

set TARGET="C:\xampp\htdocs\puncakku_api"

if not exist %TARGET% (
    mkdir %TARGET%
)

copy /Y "%~dp0*.php" %TARGET%

echo.
echo Selesai! File API berhasil disalin ke C:\xampp\htdocs\puncakku_api\
echo Pastikan Apache dan MySQL di XAMPP Control Panel sudah dalam status START.
echo.
pause
