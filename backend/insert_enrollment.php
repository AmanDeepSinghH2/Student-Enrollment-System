<?php
include 'db_connection.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $studentID = $_POST['studentID'] ?? '';
    $status = $_POST['status'] ?? '';
    $enrollmentDate = $_POST['enrollmentDate'] ?? '';

    $stmt = $conn->prepare("INSERT INTO Enrollments (StudentID, Status, EnrollmentDate) VALUES (?, ?, ?)");
    $stmt->bind_param("iss", $studentID, $status, $enrollmentDate);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Enrollment added successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => $stmt->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>
