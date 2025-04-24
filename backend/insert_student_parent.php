<?php
include 'db_connection.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $studentID = $_POST['studentID'] ?? '';
    $parentType = $_POST['parentType'] ?? '';
    $phoneNumber = $_POST['phoneNumber'] ?? '';

    $stmt = $conn->prepare("INSERT INTO StudentParents (StudentID, ParentType, PhoneNumber) VALUES (?, ?, ?)");
    $stmt->bind_param("iss", $studentID, $parentType, $phoneNumber);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Student parent added successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => $stmt->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>
