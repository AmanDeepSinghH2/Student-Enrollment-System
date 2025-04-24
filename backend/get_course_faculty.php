<?php
include 'db_connection.php';

$sql = "SELECT cf.ID, c.CourseID, c.Name AS CourseName, f.FacultyID, f.Name AS FacultyName 
        FROM CourseFaculty cf
        JOIN Courses c ON cf.CourseID = c.CourseID
        JOIN Faculty f ON cf.FacultyID = f.FacultyID
        ORDER BY cf.ID DESC";
$result = $conn->query($sql);

$mappings = [];

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $mappings[] = $row;
    }
}

echo json_encode($mappings);

$conn->close();
?>
