<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, DELETE");
header("Content-Type: application/json; charset=UTF-8");

// Konfigurasi Database MySQL Laragon
$host     = "127.0.0.1"; // Menggunakan IP 127.0.0.1 lebih stabil daripada localhost
$username = "root";
$password = "";          // Default Laragon tanpa password
$database = "mobile";    // Sesuai nama database di Laragon
$port     = 3306;

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

try {
    $koneksi = new mysqli($host, $username, $password, $database, $port);
    $koneksi->set_charset("utf8mb4");
} catch (mysqli_sql_exception $e) {
    http_response_code(500);
    echo json_encode([
        "status"  => false,
        "message" => "Gagal terhubung ke MySQL Laragon: " . $e->getMessage(),
        "hint"    => "Pastikan Anda sudah mengklik tombol 'Start All' di Laragon dan database 'mobile' sudah ada."
    ]);
    exit();
}
?>
