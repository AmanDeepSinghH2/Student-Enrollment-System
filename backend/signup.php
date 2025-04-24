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
$role = isset($data['role']) ? $data['role'] : 'student';

if (strlen($username) < 3 || strlen($password) < 6) {
    http_response_code(400);
    echo json_encode(['error' => 'Username must be at least 3 characters and password at least 6 characters']);
    exit;
}

// Additional validation for faculty fields
if ($role === 'faculty') {
    if (empty($data['facultyName'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Faculty name is required']);
        exit;
    }
}

// Check if username already exists
$stmt = $conn->prepare("SELECT UserID FROM Users WHERE Username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$stmt->store_result();
if ($stmt->num_rows > 0) {
    http_response_code(409);
    echo json_encode(['error' => 'Username already exists']);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// Hash the password
$passwordHash = password_hash($password, PASSWORD_DEFAULT);

// Insert new user
$stmt = $conn->prepare("INSERT INTO Users (Username, PasswordHash, Role) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $username, $passwordHash, $role);

if ($stmt->execute()) {
    $userId = $stmt->insert_id;
    $stmt->close();

    if ($role === 'student') {
        // Insert student details
        $name = isset($data['studentName']) ? trim($data['studentName']) : '';
        // Provide default or empty values for other required fields
        $address = '';
        $phoneNumber = '';
        $dob = null;
        $semester = 1;

        $stmtStudent = $conn->prepare("INSERT INTO Students (Name, Address, PhoneNumber, DOB, Semester) VALUES (?, ?, ?, ?, ?)");
        $stmtStudent->bind_param("ssssi", $name, $address, $phoneNumber, $dob, $semester);

        if ($stmtStudent->execute()) {
            http_response_code(201);
            echo json_encode(['message' => 'User and student registered successfully']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to register student details']);
        }
        $stmtStudent->close();
    } elseif ($role === 'faculty') {
        // Insert faculty details
        $facultyName = isset($data['facultyName']) ? trim($data['facultyName']) : '';
        $facultyPhoneNumber = isset($data['facultyPhoneNumber']) ? trim($data['facultyPhoneNumber']) : '';
        $facultyDOB = isset($data['facultyDOB']) && $data['facultyDOB'] !== '' ? $data['facultyDOB'] : null;

        $stmtFaculty = $conn->prepare("INSERT INTO Faculty (Name, PhoneNumber, DOB) VALUES (?, ?, ?)");
        $stmtFaculty->bind_param("sss", $facultyName, $facultyPhoneNumber, $facultyDOB);

        if ($stmtFaculty->execute()) {
            http_response_code(201);
            echo json_encode(['message' => 'User and faculty registered successfully']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to register faculty details: ' . $stmtFaculty->error]);
        }
        $stmtFaculty->close();
    } else {
        http_response_code(201);
        echo json_encode(['message' => 'User registered successfully']);
    }
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to register user']);
}

$conn->close();
?>
