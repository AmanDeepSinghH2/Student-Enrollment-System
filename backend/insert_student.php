<?php
include 'db_connection.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST['name'] ?? '';
    $address = $_POST['address'] ?? '';
    $phoneNumber = $_POST['phoneNumber'] ?? '';
    $dob = $_POST['dob'] ?? '';
    $semester = $_POST['semester'] ?? '';

    $stmt = $conn->prepare("INSERT INTO Students (Name, Address, PhoneNumber, DOB, Semester) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssi", $name, $address, $phoneNumber, $dob, $semester);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Student added successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => $stmt->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>
