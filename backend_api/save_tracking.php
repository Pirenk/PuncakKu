<?php
require_once "koneksi.php";

// Terima payload JSON dari aplikasi Flutter PuncakKu
$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);

if (!$data) {
    http_response_code(400);
    echo json_encode([
        "status"  => false,
        "message" => "Format data JSON tidak valid atau data kosong"
    ]);
    exit();
}

try {
    // 1. Ekstrak data ringkasan tracking
    $id_user         = isset($data['id_user']) ? intval($data['id_user']) : 1;
    $id_trip         = isset($data['id_trip']) && $data['id_trip'] !== null ? intval($data['id_trip']) : null;
    $tanggal_mulai   = isset($data['tanggal_mulai']) ? $data['tanggal_mulai'] : date("Y-m-d H:i:s");
    $tanggal_selesai = isset($data['tanggal_selesai']) ? $data['tanggal_selesai'] : date("Y-m-d H:i:s");
    $total_jarak     = isset($data['total_jarak']) ? floatval($data['total_jarak']) : 0.00;
    $durasi_detik    = isset($data['durasi_detik']) ? intval($data['durasi_detik']) : 0;
    $status          = isset($data['status']) ? $data['status'] : 'selesai';
    $points          = isset($data['points']) && is_array($data['points']) ? $data['points'] : [];

    // 2. Insert ke tabel `gps_tracking`
    $queryTracking = "INSERT INTO gps_tracking (id_user, id_trip, tanggal_mulai, tanggal_selesai, total_jarak, durasi_detik, status, created_at, updated_at) 
                      VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";

    $stmt = $koneksi->prepare($queryTracking);
    $stmt->bind_param("iissdis", $id_user, $id_trip, $tanggal_mulai, $tanggal_selesai, $total_jarak, $durasi_detik, $status);
    $stmt->execute();

    $id_tracking_baru = $stmt->insert_id;
    $stmt->close();

    // 3. Insert seluruh titik ke tabel `gps_tracking_points`
    $inserted_points = 0;
    if (!empty($points)) {
        $queryPoint = "INSERT INTO gps_tracking_points (id_tracking, latitude, longitude, altitude, accuracy, speed, recorded_at, created_at) 
                       VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        $stmtPoint = $koneksi->prepare($queryPoint);

        foreach ($points as $p) {
            $lat      = floatval($p['latitude']);
            $lng      = floatval($p['longitude']);
            $alt      = isset($p['altitude']) && $p['altitude'] !== null ? floatval($p['altitude']) : null;
            $accuracy = isset($p['accuracy']) && $p['accuracy'] !== null ? floatval($p['accuracy']) : null;
            $speed    = isset($p['speed']) && $p['speed'] !== null ? floatval($p['speed']) : null;
            $rec_at   = isset($p['recorded_at']) ? $p['recorded_at'] : date("Y-m-d H:i:s");

            $stmtPoint->bind_param("iddddds", $id_tracking_baru, $lat, $lng, $alt, $accuracy, $speed, $rec_at);
            if ($stmtPoint->execute()) {
                $inserted_points++;
            }
        }
        $stmtPoint->close();
    }

    echo json_encode([
        "status"          => true,
        "message"         => "Berhasil menyimpan GPS tracking ke database Laragon MySQL!",
        "id_tracking"     => $id_tracking_baru,
        "inserted_points" => $inserted_points
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "status"  => false,
        "message" => "Error saat menyimpan data: " . $e->getMessage()
    ]);
}
?>
