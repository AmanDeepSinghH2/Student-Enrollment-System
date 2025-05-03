<?php
session_start();
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'faculty') {
    header('Location: ../signin.html');
    exit;
}
$user = $_SESSION['user'];

require_once 'db_connection.php';

$coursesQuery = "SELECT c.Name AS course_name FROM Courses c JOIN CourseFaculty cf ON c.CourseID = cf.CourseID WHERE cf.FacultyID = ?";
$stmt = $conn->prepare($coursesQuery);
$stmt->bind_param("i", $user['userID']);
$stmt->execute();
$coursesResult = $stmt->get_result();
$courses = [];
if ($coursesResult->num_rows > 0) {
    while ($row = $coursesResult->fetch_assoc()) {
        $courses[] = $row;
    }
}

// Return data as JSON
header('Content-Type: application/json');
echo json_encode([
    'user' => [
        'name' => $user['name'],
        'userID' => $user['userID']
    ],
    'courses' => $courses
]);
?>
