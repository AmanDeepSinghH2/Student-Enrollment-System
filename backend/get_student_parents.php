<?php
include 'db_connection.php';

$sql = "SELECT ParentID, StudentID, ParentType, PhoneNumber FROM StudentParents ORDER BY ParentID DESC";
$result = $conn->query($sql);

$parents = [];

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $parents[] = $row;
    }
}

echo json_encode($parents);

$conn->close();
?>
