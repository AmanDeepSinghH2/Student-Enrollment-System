<?php
session_start();
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'student') {
    header('Location: ../signin.html');
    exit;
}
$user = $_SESSION['user'];

require_once 'db_connection.php';

// Fetch courses
$coursesQuery = "SELECT Name AS course_name FROM Courses";
$coursesResult = $conn->query($coursesQuery);
$courses = [];
if ($coursesResult->num_rows > 0) {
    while ($row = $coursesResult->fetch_assoc()) {
        $courses[] = $row;
    }
}

// Fetch enrollment details
$enrollmentQuery = "SELECT Semester AS semester, Status AS enrollment_status, EnrollmentDate AS valid_till FROM Enrollments WHERE StudentID = ?";
$stmt = $conn->prepare($enrollmentQuery);
$stmt->bind_param("i", $user['userID']);
$stmt->execute();
$enrollmentResult = $stmt->get_result();
$enrollment = $enrollmentResult->fetch_assoc();

// Return data as JSON
header('Content-Type: application/json');
echo json_encode([
    'user' => [
        'name' => $user['name'],
        'userID' => $user['userID']
    ],
    'courses' => $courses,
    'enrollment' => $enrollment
]);
?>
