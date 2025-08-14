<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *"); // Flutter'dan gelen isteklere izin

// Basit örnek API verisi
$response = [
    "status" => "success",
    "message" => "Merhaba Flutter! Bu veri PHP'den geliyor.",
    "time" => date("Y-m-d H:i:s")
];

echo json_encode($response);
