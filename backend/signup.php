<?php
header('Content-Type: application/json');
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['username']) || !isset($data['password']) || !isset($data['emailid'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Username, emailid and password are required']);
    exit;
}

$username = trim($data['username']);
$password = $data['password'];
$emailid = trim($data['emailid']);
$role = isset($data['role']) ? $data['role'] : 'faculty';

if ($role !== 'faculty' && $role !== 'student') {
    http_response_code(403);
    echo json_encode(['error' => 'Only faculty or student signup is allowed.']);
    exit;
}

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

// Additional validation for student fields
if ($role === 'student') {
    if (empty($data['studentName'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Student name is required']);
        exit;
    }
}

// Check if username or emailid already exists in respective tables
if ($role === 'faculty') {
    $stmt = $conn->prepare("SELECT FacultyID FROM Faculty WHERE Username = ? OR EmailID = ?");
} else {
    $stmt = $conn->prepare("SELECT StudentID FROM Students WHERE Username = ? OR EmailID = ?");
}
$stmt->bind_param("ss", $username, $emailid);
$stmt->execute();
$stmt->store_result();
if ($stmt->num_rows > 0) {
    http_response_code(409);
    echo json_encode(['error' => 'Username or EmailID already exists']);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// Hash the password
$passwordHash = password_hash($password, PASSWORD_DEFAULT);

if ($role === 'faculty') {
    // Insert faculty user
    $stmt = $conn->prepare("INSERT INTO Faculty (Name, PhoneNumber, DOB, EmailID, Username, PasswordHash) VALUES (?, ?, ?, ?, ?, ?)");
    $facultyName = isset($data['facultyName']) ? trim($data['facultyName']) : '';
    $facultyPhoneNumber = isset($data['facultyPhoneNumber']) ? trim($data['facultyPhoneNumber']) : '';
    $facultyDOB = isset($data['facultyDOB']) && $data['facultyDOB'] !== '' ? $data['facultyDOB'] : null;
    // If facultyDOB is null, bind as null string to avoid errors
    if ($facultyDOB === null) {
        $facultyDOB = null;
    }
    $stmt->bind_param("ssssss", $facultyName, $facultyPhoneNumber, $facultyDOB, $emailid, $username, $passwordHash);

    if ($stmt->execute()) {
        http_response_code(201);
        echo json_encode(['message' => 'Faculty registered successfully']);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to register faculty: ' . $stmt->error]);
    }
    $stmt->close();
} else {
    // Insert student user
    $stmt = $conn->prepare("INSERT INTO Students (Name, Address, PhoneNumber, DOB, Semester, EmailID, Username, PasswordHash) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $studentName = isset($data['studentName']) ? trim($data['studentName']) : '';
    $address = isset($data['address']) ? trim($data['address']) : '';
    $phoneNumber = isset($data['phoneNumber']) ? trim($data['phoneNumber']) : '';
    $dob = isset($data['dob']) && $data['dob'] !== '' ? $data['dob'] : null;
    $semester = isset($data['semester']) ? intval($data['semester']) : 1;
    $stmt->bind_param("ssssisss", $studentName, $address, $phoneNumber, $dob, $semester, $emailid, $username, $passwordHash);

    if ($stmt->execute()) {
        http_response_code(201);
        echo json_encode(['message' => 'Student registered successfully']);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to register student: ' . $stmt->error]);
    }
    $stmt->close();
}

$conn->close();
?>
