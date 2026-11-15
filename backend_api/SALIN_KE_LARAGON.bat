@echo off
echo ========================================================
echo Memasang Backend API PuncakKu ke Laragon www...
echo ========================================================

set TARGET="C:\laragon\www\puncakku_api"

if not exist %TARGET% (
    mkdir %TARGET%
)

copy /Y "%~dp0*.php" %TARGET%

echo.
echo Selesai! File API berhasil disalin ke C:\laragon\www\puncakku_api\
echo Pastikan Anda sudah mengklik tombol "Start All" di Laragon.
echo.
pause
