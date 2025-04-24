<?php
include 'db_connection.php';

$sql = "SELECT e.EnrollmentID, e.StudentID, s.Name AS StudentName, e.Status, e.EnrollmentDate 
        FROM Enrollments e
        JOIN Students s ON e.StudentID = s.StudentID
        ORDER BY e.EnrollmentID DESC";
$result = $conn->query($sql);

$enrollments = [];

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $enrollments[] = $row;
    }
}

echo json_encode($enrollments);

$conn->close();
?>
