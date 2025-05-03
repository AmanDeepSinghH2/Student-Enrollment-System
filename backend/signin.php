<?php
header('Content-Type: application/json');
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['username']) || !isset($data['password'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Username and password are required']);
    exit;
}

$username = trim($data['username']);
$password = $data['password'];

if (strlen($username) < 3 || strlen($password) < 6) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid username or password']);
    exit;
}

// Try to find user in Faculty table
$stmt = $conn->prepare("SELECT FacultyID, PasswordHash, Name, EmailID FROM Faculty WHERE Username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows === 1) {
    $stmt->bind_result($userID, $passwordHash, $name, $emailid);
    $stmt->fetch();

    if (!password_verify($password, $passwordHash)) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid username or password']);
        $stmt->close();
        $conn->close();
        exit;
    }

    $stmt->close();
    $conn->close();

    // Authentication successful for faculty
    echo json_encode([
        'message' => 'Login successful',
        'user' => [
            'userID' => $userID,
            'username' => $username,
            'name' => $name,
            'emailid' => $emailid,
            'role' => 'faculty'
        ]
    ]);
    exit;
}

$stmt->close();

// Try to find user in Students table
$stmt = $conn->prepare("SELECT StudentID, PasswordHash, Name, EmailID FROM Students WHERE Username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows === 1) {
    $stmt->bind_result($userID, $passwordHash, $name, $emailid);
    $stmt->fetch();

    if (!password_verify($password, $passwordHash)) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid username or password']);
        $stmt->close();
        $conn->close();
        exit;
    }

    $stmt->close();
    $conn->close();

    // Authentication successful for student
    echo json_encode([
        'message' => 'Login successful',
        'user' => [
            'userID' => $userID,
            'username' => $username,
            'name' => $name,
            'emailid' => $emailid,
            'role' => 'student'
        ]
    ]);
    exit;
}

$stmt->close();
$conn->close();

http_response_code(401);
echo json_encode(['error' => 'Invalid username or password']);
?>
