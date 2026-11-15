<?php
require_once "koneksi.php";

$id_tracking = isset($_GET['id_tracking']) ? intval($_GET['id_tracking']) : 0;

if ($id_tracking <= 0) {
    http_response_code(400);
    echo json_encode(["status" => false, "message" => "Parameter id_tracking wajib disertakan"]);
    exit();
}

$stmt = $koneksi->prepare("SELECT * FROM gps_tracking_points WHERE id_tracking = ? ORDER BY recorded_at ASC");
$stmt->bind_param("i", $id_tracking);
$stmt->execute();
$result = $stmt->get_result();

$points = [];
while ($row = $result->fetch_assoc()) {
    $points[] = [
        "id_point"    => intval($row['id_point']),
        "id_tracking" => intval($row['id_tracking']),
        "latitude"    => floatval($row['latitude']),
        "longitude"   => floatval($row['longitude']),
        "altitude"    => $row['altitude'] !== null ? floatval($row['altitude']) : null,
        "accuracy"    => $row['accuracy'] !== null ? floatval($row['accuracy']) : null,
        "speed"       => $row['speed'] !== null ? floatval($row['speed']) : null,
        "recorded_at" => $row['recorded_at'],
        "created_at"  => $row['created_at']
    ];
}
$stmt->close();

echo json_encode([
    "status"      => true,
    "id_tracking" => $id_tracking,
    "total"       => count($points),
    "data"        => $points
]);
?>
