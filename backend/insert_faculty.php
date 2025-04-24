<?php
include 'db_connection.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST['name'] ?? '';
    $phoneNumber = $_POST['phoneNumber'] ?? '';
    $dob = $_POST['dob'] ?? '';

    $stmt = $conn->prepare("INSERT INTO Faculty (Name, PhoneNumber, DOB) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $name, $phoneNumber, $dob);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Faculty added successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => $stmt->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>
