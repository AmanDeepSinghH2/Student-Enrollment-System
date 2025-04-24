<?php
include 'db_connection.php';

$sql = "SELECT g.GradeID, g.StudentID, s.Name AS StudentName, g.CourseID, c.Name AS CourseName, g.Grade, g.GradeDate 
        FROM Grades g
        JOIN Students s ON g.StudentID = s.StudentID
        JOIN Courses c ON g.CourseID = c.CourseID
        ORDER BY g.GradeID DESC";
$result = $conn->query($sql);

$grades = [];

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $grades[] = $row;
    }
}

echo json_encode($grades);

$conn->close();
?>
