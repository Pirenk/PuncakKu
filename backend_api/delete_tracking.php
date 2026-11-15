<?php
require_once "koneksi.php";

$id_tracking = isset($_GET['id_tracking']) ? intval($_GET['id_tracking']) : (isset($_POST['id_tracking']) ? intval($_POST['id_tracking']) : 0);

if ($id_tracking <= 0) {
    http_response_code(400);
    echo json_encode(["status" => false, "message" => "Parameter id_tracking tidak valid"]);
    exit();
}

// Hapus titik koordinat terlebih dahulu
$koneksi->query("DELETE FROM gps_tracking_points WHERE id_tracking = $id_tracking");

// Hapus sesi tracking
$hapus = $koneksi->query("DELETE FROM gps_tracking WHERE id_tracking = $id_tracking");

if ($hapus) {
    echo json_encode(["status" => true, "message" => "Berhasil menghapus tracking #$id_tracking dari MySQL"]);
} else {
    http_response_code(500);
    echo json_encode(["status" => false, "message" => "Gagal menghapus: " . $koneksi->error]);
}
?>
