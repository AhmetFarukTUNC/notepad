<?php
header('Content-Type: application/json');

// Veritabanı bağlantısı
$host = 'localhost';
$dbname = 'notepad';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'DB connection failed']);
    exit;
}

// POST verileri
$title = $_POST['title'] ?? '';
$content = $_POST['content'] ?? '';

if (empty($title) || empty($content)) {
    echo json_encode(['status' => 'error', 'message' => 'Title and content required']);
    exit;
}

$imagePath = null;
$videoPath = null;

// FOTOĞRAF yükleme
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = 'uploads/images/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $extension = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
    $filename = uniqid('img_') . '.' . $extension;
    $targetFile = $uploadDir . $filename;

    if (move_uploaded_file($_FILES['image']['tmp_name'], $targetFile)) {
        $imagePath = $targetFile;
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to upload image']);
        exit;
    }
}

// VİDEO yükleme
if (isset($_FILES['video']) && $_FILES['video']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = 'uploads/videos/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $extension = pathinfo($_FILES['video']['name'], PATHINFO_EXTENSION);
    $filename = uniqid('vid_') . '.' . $extension;
    $targetFile = $uploadDir . $filename;

    if (move_uploaded_file($_FILES['video']['tmp_name'], $targetFile)) {
        $videoPath = $targetFile;
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to upload video']);
        exit;
    }
}

// Veritabanına kaydet
$sql = "INSERT INTO notes (title, content, image_path, video_path, created_at)
        VALUES (:title, :content, :image_path, :video_path, NOW())";
$stmt = $pdo->prepare($sql);
$result = $stmt->execute([
    'title' => $title,
    'content' => $content,
    'image_path' => $imagePath,
    'video_path' => $videoPath
]);

if ($result) {
    echo json_encode(['status' => 'success', 'message' => 'Note saved']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to save note']);
}
?>
