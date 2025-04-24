<?php
header('Content-Type: application/json');
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

if (!isset($_GET['studentID'])) {
    http_response_code(400);
    echo json_encode(['error' => 'studentID parameter is required']);
    exit;
}

$studentID = intval($_GET['studentID']);

$sql = "SELECT c.CourseID, c.Name AS CourseName
        FROM Enrollments e
        JOIN Courses c ON e.CourseID = c.CourseID
        WHERE e.StudentID = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $studentID);
$stmt->execute();
$result = $stmt->get_result();

$courses = [];

while ($row = $result->fetch_assoc()) {
    $courses[] = $row;
}

$stmt->close();
$conn->close();

echo json_encode($courses);
?>
