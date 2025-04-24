<?php
include 'db_connection.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $studentID = $_POST['studentID'] ?? '';
    $courseID = $_POST['courseID'] ?? '';
    $grade = $_POST['grade'] ?? '';
    $gradeDate = $_POST['gradeDate'] ?? '';

    $stmt = $conn->prepare("INSERT INTO Grades (StudentID, CourseID, Grade, GradeDate) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("iiss", $studentID, $courseID, $grade, $gradeDate);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Grade added successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => $stmt->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>
