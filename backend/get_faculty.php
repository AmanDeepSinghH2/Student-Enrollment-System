<?php
include 'db_connection.php';

$sql = "SELECT FacultyID, Name, PhoneNumber, DOB FROM Faculty ORDER BY FacultyID DESC";
$result = $conn->query($sql);

$faculty = [];

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $faculty[] = $row;
    }
}

echo json_encode($faculty);

$conn->close();
?>
