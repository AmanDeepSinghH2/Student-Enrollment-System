<?php
$servername = "localhost";
$username = "username";
$password = "password";
$dbname = "student_enrollment";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $response = ['success' => false, 'message' => ''];

    $data = json_decode(file_get_contents("php://input"));

    if (isset($data->action)) {
        switch ($data->action) {
            case 'register':
                $name = $data->name;
                $email = $data->email;
                $stmt = $conn->prepare("INSERT INTO Students (Name, Email) VALUES (?, ?)");
                $stmt->bind_param("ss", $name, $email);
                $stmt->execute();
                $response['success'] = true;
                $response['message'] = 'Student registered successfully!';
                echo json_encode($response);

                break;

            case 'enroll':
                $student_id = $data->studentId;
                $course_id = $data->courseId;
                $stmt = $conn->prepare("INSERT INTO Enrollments (StudentID, CourseID) VALUES (?, ?)");
                $stmt->bind_param("ii", $student_id, $course_id);
                $stmt->execute();
                $response['success'] = true;
                $response['message'] = 'Student enrolled successfully!';
                echo json_encode($response);

                break;

            case 'submit_grade':
                $student_id = $data->studentId;
                $course_id = $data->courseId;
                $grade = $data->grade;
                $stmt = $conn->prepare("INSERT INTO Grades (StudentID, CourseID, Grade) VALUES (?, ?, ?)");
                $stmt->bind_param("iis", $student_id, $course_id, $grade);
                $stmt->execute();
                $response['success'] = true;
                $response['message'] = 'Grade submitted successfully!';
                echo json_encode($response);

                break;
        }
    }
}

$conn->close();
