<?php
header('Content-Type: application/json');
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

$username = trim($data['username'] ?? '');
$emailid = trim($data['emailid'] ?? '');
$password = $data['password'] ?? '';
$role = $data['role'] ?? '';
$facultyName = trim($data['facultyName'] ?? '');
$facultyPhoneNumber = trim($data['facultyPhoneNumber'] ?? '');
$facultyDOB = $data['facultyDOB'] ?? '';

if ($role !== 'faculty') {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid role']);
    exit;
}

if (strlen($username) < 3 || strlen($password) < 6) {
    http_response_code(400);
    echo json_encode(['error' => 'Username must be at least 3 characters and password at least 6 characters']);
    exit;
}

if (empty($facultyName)) {
    http_response_code(400);
    echo json_encode(['error' => 'Faculty name is required']);
    exit;
}

// Check if username or email already exists in Faculty table
$stmt = $conn->prepare("SELECT FacultyID FROM Faculty WHERE Username = ? OR EmailID = ?");
$stmt->bind_param("ss", $username, $emailid);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    http_response_code(409);
    echo json_encode(['error' => 'Username or email already exists']);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// Hash the password
$passwordHash = password_hash($password, PASSWORD_DEFAULT);

// Insert new faculty record
$stmt = $conn->prepare("INSERT INTO Faculty (Username, PasswordHash, Name, EmailID, PhoneNumber, DOB) VALUES (?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssss", $username, $passwordHash, $facultyName, $emailid, $facultyPhoneNumber, $facultyDOB);

if ($stmt->execute()) {
    http_response_code(201);
    echo json_encode(['message' => 'Faculty registered successfully']);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to register faculty: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
