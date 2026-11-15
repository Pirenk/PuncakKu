<?php
require_once "koneksi.php";

$query = "SELECT * FROM gps_tracking ORDER BY tanggal_mulai DESC";
$result = $koneksi->query($query);

$list = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $list[] = [
            "id_tracking"     => intval($row['id_tracking']),
            "id_user"         => intval($row['id_user']),
            "id_trip"         => $row['id_trip'] !== null ? intval($row['id_trip']) : null,
            "tanggal_mulai"   => $row['tanggal_mulai'],
            "tanggal_selesai" => $row['tanggal_selesai'],
            "total_jarak"     => floatval($row['total_jarak']),
            "durasi_detik"    => intval($row['durasi_detik']),
            "status"          => $row['status'],
            "created_at"      => $row['created_at'],
            "updated_at"      => $row['updated_at']
        ];
    }
}

echo json_encode([
    "status" => true,
    "total"  => count($list),
    "data"   => $list
]);
?>
