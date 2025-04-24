<?php
include 'db_connection.php';

$sql = "SELECT CourseID, Name FROM Courses ORDER BY CourseID DESC";
$result = $conn->query($sql);

$courses = [];

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $courses[] = $row;
    }
}

echo json_encode($courses);

$conn->close();
?>
