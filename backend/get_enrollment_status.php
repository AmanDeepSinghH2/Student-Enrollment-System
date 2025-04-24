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

$sql = "SELECT Semester, Status, COUNT(*) AS CoursesEnrolled, MAX(EnrollmentDate) AS LastEnrollmentDate
        FROM Enrollments
        WHERE StudentID = ?
        GROUP BY Semester, Status";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $studentID);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['message' => 'No enrollment records found for this student']);
    $stmt->close();
    $conn->close();
    exit;
}

$enrollmentStatus = $result->fetch_assoc();

$stmt->close();
$conn->close();

echo json_encode([
    'semester' => $enrollmentStatus['Semester'],
    'status' => $enrollmentStatus['Status'],
    'coursesEnrolled' => intval($enrollmentStatus['CoursesEnrolled']),
    'lastEnrollmentDate' => $enrollmentStatus['LastEnrollmentDate']
]);
?>
