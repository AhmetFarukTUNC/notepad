<?php
header("Access-Control-Allow-Origin: *");
$host = 'localhost';
$dbname = 'notepad';
$username = 'root';
$password = '';

// Temel URL (API için)
$base_url = 'http://192.168.1.100'; // kendi IP/domain

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Veritabanı bağlantı hatası']);
    exit;
}

// Eğer video parametresi varsa, dosyayı stream et
if (isset($_GET['video'])) {
    $video_path = 'uploads/videos/' . basename($_GET['video']); // güvenlik için basename kullanıldı

    if (file_exists($video_path)) {
        header('Content-Type: video/mp4');
        header('Content-Length: ' . filesize($video_path));
        readfile($video_path);
        exit;
    } else {
        http_response_code(404);
        echo "Dosya bulunamadı.";
        exit;
    }
}

// Video parametresi yoksa JSON liste döndür
header('Content-Type: application/json; charset=utf-8');

try {
    $stmt = $pdo->query("SELECT id, title, content, image_path, video_path, created_at FROM notes ORDER BY created_at DESC");
    $notes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Tam URL oluştur
    foreach ($notes as &$note) {
        $note['image_url'] = !empty($note['image_path']) ? $base_url . '/' . ltrim($note['image_path'], '/') : null;
        $note['video_url'] = !empty($note['video_path']) ? $base_url . '/api.php?video=' . urlencode(basename($note['video_path'])) : null;
    }
    unset($note);

    echo json_encode($notes, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Veri çekme hatası']);
}
