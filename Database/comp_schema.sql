DROP DATABASE IF EXISTS Enroll;
CREATE DATABASE Enroll;
USE Enroll;

CREATE TABLE FullData (
    RecordID INT PRIMARY KEY AUTO_INCREMENT,
    
    -- Student Info
    StudentID INT,
    StudentName VARCHAR(100),
    StudentAddress VARCHAR(255),
    StudentPhoneNumber VARCHAR(15),
    MotherPhoneNumber VARCHAR(15),
    FatherPhoneNumber VARCHAR(15),
    StudentDOB DATE,
    StudentSemester INT,
    StudentCreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Enrollment Info
    EnrollmentID INT,
    EnrollmentStatus VARCHAR(50),
    EnrollmentDate DATE,

    -- Course Info
    CourseID INT,
    CourseName VARCHAR(100),

    -- Faculty Info
    FacultyID INT,
    FacultyName VARCHAR(100),
    FacultyPhoneNumber VARCHAR(15),
    FacultyDOB DATE,

    -- Grade Info
    GradeID INT,
    Grade VARCHAR(2),
    GradeDate DATE,
    GradeCreatedAt TIMESTAMP
);
INSERT INTO FullData (
    StudentID, StudentName, StudentAddress, StudentPhoneNumber,
    MotherPhoneNumber, FatherPhoneNumber, StudentDOB, StudentSemester,

    EnrollmentID, EnrollmentStatus, EnrollmentDate,

    CourseID, CourseName,

    FacultyID, FacultyName, FacultyPhoneNumber, FacultyDOB,

    GradeID, Grade, GradeDate, GradeCreatedAt
)
VALUES
(1, 'Alice Smith', '456 Elm St', '2345678901', '1234567890', '2233445566', '2001-02-15', 2,
 1, 'Pending', '2023-01-10',
 1, 'Introduction to Mathematics',
 1, 'Dr. Jane Smith', '2345678901', '1980-02-20',
 1, 'A', '2023-01-15', CURRENT_TIMESTAMP),

(2, 'Bob Johnson', '789 Oak St', '3456789012', '2345678901', '3344556677', '2002-03-20', 3,
 2, 'Enrolled', '2023-02-12',
 2, 'Advanced Statistics',
 1, 'Dr. Jane Smith', '2345678901', '1980-02-20',
 2, 'B+', '2023-02-20', CURRENT_TIMESTAMP),

(3, 'Charlie Brown', '101 Pine St', '4567890123', '3456789012', '4455667788', '2003-04-25', 4,
 3, 'Completed', '2023-03-14',
 3, 'Biology 101',
 2, 'Dr. Emily Davis', '3456789012', '1985-03-25',
 3, 'A+', '2023-03-25', CURRENT_TIMESTAMP);
