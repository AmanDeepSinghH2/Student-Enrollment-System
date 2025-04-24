<?php
include 'db_connection.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $courseID = $_POST['courseID'] ?? '';
    $facultyID = $_POST['facultyID'] ?? '';

    $stmt = $conn->prepare("INSERT INTO CourseFaculty (CourseID, FacultyID) VALUES (?, ?)");
    $stmt->bind_param("ii", $courseID, $facultyID);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Course-Faculty mapping added successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => $stmt->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>
