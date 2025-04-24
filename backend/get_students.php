<?php
include 'db_connection.php';

$sql = "SELECT StudentID, Name, Address, PhoneNumber, DOB, Semester FROM Students ORDER BY StudentID DESC";
$result = $conn->query($sql);

$students = [];

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $students[] = $row;
    }
}

echo json_encode($students);

$conn->close();
?>
